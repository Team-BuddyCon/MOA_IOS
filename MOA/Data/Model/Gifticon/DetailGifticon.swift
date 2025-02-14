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
    let expireDate: Date
    let gifticonStore: StoreType
    let gifticonStoreCategory: StoreCategory
    var used: Bool
    
    init(
        gifticonId: Int = 0,
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = AVAILABLE_GIFTICON_RESPONSE_TIME_FORMAT
        
        if let date = formatter.date(from: expireDate) {
            self.expireDate = date
        } else {
            self.expireDate = Date()
        }
        
        self.gifticonStore = gifticonStore
        self.gifticonStoreCategory = gifticonStoreCategory
        self.used = used
    }
}
