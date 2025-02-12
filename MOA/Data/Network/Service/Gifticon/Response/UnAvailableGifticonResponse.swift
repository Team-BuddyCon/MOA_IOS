//
//  UnAvailableGifticonResponse.swift
//  MOA
//
//  Created by 오원석 on 1/10/25.
//

import Foundation

struct UnAvailableGifticonResponse: BaseResponse {
    var status: Int
    var message: String
    var gifticonInfos: UnAvailableGifticonInfos
    
    struct UnAvailableGifticonInfos: Decodable {
        let size: Int
        let content: [UnAvailableGifticonInfo]
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case gifticonInfos = "body"
    }
}

struct UnAvailableGifticonInfo: Decodable {
    let gifticonId: Int
    let imageUrl: String
    let name: String
    let memo: String
    let expireDate: String
    let gifticonStore: String
    let gifticonStoreCategory: String
    
    func toModel() -> UnAvailableGifticon {
        UnAvailableGifticon(
            gifticonId: gifticonId,
            imageUrl: imageUrl,
            name: name,
            memo: memo,
            expireDate: expireDate.transformTimeformat(
                origin: AVAILABLE_GIFTICON_RESPONSE_TIME_FORMAT,
                dest: AVAILABLE_GIFTICON_TIME_FORMAT
            ),
            gifticonStore: StoreType.from(string: gifticonStore) ?? .ALL,
            gifticonStoreCategory: StoreCategory(rawValue: gifticonStoreCategory) ?? .All
        )
    }
}
