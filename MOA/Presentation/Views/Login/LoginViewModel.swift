//
//  LoginViewModel.swift
//  MOA
//
//  Created by 오원석 on 9/28/24.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import KakaoSDKUser
import KakaoSDKCommon
import KakaoSDKAuth
import RxKakaoSDKAuth
import RxKakaoSDKUser
import RxKakaoSDKCommon

//private let TEST_ACCESS_TOKEN = "eyJhbGciOiJIUzUxMiJ9.eyJpZCI6MSwiaWF0IjoxNzE3ODQ1MDAzLCJleHAiOjE3MjM4OTMwMDN9.wNxFHkYU7vyFIh5ErZem18_WUSDV8hdlINzcqOZdrzrplQpAaMj8ZDax6OpWzqmrftPTCV4z2sjT7Rz6SEFdRw"

final class LoginViewModel: BaseViewModel {
    private let authService: AuthServiceProtocol
    private let tokenInfoRelay = PublishRelay<AuthToken>()
    var tokenInfoDriver: Driver<AuthToken> {
        tokenInfoRelay.asDriver(onErrorJustReturn: AuthToken())
    }
    
    private let kakaoAuthRelay = PublishRelay<KakaoAuth>()
    var kakaoAuthDriver: Driver<KakaoAuth> {
        kakaoAuthRelay.asDriver(onErrorJustReturn: KakaoAuth())
    }
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        AuthApi.shared.refreshToken(completion: {_,_ in })
    }
    
    func loginBykakao() {
        if UserApi.isKakaoTalkLoginAvailable() {
            loginByKakaoTalk()
        } else {
            loginByKakaoAccount()
        }
    }
    
    func loginByKakaoTalk() {
//        if UserPreferences.getAccessToken().isEmpty {
//            // loginWithKakaoTalk, me를 동시에 실행하면 Token authentication is nil 에러 발생
//            UserApi.shared.rx.loginWithKakaoTalk()
//                .flatMap { oauthToken in
//                    UserApi.shared.rx.me().asObservable().map { user in
//                        (oauthToken, user)
//                    }
//                }.subscribe(
//                    onNext: { [weak self] (oauthToken, user) in
//                        guard let self = self else {
//                            MOALogger.loge()
//                            return
//                        }
//                        
//                        kakaoAuthRelay.accept(
//                            KakaoAuth(
//                                accessToken: oauthToken.accessToken,
//                                profileName: user.kakaoAccount?.profile?.nickname ?? ""
//                            )
//                        )
//                    }
//                ).disposed(by: disposeBag)
//        } else {
//            UserApi.shared.rx.loginWithKakaoTalk()
//                .flatMap { oauthToken in
//                    UserApi.shared.rx.me().asObservable().map { user in
//                        (oauthToken, user)
//                    }
//                }.flatMap { [weak self] (oauthToken, user) -> Observable<Result<AuthLoginResponse, URLError>> in
//                    guard let self = self else {
//                        return .just(.failure(URLError(.unknown)))
//                    }
//                    
//                    return authService.login(
//                        oauthAccessToken: oauthToken.accessToken,
//                        nickname: user.kakaoAccount?.profile?.nickname ?? "",
//                        email: nil,
//                        gender: nil,
//                        age: nil
//                    )
//                }.subscribe(
//                    onNext: handleLoginResult(result:),
//                    onError: { [weak self] error in
//                        self?.handleLoginResult(result: .failure(URLError(URLError.cannotParseResponse)))
//                    }
//                ).disposed(by: disposeBag)
//        }
    }
    
    func loginByKakaoAccount() {
//        if UserPreferences.getAccessToken().isEmpty {
//            UserApi.shared.rx.loginWithKakaoAccount()
//                .flatMap { oauthToken in
//                    UserApi.shared.rx.me().asObservable().map { user in
//                        (oauthToken, user)
//                    }
//                }.subscribe(
//                    onNext: { [weak self] (oauthToken, user) in
//                        guard let self = self else {
//                            MOALogger.loge()
//                            return
//                        }
//                        
//                        kakaoAuthRelay.accept(
//                            KakaoAuth(
//                                accessToken: oauthToken.accessToken,
//                                profileName: user.kakaoAccount?.profile?.nickname ?? ""
//                            )
//                        )
//                    }
//                ).disposed(by: disposeBag)
//        } else {
//            UserApi.shared.rx.loginWithKakaoAccount()
//                .flatMap { oauthToken in
//                    UserApi.shared.rx.me().asObservable().map { user in
//                        (oauthToken, user)
//                    }
//                }.flatMap { [weak self] (oauthToken, user) -> Observable<Result<AuthLoginResponse, URLError>> in
//                    guard let self = self else {
//                        return .just(.failure(URLError(.unknown)))
//                    }
//                    
//                    return authService.login(
//                        oauthAccessToken: oauthToken.accessToken,
//                        nickname: user.kakaoAccount?.profile?.nickname ?? "",
//                        email: nil,
//                        gender: nil,
//                        age: nil
//                    )
//                }.subscribe(
//                    onNext: handleLoginResult(result:),
//                    onError: { [weak self] error in
//                        self?.handleLoginResult(result: .failure(URLError(URLError.cannotParseResponse)))
//                    }
//                ).disposed(by: disposeBag)
//        }
    }
    
    func handleLoginResult(result: Result<AuthLoginResponse, URLError>) {
        switch result {
        case .success(let response):
            MOALogger.logi("\(response)")
            tokenInfoRelay.accept(
                AuthToken(
                    accessToken: response.tokenInfo.accessToken,
                    refreshToken: response.tokenInfo.refreshToken,
                    accessTokenExpiresIn: response.tokenInfo.accessTokenExpiresIn,
                    isFirstLogin: response.tokenInfo.isFirstLogin
                )
            )
        case .failure(let error):
            MOALogger.loge(error.localizedDescription)
        }
    }
}
