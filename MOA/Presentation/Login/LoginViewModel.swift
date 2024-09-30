//
//  LoginViewModel.swift
//  MOA
//
//  Created by 오원석 on 9/28/24.
//

import Foundation
import RxSwift
import KakaoSDKUser
import KakaoSDKCommon
import KakaoSDKAuth
import RxKakaoSDKAuth
import RxKakaoSDKUser
import RxKakaoSDKCommon

final class LoginViewModel: BaseViewModel {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
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
                    onNext: { result in
                        print("loginWithKakakoTalk success \(result)")
                    },
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
                    onNext: { result in
                        print("loginWithKakakoTalk success \(result)")
                    },
                    onError: { error in
                        print("loginWithKakakoTalk error \(error)")
                    }
                ).disposed(by: disposeBag)
//            UserApi.shared.rx.loginWithKakaoAccount()
//                .subscribe(
//                    onNext: { oauthToken in
//                        print("loginWithKakaoAccount success \(oauthToken)")
//                    },
//                    onError: { error in
//                        print("loginWithKakaoAccount error \(error)")
//                    }
//                ).disposed(by: disposeBag)
        }
    }
}
