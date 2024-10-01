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
    
    struct AuthTokenInfo: Decodable {
        let accessToken: String
        let refreshToken: String
        let accessTokenExpiresIn: Int
        let isFirstLogin: Bool
        
        func toModel() -> AuthToken {
            AuthToken(
                accessToken: accessToken,
                refreshToken: refreshToken,
                accessTokenExpiresIn: accessTokenExpiresIn,
                isFirstLogin: isFirstLogin
            )
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case tokenInfo = "body"
    }
}
