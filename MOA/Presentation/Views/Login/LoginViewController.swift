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
import AuthenticationServices

protocol LoginViewControllerDelegate: AnyObject {
    func loginInSuccess(isNewUser: Bool)
}

final class LoginViewController: BaseViewController {
    
    private var isLogout: Bool = false
    private var isWithDraw: Bool = false
    
    private lazy var loginIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: LOGIN_ICON))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let googleLoginButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: GOOGLE_LOGIN_BUTTON), for: .normal)
        return button
    }()
    
    private let appleLoginButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: APPLE_LOGIN_BUTTON), for: .normal)
        return button
    }()
    
    fileprivate var currentNonce: String?
    weak var delegate: LoginViewControllerDelegate?
    
    private let successLoginRelay = PublishRelay<(AuthDataResult, OAuthService)>()
    private let errorLoginRelay = PublishRelay<Void>()
    let loginViewModel: LoginViewModel
    
    init(
        loginViewModel: LoginViewModel,
        isLogout: Bool = false,
        isWithDraw: Bool = false
    ) {
        self.loginViewModel = loginViewModel
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
        
        setupLayout()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UserPreferences.setShowLogin(isShow: true)
        
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
    func setupLayout() {
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
    
    func bind() {
        let input = LoginViewModel.Input(
            successLogin: successLoginRelay.asSignal(),
            errorLogin: errorLoginRelay.asSignal()
        )
        
        let output = loginViewModel.transform(input: input)
        
        output.loginIn
            .emit(to: self.rx.loginIn)
            .disposed(by: disposeBag)
        
        output.showErrorPopup
            .emit(to: self.rx.showErrorPopup)
            .disposed(by: disposeBag)
        
        googleLoginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.googleLogin()
            }).disposed(by: disposeBag)
        
        appleLoginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.appleLogin()
            }).disposed(by: disposeBag)
    }
    
    func googleLogin() {
        MOALogger.logd()
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.restorePreviousSignIn(completion: { user, error in
            // 로그인 세션 없는 경우
            if let error = error {
                MOALogger.loge("GIDSignIn restorePreviousSignIn error: \(error.localizedDescription)")
                
                GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
                    guard error == nil else {
                        MOALogger.loge("GIDSignIn signIn error: \(String(describing: error))")
                        self.errorLoginRelay.accept(Void())
                        return
                    }
                    
                    guard let user = result?.user,
                          let idToken = user.idToken?.tokenString else {
                        self.errorLoginRelay.accept(Void())
                        return
                    }
                    
                    let credential = GoogleAuthProvider.credential(
                        withIDToken: idToken,
                        accessToken: user.accessToken.tokenString
                    )
                    
                    Auth.auth().signIn(with: credential) { result, error in
                        guard error == nil else {
                            MOALogger.loge("Auth signIn error: \(String(describing: error))")
                            self.errorLoginRelay.accept(Void())
                            return
                        }
                        
                        if let result = result {
                            self.successLoginRelay.accept((result, OAuthService.Google))
                        }
                    }
                }
            } else {
                guard let user = user,
                      let idToken = user.idToken?.tokenString else {
                    MOALogger.loge()
                    self.errorLoginRelay.accept(Void())
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                Auth.auth().signIn(with: credential) { result, error in
                    guard error == nil else {
                        MOALogger.loge(error?.localizedDescription)
                        self.errorLoginRelay.accept(Void())
                        return
                    }
                    
                    if let result = result {
                        self.successLoginRelay.accept((result, OAuthService.Google))
                    }
                }
            }
        })
    }
    
    func appleLogin() {
        MOALogger.logd()
        let nonce = CryptoUtils.randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = CryptoUtils.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension Reactive where Base: LoginViewController {
    var showErrorPopup: Binder<Void> {
        return Binder(self.base) { viewController, _ in
            viewController.showAlertModal(
                title: GIFTICON_REGISTER_ERROR_POPUP_TITLE,
                subTitle: GIFTICON_REGISTER_ERROR_POPUP_SUBTITLE,
                confirmText: CONFIRM
            )
        }
    }
    
    var loginIn: Binder<Bool> {
        return Binder(self.base) { viewController, newUser in
            viewController.delegate?.loginInSuccess(isNewUser: newUser)
        }
    }
}

// 애플 로그인 인증과정(성공/실패) 처리하는 프로토콜
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        MOALogger.logd()
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = self.currentNonce else {
                MOALogger.loge("Invalid state: A login callback was received, but no login request was sent.")
                self.errorLoginRelay.accept(Void())
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                MOALogger.logd("Unable to fetch identity token")
                self.errorLoginRelay.accept(Void())
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                MOALogger.loge("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                self.errorLoginRelay.accept(Void())
                return
            }
            
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            
            Auth.auth().signIn(with: credential) { result, error in
                guard error == nil else {
                    MOALogger.loge("Auth signIn error: \(String(describing: error))")
                    self.errorLoginRelay.accept(Void())
                    return
                }
                
                if let result = result {
                    self.successLoginRelay.accept((result, OAuthService.Apple))
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        MOALogger.loge(error.localizedDescription)
        self.errorLoginRelay.accept(Void())
    }
}

// Apple 로그인을 어떤 창 위에 표시할지 명시하는 프로토콜
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        MOALogger.logd()
        return self.view.window!
    }
}
