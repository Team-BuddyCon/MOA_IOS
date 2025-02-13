//
//  AvailableGifticon.swift
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
    let used: Bool
    
    init(
        gifticonId: String = "",
        imageUrl: String = "",
        name: String = "",
        memo: String = "",
        expireDate: String = "",
        gifticonStore: StoreType = .ALL,
        gifticonStoreCategory: StoreCategory = .ALL,
        used: Bool = false
    ) {
        self.gifticonId = gifticonId
        self.imageUrl = imageUrl
        self.name = name
        self.memo = memo
        self.expireDate = expireDate
        self.gifticonStore = gifticonStore
        self.gifticonStoreCategory = gifticonStoreCategory
        self.used = used
    }
}
