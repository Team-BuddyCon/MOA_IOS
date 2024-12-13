//
//  DetailGifticonResponse.swift
//  MOA
//
//  Created by 오원석 on 12/12/24.
//

import Foundation

struct DetailGifticonResponse: BaseResponse {
    var status: Int
    var message: String
    var info: DetailGifticonInfo
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case info = "body"
    }
}

struct DetailGifticonInfo: Decodable {
    let gifticonId: Int
    let imageUrl: String
    let name: String
    let memo: String
    let expireDate: String
    let gifticonStore: String
    let gifticonStoreCategory: String
    let used: Bool
    
    func toModel() -> DetailGifticon {
        DetailGifticon(
            gifticonId: gifticonId,
            imageUrl: imageUrl,
            name: name,
            memo: memo,
            expireDate: expireDate.transformTimeformat(
                origin: AVAILABLE_GIFTICON_RESPONSE_TIME_FORMAT,
                dest: AVAILABLE_GIFTICON_UI_TIME_FORMAT
            ),
            gifticonStore: StoreType(rawValue: gifticonStore) ?? .ALL,
            gifticonStoreCategory: StoreCategory(rawValue: gifticonStoreCategory) ?? .All,
            used: used
        )
    }
}
