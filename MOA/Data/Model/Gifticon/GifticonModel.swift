//
//  GifticonModel.swift
//  MOA
//
//  Created by 오원석 on 11/11/24.
//

import Foundation

struct GifticonModel {
    let gifticonId: String
    let imageUrl: String
    let name: String
    let memo: String
    let expireDate: String
    let gifticonStore: StoreType
    let gifticonStoreCategory: StoreCategory
    let uploadDate: String
    let used: Bool
    
    init(
        gifticonId: String = "",
        imageUrl: String = "",
        name: String = "",
        memo: String = "",
        expireDate: String = "",
        gifticonStore: StoreType = .ALL,
        gifticonStoreCategory: StoreCategory = .ALL,
        uploadDate: String = "",
        used: Bool = false
    ) {
        self.gifticonId = gifticonId
        self.imageUrl = imageUrl
        self.name = name
        self.memo = memo
        self.expireDate = expireDate
        self.gifticonStore = gifticonStore
        self.gifticonStoreCategory = gifticonStoreCategory
        self.uploadDate = uploadDate
        self.used = used
    }
}
