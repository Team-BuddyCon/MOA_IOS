//
//  LoginViewController.swift
//  MOA
//
//  Created by 오원석 on 9/21/24.
//

import UIKit
import SnapKit

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
    
    let loginViewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupData()
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
    
    func setupData() {
        UserPreferences.setIsNeededShowLogin(isShow: true)
    }
}

private extension LoginViewController {
    @objc func tapKakaoLogin() {
        loginViewModel.loginBykakao()
    }
}
