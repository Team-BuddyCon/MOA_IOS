//
//  UnAvailableGifticon.swift
//  MOA
//
//  Created by 오원석 on 11/11/24.
//

import Foundation

struct UnAvailableGifticon {
    let gifticonId: Int
    let imageUrl: String
    let name: String
    let memo: String
    let expireDate: String
    let gifticonStore: StoreType
    let gifticonStoreCategory: StoreCategory
    
    init(
        gifticonId: Int = Int.min,
        imageUrl: String = "",
        name: String = "",
        memo: String = "",
        expireDate: String = "",
        gifticonStore: StoreType = .ALL,
        gifticonStoreCategory: StoreCategory = .All
    ) {
        self.gifticonId = gifticonId
        self.imageUrl = imageUrl
        self.name = name
        self.memo = memo
        self.expireDate = expireDate
        self.gifticonStore = gifticonStore
        self.gifticonStoreCategory = gifticonStoreCategory
    }
}
