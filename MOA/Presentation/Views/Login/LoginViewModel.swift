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
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices

final class LoginViewModel: BaseViewModel {
    struct Input {
        let successLogin: Signal<(AuthDataResult, OAuthService)>
        let errorLogin: Signal<Void>
    }
    
    struct Output {
        let loginIn: Signal<Bool>
        let showErrorPopup: Signal<Void>
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private let loginInByNewUserRelay = PublishRelay<Bool>()
    
    func transform(input: Input) -> Output {
        input.successLogin
            .emit(onNext: { [weak self] result, oauth in
                guard let self = self else { return }
                UserPreferences.setOAuthService(service: oauth.rawValue)
                UserPreferences.setLoginUserName(name: result.user.displayName ?? USER_NAME)
                UserPreferences.setUserID(userID: result.user.uid)
                loginInByNewUserRelay.accept(result.additionalUserInfo?.newUser() == true)
            }).disposed(by: disposeBag)
        
        return Output(
            loginIn: loginInByNewUserRelay.asSignal(),
            showErrorPopup: input.errorLogin
        )
    }
}
