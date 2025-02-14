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
    var gifticonInfos: AvailableGifticonInfos

    struct AvailableGifticonInfos: Decodable {
        let size: Int
        let content: [AvailableGifticonInfo]
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case gifticonInfos = "body"
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
    
    func toModel() -> GifticonModel {
        GifticonModel(
            gifticonId: String(gifticonId),
            imageUrl: imageUrl,
            name: name,
            memo: memo,
            expireDate: expireDate.transformTimeformat(
                origin: AVAILABLE_GIFTICON_RESPONSE_TIME_FORMAT,
                dest: AVAILABLE_GIFTICON_TIME_FORMAT
            ),
            gifticonStore: StoreType.from(string: gifticonStore) ?? .ALL,
            gifticonStoreCategory: StoreCategory(rawValue: gifticonStoreCategory) ?? .ALL
        )
    }
}
