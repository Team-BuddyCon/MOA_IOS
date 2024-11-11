//
//  AuthService.swift
//  MOA
//
//  Created by 오원석 on 9/29/24.
//

import Foundation
import RxSwift

protocol AuthServiceProtocol {
    func login(
        oauthAccessToken: String,
        nickname: String,
        email: String?,
        gender: String?,
        age: String?
    ) -> Observable<Result<AuthLoginResponse, URLError>>
}

final class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    private init() {}
    
    func login(
        oauthAccessToken: String,
        nickname: String,
        email: String?,
        gender: String?,
        age: String?
    ) -> Observable<Result<AuthLoginResponse, URLError>> {
        let request = AuthLoginRequest(
            oauthAccessToken: oauthAccessToken,
            nickname: nickname,
            email: email,
            gender: gender,
            age: age
        )
        
        return NetworkManager.shared.request(request: request)
    }
}
