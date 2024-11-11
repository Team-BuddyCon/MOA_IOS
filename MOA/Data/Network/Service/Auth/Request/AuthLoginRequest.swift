//
//  AuthLoginRequest.swift
//  MOA
//
//  Created by 오원석 on 9/29/24.
//

import Foundation

let AUTH_LOGIN_PATH = "/api/v1/auth/login"
let AUTH_LOGIN_OAUTH_ACCESS_TOKEN = "oauthAccessToken"
let AUTH_LOGIN_NICKNAME = "nickname"
let AUTH_LOGIN_EMAIL = "email"
let AUTH_LOGIN_GENDER = "gender"
let AUTH_LOGIN_AGE = "age"

final class AuthLoginRequest: BaseRequest {
    var domain: NetworkDomain { .MOA }
    
    var path: String { AUTH_LOGIN_PATH }
    
    var method: NetworkMethod { .POST }
    
    var query: [String : String?]
    
    var body: [String : Any]
    
    init(
        oauthAccessToken: String,
        nickname: String,
        email: String? = nil,
        gender: String? = nil,
        age: String? = nil
    ) {
        var body:[String: Any] = [:]
        body.updateValue(oauthAccessToken, forKey: AUTH_LOGIN_OAUTH_ACCESS_TOKEN)
        body.updateValue(nickname, forKey: AUTH_LOGIN_NICKNAME)
        
        if let email = email {
            body.updateValue(email, forKey: AUTH_LOGIN_EMAIL)
        }
        
        if let gender = gender {
            body.updateValue(gender, forKey: AUTH_LOGIN_GENDER)
        }
        
        if let age = age {
            body.updateValue(age, forKey: AUTH_LOGIN_AGE)
        }
        
        self.query = [:]
        self.body = body
    }
}
