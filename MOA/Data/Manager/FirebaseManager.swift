//
//  FirebaseManager.swift
//  MOA
//
//  Created by 오원석 on 2/9/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import FirebaseStorage
import FirebaseFirestore

private let USER_DB_ID = "users"
private let GIFTICON_DB_ID = "gifticons"
private let MIME_TYPE = "image/jpeg"

final class FirebaseManager {
    static let shared = FirebaseManager()
    private init() {}
    
    private let storage = Storage.storage()
    private let store = Firestore.firestore()
    
    func getGifticon(
        gifticonId: String
    ) -> Observable<AvailableGifticon> {
        return Observable.create { observer in
            let userID = UserPreferences.getUserID()
            
            self.store
                .collection(USER_DB_ID)
                .document("\(userID)")
                .collection(GIFTICON_DB_ID)
                .document("\(gifticonId)")
                .getDocument(completion: { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                    } else if let snapshot = snapshot {
                        if snapshot.exists, let data = snapshot.data() {
                            let gifticon = AvailableGifticon(dic: data)
                            observer.onNext(gifticon)
                            observer.onCompleted()
                        } else {
                            observer.onError(NSError())
                        }
                    } else {
                        observer.onError(NSError())
                    }
                })
            
            return Disposables.create()
        }
    }
    
    func getAllGifticon(
        categoryType: StoreCategory,
        sortType: SortType
    ) -> Observable<[AvailableGifticon]> {
        return Observable.create { observer in
            let userID = UserPreferences.getUserID()
            
            var orderBy: String = ""
            switch sortType {
            case .EXPIRE_DATE:
                orderBy = HttpKeys.Gifticon.expireDate
            case .CREATED_AT:
                orderBy = HttpKeys.Gifticon.uplodeDate
            case .NAME:
                orderBy = HttpKeys.Gifticon.name
            }
            
            var category: [String] = []
            switch categoryType {
            case .All:
                category = StoreCategory.allCases.compactMap { $0.code }
            default:
                if let code = categoryType.code {
                    category.append(code)
                }
            }
            
            self.store
                .collection(USER_DB_ID)
                .document("\(userID)")
                .collection(GIFTICON_DB_ID)
                .order(by: orderBy, descending: false)
                .whereField(HttpKeys.Gifticon.gifticonStoreCategory, in: category)
                .getDocuments(completion: { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                    } else if let snapshot = snapshot {
                        let gifticons = snapshot.documents.compactMap { document in
                            AvailableGifticon(dic: document.data())
                        }
                        observer.onNext(gifticons)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError())
                    }
                })
            
            return Disposables.create()
        }
    }
    
    func createGifticon(
        jpegData: Data,
        name: String,
        expireDate: String,
        gifticonStore: String,
        memo: String? = nil,
        onSucess: @escaping () -> Void,
        onError: @escaping () -> Void
    ) {
 
        let storeCategory = StoreCategory.from(typeCode: gifticonStore)?.code
        guard let storeCategory = storeCategory else { return }
        
        let uuid = UUID().uuidString
        let userID = UserPreferences.getUserID()
        let uploadDate = Date().toString(format: AVAILABLE_GIFTICON_TIME_FORMAT)
        let currentTime = Int(Date().timeIntervalSince1970)
        let storagePath = "\(userID)/\(currentTime).jpeg"
        let storageRef = storage.reference().child(storagePath)
        let metaData = StorageMetadata()
        metaData.contentType = MIME_TYPE
        
        let _ = storageRef.putData(jpegData, metadata: metaData) { (metadata, error) in
            guard error == nil else {
                MOALogger.loge("createGifticon putData error: \(String(describing: error))")
                onError()
                return
            }
            
            guard metadata != nil else {
                MOALogger.loge("createGifticon putData metadata: \(metaData)")
                onError()
                return
            }
            
            MOALogger.logd("createGifticon putData success")
            storageRef.downloadURL(completion: { url, error in
                guard error == nil else {
                    MOALogger.loge("createGifticon downloadURL error: \(String(describing: error))")
                    onError()
                    return
                }
                
                if let imageUrl = url?.absoluteString {
                    self.store.collection(USER_DB_ID)
                        .document(userID)
                        .collection(GIFTICON_DB_ID)
                        .document(uuid).setData(
                            [
                                HttpKeys.Gifticon.gifticonId: uuid,
                                HttpKeys.Gifticon.imageUrl: imageUrl,
                                HttpKeys.Gifticon.name: name,
                                HttpKeys.Gifticon.uplodeDate: uploadDate,
                                HttpKeys.Gifticon.expireDate: expireDate,
                                HttpKeys.Gifticon.gifticonStore: gifticonStore,
                                HttpKeys.Gifticon.gifticonStoreCategory: storeCategory,
                                HttpKeys.Gifticon.memo: memo ?? "",
                                HttpKeys.Gifticon.used: false
                            ]
                    ) { error in
                        guard error == nil else {
                            MOALogger.loge("createGifticon setData error: \(String(describing: error))")
                            onError()
                            return
                        }
                        MOALogger.logd("createGifticon success")
                    }
                }
            })
        }
    }
    
    func updateGifticon(
        gifticonId: String,
        name: String? = nil,
        expireDate: String? = nil,
        gifticonStore: String? = nil,
        memo: String? = nil,
        used: Bool? = nil
    ) -> Observable<Bool> {
        return Observable.create { observer in
            var fields: [String: Any] = [:]
            if let name = name {
                fields.updateValue(name, forKey: HttpKeys.Gifticon.name)
            }
            
            if let expireDate = expireDate {
                fields.updateValue(expireDate, forKey: HttpKeys.Gifticon.expireDate)
            }
            
            if let gifticonStore = gifticonStore {
                fields.updateValue(gifticonStore, forKey: HttpKeys.Gifticon.gifticonStore)
            }
            
            if let memo = memo {
                fields.updateValue(memo, forKey: HttpKeys.Gifticon.memo)
            }
            
            if let used = used {
                fields.updateValue(used, forKey: HttpKeys.Gifticon.used)
            }
            
            let userID = UserPreferences.getUserID()
            self.store
                .collection(USER_DB_ID)
                .document("\(userID)")
                .collection(GIFTICON_DB_ID)
                .document("\(gifticonId)")
                .updateData(fields) { error in
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
    
    func deleteGifticon(
        gifticonId: String
    ) -> Observable<Bool> {
        return Observable.create { observer in
            let userID = UserPreferences.getUserID()
            self.store
                .collection(USER_DB_ID)
                .document("\(userID)")
                .collection(GIFTICON_DB_ID)
                .document("\(gifticonId)")
                .delete() { error in
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
}
