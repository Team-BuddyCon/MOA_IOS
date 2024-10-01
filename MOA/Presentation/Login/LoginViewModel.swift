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

private let TEST_ACCESS_TOKEN = "eyJhbGciOiJIUzUxMiJ9.eyJpZCI6MSwiaWF0IjoxNzE3ODQ1MDAzLCJleHAiOjE3MjM4OTMwMDN9.wNxFHkYU7vyFIh5ErZem18_WUSDV8hdlINzcqOZdrzrplQpAaMj8ZDax6OpWzqmrftPTCV4z2sjT7Rz6SEFdRw"

final class LoginViewModel: BaseViewModel {
    private let authService: AuthServiceProtocol
    private let tokenInfoRelay = PublishRelay<AuthToken>()
    let tokenInfoDriver: Driver<AuthToken>
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        tokenInfoDriver = tokenInfoRelay.asDriver(onErrorJustReturn: AuthToken())
    }
    
    func loginBykakao() {
        if UserApi.isKakaoTalkLoginAvailable() {
            Observable.zip(UserApi.shared.rx.loginWithKakaoTalk(), UserApi.shared.rx.me().asObservable())
                .flatMap { [weak self] (oauthToken, user) -> Observable<Result<AuthLoginResponse, URLError>> in
                    guard let self = self else { return .just(.failure(URLError(.unknown))) }
                    return authService.login(
                        oauthAccessToken: oauthToken.accessToken,
                        nickname: user.kakaoAccount?.profile?.nickname ?? "",
                        email: nil,
                        gender: nil,
                        age: nil
                    )
                }.subscribe(
                    onNext: handleLoginResult(result:),
                    onError: { error in
                        print("loginWithKakakoTalk error \(error)")
                    }
                ).disposed(by: disposeBag)
        } else {
            Observable.zip(UserApi.shared.rx.loginWithKakaoAccount(), UserApi.shared.rx.me().asObservable())
                .flatMap { [weak self] (oauthToken, user) -> Observable<Result<AuthLoginResponse, URLError>> in
                    guard let self = self else { return .just(.failure(URLError(.unknown))) }
                    return authService.login(
                        oauthAccessToken: oauthToken.accessToken,
                        nickname: user.kakaoAccount?.profile?.nickname ?? "",
                        email: nil,
                        gender: nil,
                        age: nil
                    )
                }.subscribe(
                    onNext: handleLoginResult(result:),
                    onError: { error in
                        print("loginWithKakakoTalk error \(error)")
                    }
                ).disposed(by: disposeBag)
        }
    }
    
    func handleLoginResult(result: Result<AuthLoginResponse, URLError>) {
        switch result {
        case .success(let response):
            print("handleLoginResult success \(response)")
            break
        case .failure(let error):
            tokenInfoRelay.accept(
                AuthToken(
                    accessToken: TEST_ACCESS_TOKEN,
                    accessTokenExpiresIn: Date().add(offset: 7).timeInMills
                )
            )
            break
        }
    }
}
