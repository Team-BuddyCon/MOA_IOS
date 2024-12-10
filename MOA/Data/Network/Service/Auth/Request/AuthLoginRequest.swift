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
    var domain: HttpDomain { .MOA }
    
    var path: String { HttpPath.Auth.Login }
    
    var method: HttpMethod { .POST }
    
    var query: [String : String?]
    
    var body: [String : Any]
    
    var contentType: HttpContentType { .application_json }
    
    init(
        oauthAccessToken: String,
        nickname: String,
        email: String? = nil,
        gender: String? = nil,
        age: String? = nil
    ) {
        var body:[String: Any] = [:]
        body.updateValue(oauthAccessToken, forKey: HttpKeys.Auth.oauthAccessToken)
        body.updateValue(nickname, forKey: HttpKeys.Auth.nickname)
        if let email = email {
            body.updateValue(email, forKey: HttpKeys.Auth.email)
        }
        
        if let gender = gender {
            body.updateValue(gender, forKey: HttpKeys.Auth.gender)
        }
        
        if let age = age {
            body.updateValue(age, forKey: HttpKeys.Auth.age)
        }
        
        self.query = [:]
        self.body = body
    }
}
