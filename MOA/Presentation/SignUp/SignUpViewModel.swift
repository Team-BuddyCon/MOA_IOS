//
//  SignUpViewModel.swift
//  MOA
//
//  Created by 오원석 on 10/30/24.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

let TEST_ACCESS_TOKEN = "eyJhbGciOiJIUzUxMiJ9.eyJpZCI6MSwiaWF0IjoxNzE3ODQ1MDAzLCJleHAiOjE3MjM4OTMwMDN9.wNxFHkYU7vyFIh5ErZem18_WUSDV8hdlINzcqOZdrzrplQpAaMj8ZDax6OpWzqmrftPTCV4z2sjT7Rz6SEFdRw"

final class SignUpViewModel: BaseViewModel {
    private let authService: AuthServiceProtocol
    private let tokenInfoRelay = PublishRelay<AuthToken>()
    var tokenInfoDriver: Driver<AuthToken> {
        tokenInfoRelay.asDriver(onErrorJustReturn: AuthToken())
    }
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func signUp(acecssToken: String, name: String) {
        authService.login(
            oauthAccessToken: acecssToken,
            nickname: name,
            email: nil,
            gender: nil,
            age: nil
        ).subscribe(
            onNext: { [weak self] result in
                UserPreferences.setAccessToken(accessToken: acecssToken)
                UserPreferences.setLoginUserName(name: name)
                
                switch result {
                case .success(let response):
                    MOALogger.logi("\(response)")
                    self?.tokenInfoRelay.accept(
                        AuthToken(
                            accessToken: response.tokenInfo.accessToken,
                            refreshToken: response.tokenInfo.refreshToken,
                            accessTokenExpiresIn: response.tokenInfo.accessTokenExpiresIn,
                            isFirstLogin: response.tokenInfo.isFirstLogin
                        )
                    )
                case .failure(let error):
                    // TODO 500 에러 대비 방지
                    MOALogger.loge(error.localizedDescription)
                    self?.tokenInfoRelay.accept(
                        AuthToken(
                            accessToken: TEST_ACCESS_TOKEN,
                            accessTokenExpiresIn: Date().add(offset: 7).timeInMills
                        )
                    )
                }
            },
            onError: { error in
                MOALogger.loge("\(error)")
            }
        ).disposed(by: disposeBag)
    }
}
