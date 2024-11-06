//
//  LoginViewController.swift
//  MOA
//
//  Created by 오원석 on 9/21/24.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

final class LoginViewController: BaseViewController {
    
    private lazy var loginIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: LOGIN_ICON))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var kakaoLoginButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: KAKAO_LOGIN_BUTTON_IMAGES), for: .normal)
        button.addTarget(self, action: #selector(tapKakaoLogin), for: .touchUpInside)
        return button
    }()
    
    private  let loginViewModel = LoginViewModel(authService: AuthService.shared)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        UserPreferences.setShouldEntryLogin()
        setupAppearance()
        subscribeViewModel()
    }
}

private extension LoginViewController {
    func setupAppearance() {
        view.backgroundColor = .white
        [loginIconImageView, kakaoLoginButton].forEach {
            view.addSubview($0)
        }
        
        loginIconImageView.snp.makeConstraints {
            $0.height.equalTo(118)
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        kakaoLoginButton.snp.makeConstraints {
            $0.height.equalTo(54)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
        }
    }
    
    func subscribeViewModel() {
        loginViewModel.tokenInfoDriver
            .drive { token in
                MOALogger.logi("\(token)")
                UIApplication.shared.navigationHome()
            }.disposed(by: disposeBag)
        
        loginViewModel.kakaoAuthDriver
            .drive { kakaoAuth in
                MOALogger.logi("\(kakaoAuth)")
                self.navigationController?.pushViewController(SignUpViewController(kakaoAuth: kakaoAuth), animated: true)
            }.disposed(by: disposeBag)
    }
}

private extension LoginViewController {
    @objc func tapKakaoLogin() {
        MOALogger.logd()
        UIApplication.shared.navigationHome()
        //loginViewModel.loginBykakao()
    }
}
