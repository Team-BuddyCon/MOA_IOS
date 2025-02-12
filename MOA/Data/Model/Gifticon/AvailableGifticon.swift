//
//  AvailableGifticon.swift
//  MOA
//
//  Created by 오원석 on 11/11/24.
//

import Foundation

struct AvailableGifticon {
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
    
    init(dic: [String: Any]) {
        self.gifticonId = dic[HttpKeys.Gifticon.gifticonId] as! String
        self.imageUrl = dic[HttpKeys.Gifticon.imageUrl] as! String
        self.name = dic[HttpKeys.Gifticon.name] as! String
        self.memo = dic[HttpKeys.Gifticon.memo] as! String
        self.expireDate = dic[HttpKeys.Gifticon.expireDate] as! String
        self.gifticonStore = StoreType.from(string: dic[HttpKeys.Gifticon.gifticonStore] as! String) ?? .ALL
        self.gifticonStoreCategory = StoreCategory.from(string: dic[HttpKeys.Gifticon.gifticonStoreCategory] as! String) ?? .All
        self.used = dic[HttpKeys.Gifticon.used] as! Bool
    }
}
