//
//  AvailableGifticonResponse.swift
//  MOA
//
//  Created by 오원석 on 11/11/24.
//

import Foundation

struct AvailableGifticonResponse: BaseResponse {
    var status: Int
    var message: String
    
    private var body: Body
    var gifticonInfo: AvailableGifticonInfo {
        body.content
    }

    private struct Body: Decodable {
        let size: Int
        let content: AvailableGifticonInfo
    }
}

struct AvailableGifticonInfo: Decodable {
    let gifticonId: Int
    let imageUrl: String
    let name: String
    let memo: String
    let expireDate: String
    let gifticonStore: String
    let gifticonStoreCategory: String
    
    func toModel() -> AvailableGifticon {
        AvailableGifticon(
            gifticonId: gifticonId,
            imageUrl: imageUrl,
            name: name,
            memo: memo,
            expireDate: expireDate.transformTimeformat(
                origin: AVAILABLE_GIFTICON_RESPONSE_TIME_FORMAT,
                dest: AVAILABLE_GIFTICON_UI_TIME_FORMAT
            ),
            gifticonStore: StoreType(rawValue: gifticonStore) ?? .ALL,
            gifticonStoreCategory: StoreCategory(rawValue: gifticonStoreCategory) ?? .All
        )
    }
}
