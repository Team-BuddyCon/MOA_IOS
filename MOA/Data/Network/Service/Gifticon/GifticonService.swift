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
        sortType: SortType,
        used: Bool
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
    
    ///
    
    func fetchAvailableGifticon(
        pageNumber: Int,
        rowCount: Int,
        storeCateogry: StoreCategory?,
        storeType: StoreType?,
        sortType: SortType
    ) -> Observable<Result<AvailableGifticonResponse, URLError>>
    
    func fetchCreateGifticon(
        image: Data,
        name: String,
        expireDate: String,
        store: String,
        memo: String?
    ) -> Observable<Result<CreateGifticonResponse, URLError>>
    
    func fetchDetailGifticon(
        gifticonId: Int
    ) -> Observable<Result<DetailGifticonResponse, URLError>>
    
    func fetchDeleteGifticon(
        gifticonId: Int
    ) -> Observable<Result<MockGifticonResponse, URLError>>
    
    func fetchUpdateGifticon(
        gifticonId: Int,
        name: String,
        expireDate: String,
        store: String,
        memo: String?
    ) -> Observable<Result<MockGifticonResponse, URLError>>
    
    func fetchUpdateUsedGifticon(
        gifticonId: Int,
        used: Bool
    ) -> Observable<Result<MockGifticonResponse, URLError>>
    
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
        sortType: SortType,
        used: Bool
    ) -> Observable<[GifticonResponse]> {
        return Observable.create { observer in
            self.store
                .collection(FirebaseStoreID.USER.rawValue)
                .document(self.userID)
                .collection(FirebaseStoreID.GIFTICON.rawValue)
                .order(by: sortType.orderByField, descending: false)
                .whereField(HttpKeys.Gifticon.gifticonStoreCategory, in: category.categoryField)
                .whereField(HttpKeys.Gifticon.used, isEqualTo: used)
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
                        observer.onError(NSError())
                    }
                }
            
            return Disposables.create()
        }
    }
    
    ///
    
    func fetchAvailableGifticon(
        pageNumber: Int,
        rowCount: Int = 20,
        storeCateogry: StoreCategory?,
        storeType: StoreType?,
        sortType: SortType
    ) -> Observable<Result<AvailableGifticonResponse, URLError>> {
        let request = AvailableGifticonRequest(
            pageNumber: pageNumber,
            rowCount: rowCount,
            storeCategory: storeCateogry,
            storeType: storeType,
            sortType: sortType
        )
        
        return NetworkManager.shared.request(request: request)
    }
    
    func fetchCreateGifticon(
        image: Data,
        name: String,
        expireDate: String,
        store: String,
        memo: String?
    ) -> Observable<Result<CreateGifticonResponse, URLError>> {
        let request = CreateGifticonRequest(
            image: image,
            name: name,
            expireDate: expireDate,
            store: store,
            memo: memo
        )
        
        return NetworkManager.shared.request(request: request)
    }
    
    func fetchDetailGifticon(
        gifticonId: Int
    ) -> Observable<Result<DetailGifticonResponse, URLError>> {
        let request = DetailGifticonRequest(gifticonId: gifticonId)
        return NetworkManager.shared.request(request: request)
    }
    
    func fetchDeleteGifticon(
        gifticonId: Int
    ) -> Observable<Result<MockGifticonResponse, URLError>> {
        let request = DeleteGifticonRequest(gifticonId: gifticonId)
        return NetworkManager.shared.request(request: request)
    }
    
    func fetchUpdateGifticon(
        gifticonId: Int,
        name: String,
        expireDate: String,
        store: String,
        memo: String?
    ) -> Observable<Result<MockGifticonResponse, URLError>> {
        let request = UpdateGifticonRequest(
            gifticonId: gifticonId,
            name: name,
            expireDate: expireDate,
            store: store,
            memo: memo
        )
        return NetworkManager.shared.request(request: request)
    }
    
    func fetchUpdateUsedGifticon(
        gifticonId: Int,
        used: Bool
    ) -> Observable<Result<MockGifticonResponse, URLError>> {
        let request = UpdateUsedGifticonRequest(
            gifticonId: gifticonId,
            used: used
        )
        return NetworkManager.shared.request(request: request)
    }
    
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
