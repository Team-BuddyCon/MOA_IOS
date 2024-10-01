//
//  AuthToken.swift
//  MOA
//
//  Created by 오원석 on 10/1/24.
//

import Foundation

struct AuthToken {
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresIn: Int
    let isFirstLogin: Bool
    
    init(accessToken: String = "",
         refreshToken: String = "",
         accessTokenExpiresIn: Int = 0,
         isFirstLogin: Bool = true
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessTokenExpiresIn = accessTokenExpiresIn
        self.isFirstLogin = isFirstLogin
    }
}
