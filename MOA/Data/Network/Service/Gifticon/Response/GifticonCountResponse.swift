//
//  GifticonCountResponse.swift
//  MOA
//
//  Created by 오원석 on 1/10/25.
//

import Foundation

struct GifticonCountResponse: BaseResponse {
    var status: Int
    var message: String
    private var body: GifticonCountBody
    var count: Int { body.count }
    
    struct GifticonCountBody: Decodable {
        var count: Int
    }
}
