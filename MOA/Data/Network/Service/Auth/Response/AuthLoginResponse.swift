//
//  AuthLoginResponse.swift
//  MOA
//
//  Created by 오원석 on 9/29/24.
//

import Foundation

struct AuthLoginResponse: BaseResponse {
    var status: Int
    var message: String
    let tokenInfo: AuthTokenInfo
    
    class AuthTokenInfo: Decodable {
        let accessToken: String
        let refreshToken: String
        let accessTokenExpiresIn: Int
        let isFirstLogin: Bool
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case tokenInfo = "body"
    }
}
