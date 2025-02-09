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
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

final class LoginViewController: BaseViewController {
    
    private var isLogout: Bool = false
    private var isWithDraw: Bool = false
    
    private lazy var loginIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: LOGIN_ICON))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var googleLoginButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: GOOGLE_LOGIN_BUTTON), for: .normal)
        button.addTarget(self, action: #selector(tapGoogleLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var appleLoginButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: APPLE_LOGIN_BUTTON), for: .normal)
        button.addTarget(self, action: #selector(tapAppleLogin), for: .touchUpInside)
        return button
    }()
    
    init(
        isLogout: Bool = false,
        isWithDraw: Bool = false
    ) {
        self.isLogout = isLogout
        self.isWithDraw = isWithDraw
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        UserPreferences.setShouldEntryLogin()
        setupAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isLogout {
            showAlertModal(
                title: LOGOUT_POPUP_MESSAGE,
                confirmText: CONFIRM
            )
            isLogout = false
        }
        
        if isWithDraw {
            showAlertModal(
                title: WITHDRAW_POPUP_MESSAGE,
                confirmText: CONFIRM
            )
            isWithDraw = false
        }
    }
}

private extension LoginViewController {
    func setupAppearance() {
        view.backgroundColor = .white
        [loginIconImageView, googleLoginButton, appleLoginButton].forEach {
            view.addSubview($0)
        }
        
        loginIconImageView.snp.makeConstraints {
            $0.height.equalTo(118)
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        googleLoginButton.snp.makeConstraints {
            $0.height.equalTo(54)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(appleLoginButton.snp.top).offset(-16)
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.height.equalTo(54)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
        }
    }
}

private extension LoginViewController {
    @objc func tapGoogleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.restorePreviousSignIn(completion: { user, error in
            // 로그인 세션 없는 경우, 로그인 시도
            if let error = error {
                MOALogger.loge("restorePreviousSignIn error: \(String(describing: error))")
                
                GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
                    guard error == nil else {
                        MOALogger.loge("signIn error: \(String(describing: error))")
                        return
                    }
                    
                    guard let user = result?.user,
                          let idToken = user.idToken?.tokenString else {
                        MOALogger.loge()
                        return
                    }
                    
                    let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                    Auth.auth().signIn(with: credential) { result, error in
                        guard error == nil else {
                            MOALogger.loge(error?.localizedDescription)
                            return
                        }
                        
                        if let result = result {
                            if UserPreferences.isSignUp() {
                                UIApplication.shared.navigationHome()
                            } else {
                                UserPreferences.setLoginUserName(name: result.user.displayName ?? USER_NAME)
                                UserPreferences.setUserID(userID: result.user.uid)
                                self.navigationController?.pushViewController(SignUpViewController(), animated: true)
                            }
                        }
                    }
                }
            } else {
                guard let user = user,
                      let idToken = user.idToken?.tokenString else {
                    MOALogger.loge()
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                Auth.auth().signIn(with: credential) { result, error in
                    guard error == nil else {
                        MOALogger.loge(error?.localizedDescription)
                        return
                    }
                    
                    if let result = result {
                        UserPreferences.setLoginUserName(name: result.user.displayName ?? USER_NAME)
                        UserPreferences.setUserID(userID: result.user.uid)
                        UIApplication.shared.navigationHome()
                    }
                }
            }
        })
    }
    
    @objc func tapAppleLogin() {
        
    }
}
