//
//  GifticonResponse.swift
//  MOA
//
//  Created by 오원석 on 2/13/25.
//

import Foundation

struct GifticonResponse {
    let gifticonId: String
    let imageUrl: String
    let name: String
    let memo: String
    let expireDate: String
    let gifticonStore: String
    let gifticonStoreCategory: String
    let used: Bool
    
    init(dic: [String: Any]) {
        self.gifticonId = (dic[HttpKeys.Gifticon.gifticonId] as? String) ?? ""
        self.imageUrl = (dic[HttpKeys.Gifticon.imageUrl] as? String) ?? ""
        self.name = (dic[HttpKeys.Gifticon.name] as? String) ?? ""
        self.memo = (dic[HttpKeys.Gifticon.memo] as? String) ?? ""
        self.expireDate = (dic[HttpKeys.Gifticon.expireDate] as? String) ?? ""
        self.gifticonStore = (dic[HttpKeys.Gifticon.gifticonStore] as? String) ?? ""
        self.gifticonStoreCategory = (dic[HttpKeys.Gifticon.gifticonStoreCategory] as? String) ?? ""
        self.used = (dic[HttpKeys.Gifticon.used] as? Bool) ?? false
    }
    
    func toModel() -> GifticonModel {
        GifticonModel(
            gifticonId: gifticonId,
            imageUrl: imageUrl,
            name: name,
            memo: memo,
            expireDate: expireDate,
            gifticonStore: StoreType.from(string: gifticonStore) ?? .ALL,
            gifticonStoreCategory: StoreCategory.from(string: gifticonStoreCategory) ?? .ALL,
            used: used
        )
    }
}
