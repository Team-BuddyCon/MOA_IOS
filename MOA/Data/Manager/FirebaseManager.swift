//
//  FirebaseManager.swift
//  MOA
//
//  Created by 오원석 on 2/9/25.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

private let MIME_TYPE = "image/jpeg"

final class FirebaseManager {
    static let shared = FirebaseManager()
    private init() {}
    
    private let storage = Storage.storage()
    private let store = Firestore.firestore()
    
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
                    self.store.collection(userID).document(uuid).setData(
                        [
                            HttpKeys.Gifticon.gifticonId: uuid,
                            HttpKeys.Gifticon.imageUrl: imageUrl,
                            HttpKeys.Gifticon.name: name,
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
}
