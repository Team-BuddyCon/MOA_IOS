//
//  DetailGifticon.swift
//  MOA
//
//  Created by 오원석 on 12/12/24.
//

import Foundation

struct DetailGifticon {
    let gifticonId: Int
    let imageUrl: String
    let name: String
    let memo: String
    let expireDate: String
    let gifticonStore: StoreType
    let gifticonStoreCategory: StoreCategory
    let used: Bool
    
    init(
        gifticonId: Int = 0,
        imageUrl: String = "",
        name: String = "",
        memo: String = "",
        expireDate: String = "",
        gifticonStore: StoreType = .ALL,
        gifticonStoreCategory: StoreCategory = .All,
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
