//
//  LoginViewModel.swift
//  MOA
//
//  Created by 오원석 on 9/28/24.
//

import Foundation
import KakaoSDKUser
import KakaoSDKCommon
import KakaoSDKAuth
import RxKakaoSDKAuth
import RxKakaoSDKUser
import RxKakaoSDKCommon

final class LoginViewModel: BaseViewModel {
    func loginBykakao() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.rx.loginWithKakaoTalk()
                .subscribe(
                    onNext: { oauthToken in
                        print("loginWithKakakoTalk success \(oauthToken)")
                    },
                    onError: { error in
                        print("loginWithKakakoTalk error \(error)")
                    }
                ).disposed(by: disposeBag)
        } else {
            UserApi.shared.rx.loginWithKakaoAccount()
                .subscribe(
                    onNext: { oauthToken in
                        print("loginWithKakaoAccount success \(oauthToken)")
                    },
                    onError: { error in
                        print("loginWithKakaoAccount error \(error)")
                    }
                ).disposed(by: disposeBag)
        }
    }
}
