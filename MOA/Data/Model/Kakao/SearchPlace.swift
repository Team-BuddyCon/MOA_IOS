//
//  SearchPlace.swift
//  MOA
//
//  Created by 오원석 on 12/30/24.
//

import Foundation

struct SearchPlace {
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
    
    init(address_name: String = "",
         category_group_code: String = "",
         category_group_name: String = "",
         category_name: String = "",
         distance: String = "",
         id: String = "",
         phone: String = "",
         place_name: String = "",
         place_url: String = "",
         road_address_name: String = "",
         x: String = "",
         y: String = ""
    ) {
        self.address_name = address_name
        self.category_group_code = category_group_code
        self.category_group_name = category_group_name
        self.category_name = category_name
        self.distance = distance
        self.id = id
        self.phone = phone
        self.place_name = place_name
        self.place_url = place_url
        self.road_address_name = road_address_name
        self.x = x
        self.y = y
    }
}
