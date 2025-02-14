//
//  GifticonService.swift
//  MOA
//
//  Created by 오원석 on 11/11/24.
//

import Foundation
import RxSwift
import FirebaseStorage
import FirebaseFirestore

protocol GifticonServiceProtocol {
    
    func fetchGifticons(
        category: StoreCategory,
        sortType: SortType
    ) -> Observable<[GifticonResponse]>
    
    func fetchGifticons(
        storeType: StoreType
    ) -> Observable<[GifticonResponse]>
    
    func fetchGifticon(
        gifticonId: String
    ) -> Observable<GifticonResponse>
    
    func updateGifticon(
        gifticonId: String,
        name: String?,
        expireDate: String?,
        gifticonStore: String?,
        memo: String?,
        used: Bool?
    ) -> Observable<Bool>
    
    func deleteGifticon(
        gifticonId: String
    ) -> Observable<Bool>
    
    func createGifticon(
        data: Data,
        name: String,
        expireDate: String,
        gifticonStore: String,
        memo: String?
    ) -> Observable<String>
    
    func fetchUsedGifticons() -> Observable<[GifticonResponse]>
    
    ///
    
    func fetchUnAvailableGifticon(
        pageNumber: Int,
        rowCount: Int
    ) -> Observable<Result<UnAvailableGifticonResponse, URLError>>
    
    func fetchGifticonCount(
        used: Bool,
        storeCateogry: StoreCategory?,
        storeType: StoreType?,
        remainingDays: Int?
    ) -> Observable<Result<GifticonCountResponse, URLError>>
}


final class GifticonService: GifticonServiceProtocol {

    enum FirebaseStoreID: String {
        case USER = "users"
        case GIFTICON = "gifticons"
    }
    
    enum FirebaseStorageMIME: String {
        case imageJPEG = "image/jpeg"
    }
    
    static let shared = GifticonService()
    private init() {}
    
    private let storage = Storage.storage()
    private let store = Firestore.firestore()
    private var userID: String {
        UserPreferences.getUserID()
    }
    
