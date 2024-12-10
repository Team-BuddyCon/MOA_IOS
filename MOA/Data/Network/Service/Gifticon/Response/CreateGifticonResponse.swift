//
//  CreateGifticonReseponse.swift
//  MOA
//
//  Created by 오원석 on 12/9/24.
//

struct CreateGifticonResponse: BaseResponse {
    var status: Int
    var message: String
    var id: Int
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case id = "body"
    }
}
