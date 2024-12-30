//
//  SearchPlaceByKeywordResponse.swift
//  MOA
//
//  Created by 오원석 on 12/30/24.
//

import Foundation

struct SearchPlaceByKeywordResponse: BaseResponse {
    var status: Int = 0
    var message: String = ""
    let places: [SearchPlaceInfo]
    
    enum CodingKeys: String, CodingKey {
        case places = "documents"
    }
}

struct SearchPlaceInfo: Decodable {
    let address_name: String
    let category_group_code: String
    let category_group_name: String
    let category_name: String
    let distance: String
    let id: String
    let phone: String
    let place_name: String
    let place_url: String
    let road_address_name: String
    let x: String
    let y: String
    
    func toModel() -> SearchPlace {
        SearchPlace(
            address_name: address_name,
            category_group_code: category_group_code,
            category_group_name: category_group_name,
            category_name: category_name,
            distance: distance,
            id: id,
            phone: phone,
            place_name: place_name,
            place_url: place_url,
            road_address_name: road_address_name,
            x: x,
            y: y
        )
    }
}