    func fetchGifticons(
        category: StoreCategory,
        sortType: SortType
    ) -> Observable<[GifticonResponse]> {
        return Observable.create { observer in
            self.store
                .collection(FirebaseStoreID.USER.rawValue)
                .document(self.userID)
                .collection(FirebaseStoreID.GIFTICON.rawValue)
                .order(by: sortType.field, descending: false)
                .whereField(HttpKeys.Gifticon.gifticonStoreCategory, in: category.categoryField)
                .whereField(HttpKeys.Gifticon.used, isEqualTo: false)
                .getDocuments(completion: { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                    } else if let snapshot = snapshot {
                        let gifticons = snapshot.documents.compactMap { document in
                            GifticonResponse(dic: document.data())
                        }
                        observer.onNext(gifticons)
                        observer.onCompleted()
                    } else {
                        observer.onError(error ?? NSError())
                    }
                })
            
            return Disposables.create()
        }
    }
    
    func fetchGifticons(storeType: StoreType) -> Observable<[GifticonResponse]> {
        return Observable.create { observer in
            self.store
                .collection(FirebaseStoreID.USER.rawValue)
                .document(self.userID)
                .collection(FirebaseStoreID.GIFTICON.rawValue)
                .order(by: HttpKeys.Gifticon.expireDate, descending: false)
                .whereField(HttpKeys.Gifticon.gifticonStore, in: storeType.fields)
                .whereField(HttpKeys.Gifticon.used, isEqualTo: false)
                .getDocuments(completion: { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                    } else if let snapshot = snapshot {
                        let gifticons = snapshot.documents.compactMap { document in
                            GifticonResponse(dic: document.data())
                        }
                        observer.onNext(gifticons)
                        observer.onCompleted()
                    } else {
                        observer.onError(error ?? NSError())
                    }
                })
            
            return Disposables.create()
        }
    }
    
    func fetchGifticon(gifticonId: String) -> Observable<GifticonResponse> {
        return Observable.create { observer in
            self.store
                .collection(FirebaseStoreID.USER.rawValue)
                .document(self.userID)
                .collection(FirebaseStoreID.GIFTICON.rawValue)
                .document(gifticonId)
                .getDocument(completion: { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                    } else if let snapshot = snapshot {
                        if snapshot.exists, let data = snapshot.data() {
                            let gifticon = GifticonResponse(dic: data)
                            observer.onNext(gifticon)
                            observer.onCompleted()
                        } else {
                            observer.onError(error ?? NSError())
                        }
                    } else {
                        observer.onError(error ?? NSError())
                    }
                })
            
            return Disposables.create()
        }
    }
    
    func updateGifticon(
        gifticonId: String,
        name: String?,
        expireDate: String?,
        gifticonStore: String?,
        memo: String?,
        used: Bool?
    ) -> Observable<Bool> {
        return Observable.create { observer in
            var updateFields: [String: Any] = [:]
            if let name = name {
                updateFields.updateValue(name, forKey: HttpKeys.Gifticon.name)
            }
            
            if let expireDate = expireDate {
                updateFields.updateValue(expireDate, forKey: HttpKeys.Gifticon.expireDate)
            }
            
            if let gifticonStore = gifticonStore {
                updateFields.updateValue(gifticonStore, forKey: HttpKeys.Gifticon.gifticonStore)
            }
            
            if let memo = memo {
                updateFields.updateValue(memo, forKey: HttpKeys.Gifticon.memo)
            }
            
            if let used = used {
                updateFields.updateValue(used, forKey: HttpKeys.Gifticon.used)
            }
            
            self.store
                .collection(FirebaseStoreID.USER.rawValue)
                .document(self.userID)
                .collection(FirebaseStoreID.GIFTICON.rawValue)
                .document(gifticonId)
                .updateData(updateFields) { error in
                    if error == nil {
                        observer.onNext(true)
                        observer.onCompleted()
                    } else {
                        observer.onError(error ?? NSError())
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func deleteGifticon(gifticonId: String) -> Observable<Bool> {
        return Observable.create { observer in
            let storagePath = "\(self.userID)/\(gifticonId).jpeg"
            let storageRef = self.storage.reference().child(storagePath)
            storageRef.delete { error in
                if error == nil {
                    self.store
                        .collection(FirebaseStoreID.USER.rawValue)
                        .document(self.userID)
                        .collection(FirebaseStoreID.GIFTICON.rawValue)
                        .document(gifticonId)
                        .delete { error in
                            if error == nil {
                                observer.onNext(true)
                                observer.onCompleted()
                            } else {
                                observer.onError(error ?? NSError())
                            }
                        }
                } else {
                    observer.onError(error ?? NSError())
                }
            }
            
            return Disposables.create()
        }
    }
    
    func createGifticon(
        data: Data,
        name: String,
        expireDate: String,
        gifticonStore: String,
        memo: String? = nil
    ) -> Observable<String> {
        return Observable.create { observer in
            guard let gifticonStoreCategory = StoreCategory.from(typeCode: gifticonStore)?.code else {
                observer.onError(NSError())
                return Disposables.create()
            }
            
            let uuid = UUID().uuidString
            let uploadDate = Date().toString(format: AVAILABLE_GIFTICON_TIME_FORMAT)
            let storagePath = "\(self.userID)/\(uuid).jpeg"
            let storageRef = self.storage.reference().child(storagePath)
            let metaData = StorageMetadata()
            metaData.contentType = FirebaseStorageMIME.imageJPEG.rawValue
            
            storageRef.putData(data, metadata: metaData) { metadata, error in
                guard error == nil else {
                    MOALogger.loge("createGifticon putData error: \(String(describing: error))")
                    observer.onError(error ?? NSError())
                    return
                }
                
                guard metadata != nil else {
                    MOALogger.loge("createGifticon putData metadata: \(metaData)")
                    observer.onError(error ?? NSError())
                    return
                }
                
                MOALogger.logd("createGifticon putData success")
                storageRef.downloadURL { url, error in
                    guard error == nil else {
                        MOALogger.loge("createGifticon downloadURL error: \(String(describing: error))")
                        observer.onError(error ?? NSError())
                        return
                    }
                    
                    if let imageUrl = url?.absoluteString {
                        self.store.collection(FirebaseStoreID.USER.rawValue)
                            .document(self.userID)
                            .collection(FirebaseStoreID.GIFTICON.rawValue)
                            .document(uuid)
                            .setData([
                                HttpKeys.Gifticon.gifticonId: uuid,
                                HttpKeys.Gifticon.imageUrl: imageUrl,
                                HttpKeys.Gifticon.name: name,
                                HttpKeys.Gifticon.uplodeDate: uploadDate,
                                HttpKeys.Gifticon.expireDate: expireDate,
                                HttpKeys.Gifticon.gifticonStore: gifticonStore,
                                HttpKeys.Gifticon.gifticonStoreCategory: gifticonStoreCategory,
                                HttpKeys.Gifticon.memo: memo ?? "",
                                HttpKeys.Gifticon.used: false
                            ]) { error in
                                guard error == nil else {
                                    MOALogger.loge("createGifticon setData error: \(String(describing: error))")
                                    observer.onError(error ?? NSError())
                                    return
                                }
                                MOALogger.logd("createGifticon success")
                                observer.onNext(uuid)
                                observer.onCompleted()
                            }
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchUsedGifticons() -> Observable<[GifticonResponse]> {
        return Observable.create { observer in
            self.store
                .collection(FirebaseStoreID.USER.rawValue)
                .document(self.userID)
                .collection(FirebaseStoreID.GIFTICON.rawValue)
                .whereField(HttpKeys.Gifticon.used, isEqualTo: true)
                .getDocuments(completion: { (snapshot, error) in
                    if let error = error {
                        observer.onError(error)
                    } else if let snapshot = snapshot {
                        let gifticons = snapshot.documents.compactMap { document in
                            GifticonResponse(dic: document.data())
                        }
                        observer.onNext(gifticons)
                        observer.onCompleted()
                    } else {
                        observer.onError(error ?? NSError())
                    }
                })
            
            return Disposables.create()
        }
    }
    
    ///

    func fetchUnAvailableGifticon(
        pageNumber: Int,
        rowCount: Int
    ) -> Observable<Result<UnAvailableGifticonResponse, URLError>> {
        let request = UnAvailableGifticonRequest(
            pageNumber: pageNumber,
            rowCount: rowCount
        )
        return NetworkManager.shared.request(request: request)
    }
    
    func fetchGifticonCount(
        used: Bool,
        storeCateogry: StoreCategory?,
        storeType: StoreType?,
        remainingDays: Int?
    ) -> Observable<Result<GifticonCountResponse, URLError>> {
        let request = GifticonCountRequest(
            used: used,
            storeCategory: storeCateogry,
            storeType: storeType,
            remainingDays: remainingDays
        )
        return NetworkManager.shared.request(request: request)
    }
}
