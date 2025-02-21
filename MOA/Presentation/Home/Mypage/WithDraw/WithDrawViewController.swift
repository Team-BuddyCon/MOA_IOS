//
//  WithDrawViewController.swift
//  MOA
//
//  Created by 오원석 on 2/1/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseAnalytics
import FirebaseStorage
import FirebaseFirestore
import AuthenticationServices

enum WithDrawPhrase {
    case Reason
    case ReasonDetail
    case Notice
}

enum WithDrawReason: String, CaseIterable {
    case NotUseApp = "쓰지 않는 앱이에요"
    case Error = "오류가 생겨서 쓸 수 없어요"
    case NotKnowHowtoUse = "앱 사용법을 모르겠어요"
    case Etc = "기타"
}

final class WithDrawViewController: BaseViewController {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.setTextWithLineHeight(
            text: MOA_WITH_DRAW_REASON_TITLE,
            font: pretendard_bold,
            size: 22.0,
            lineSpacing: 30.8,
            alignment: .left
        )
        label.textColor = .grey90
        label.numberOfLines = 2
        return label
    }()
    
    lazy var reasonStackView: UIStackView = {
        var subViews: [SelectCheckButton] = []
        for reason in WithDrawReason.allCases {
            let view = SelectCheckButton(title: reason.rawValue)
            view.tapGesture.rx.event
                .subscribe(onNext: { [weak self] _ in
                    self?.withDrawViewModel.reason.accept(reason)
                }).disposed(by: disposeBag)
            subViews.append(view)
        }
        
        let stackView = UIStackView(arrangedSubviews: subViews)
        stackView.axis = .vertical
        stackView.subviews.forEach { subview in
            subview.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(45)
            }
        }
        return stackView
    }()
    
    let confirmButton: CommonButton = {
        let button = CommonButton(title: NEXT)
        return button
    }()
    
    lazy var reasonView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey10
        view.layer.cornerRadius = 16
        return view
    }()
    
    lazy var reasonTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: pretendard_regular, size: 15.0)
        textField.textColor = .grey40
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.placeholder = MOA_WITH_DRAW_REASON_PLACEHOLDER_TEXT
        textField.delegate = self
        return textField
    }()
    
    lazy var noticeDot1: UIView = {
        let view = UIView()
        view.backgroundColor = .grey60
        view.layer.cornerRadius = 2
        return view
    }()
    
    lazy var noticeDot2: UIView = {
        let view = UIView()
        view.backgroundColor = .grey60
        view.layer.cornerRadius = 2
        return view
    }()
    
    lazy var noticeLabel1: UILabel = {
        let label = UILabel()
        label.textColor = .grey60
        label.numberOfLines = 2
        label.setTextWithLineHeight(
            text: String(format: MOA_WITH_DRAW_NOTICE_MESSAGE1_FORMAT, UserPreferences.getLoginUserName()),
            font: pretendard_regular,
            size: 15.0,
            lineSpacing: 21,
            alignment: .left
        )
        return label
    }()
    
    lazy var noticeLabel2: UILabel = {
        let label = UILabel()
        label.textColor = .grey60
        label.numberOfLines = 2
        label.setTextWithLineHeight(
            text: MOA_WITH_DRAW_NOTICE_MESSAGE2,
            font: pretendard_regular,
            size: 15.0,
            lineSpacing: 21,
            alignment: .left
        )
        return label
    }()
    
    let storage = Storage.storage()
    let store = Firestore.firestore()
    fileprivate var currentNonce: String?
    let withDrawViewModel = WithDrawViewModel(gifticonService: GifticonService.shared)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupNavigationBar()
        setupLayout()
        bind()
    }
}

private extension WithDrawViewController {
    func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        let backButtonItem = UIBarButtonItem(
            image: UIImage(named: BACK_BUTTON_IMAGE_ASSET),
            style: .plain,
            target: self,
            action: #selector(tapBackBarButton)
        )
        backButtonItem.tintColor = .grey90
        navigationItem.leftBarButtonItem = backButtonItem
        
        let label = UILabel()
        label.text = title
        label.font = UIFont(name: pretendard_bold, size: 15.0)
        label.textColor = .grey90
        navigationItem.titleView = label
    }
    
    func setupLayout() {
        [
            titleLabel,
            reasonStackView,
            confirmButton,
            reasonView,
            reasonTextField,
            noticeLabel1,
            noticeLabel2,
            noticeDot1,
            noticeDot2
        ].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        reasonStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(54)
        }
        
        reasonView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(reasonView.snp.width).multipliedBy(300 / 335.0)
        }
        
        reasonTextField.snp.makeConstraints {
            $0.top.equalTo(reasonView.snp.top).inset(16)
            $0.horizontalEdges.equalTo(reasonView).inset(16)
        }
        
        noticeLabel1.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.trailing.equalToSuperview().inset(20)
            $0.leading.equalTo(noticeDot1.snp.trailing).offset(8)
        }
        
        noticeLabel2.snp.makeConstraints {
            $0.top.equalTo(noticeLabel1.snp.bottom).offset(12)
            $0.trailing.equalToSuperview().inset(20)
            $0.leading.equalTo(noticeDot2.snp.trailing).offset(8)
        }
        
        noticeDot1.snp.makeConstraints {
            $0.top.equalTo(noticeLabel1.snp.top).inset(8)
            $0.leading.equalToSuperview().inset(28)
            $0.size.equalTo(4)
        }
        
        noticeDot2.snp.makeConstraints {
            $0.top.equalTo(noticeLabel2.snp.top).inset(8)
            $0.leading.equalToSuperview().inset(28)
            $0.size.equalTo(4)
        }
    }
    
    func bind() {
        withDrawViewModel.phrase
            .bind(to: self.rx.bindToPhrase)
            .disposed(by: disposeBag)
        
        withDrawViewModel.reason
            .bind(to: self.rx.bindToReason)
            .disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .bind(to: self.rx.bindToConfirmButton)
            .disposed(by: disposeBag)
        
        withDrawViewModel.logoutTrigger
            .bind(to: self.rx.bindToLogoutEvent)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: WithDrawViewController {
    var bindToPhrase: Binder<WithDrawPhrase> {
        return Binder<WithDrawPhrase>(self.base) { viewController, phrase in
            switch phrase {
            case .Reason:
                viewController.titleLabel.text = MOA_WITH_DRAW_REASON_TITLE
                viewController.reasonStackView.isHidden = false
                viewController.reasonView.isHidden = true
                viewController.reasonTextField.isHidden = true
                viewController.noticeLabel1.isHidden = true
                viewController.noticeLabel2.isHidden = true
                viewController.noticeDot1.isHidden = true
                viewController.noticeDot2.isHidden = true
            case .ReasonDetail:
                viewController.titleLabel.text = MOA_WITH_DRAW_RASEON_DETAIL_TITLE
                viewController.reasonStackView.isHidden = true
                viewController.reasonView.isHidden = false
                viewController.reasonTextField.isHidden = false
                viewController.noticeLabel1.isHidden = true
                viewController.noticeLabel2.isHidden = true
                viewController.noticeDot1.isHidden = true
                viewController.noticeDot2.isHidden = true
            case .Notice:
                viewController.titleLabel.text = String(format: MOA_WITH_DRAW_NOTICE_TITLE_FORMAT, UserPreferences.getLoginUserName())
                viewController.reasonStackView.isHidden = true
                viewController.reasonView.isHidden = true
                viewController.reasonTextField.isHidden = true
                viewController.noticeLabel1.isHidden = false
                viewController.noticeLabel2.isHidden = false
                viewController.noticeDot1.isHidden = false
                viewController.noticeDot2.isHidden = false
            }
        }
    }
    
    var bindToConfirmButton: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            let phrase = viewController.withDrawViewModel.phrase.value
            switch phrase {
            case .Reason:
                let reason = viewController.withDrawViewModel.reason.value
                viewController.withDrawViewModel.phrase.accept(reason == .Etc ? .ReasonDetail : .Notice)
            case .ReasonDetail:
                viewController.withDrawViewModel.phrase.accept(.Notice)
            case .Notice:
                viewController.showSelectModal(
                    title: MOA_WITH_DRAW_POPUP_TITLE,
                    subTitle: MOA_WITH_DRAW_POPUP_SUBTITLE,
                    confirmText: WITHDRAW,
                    cancelText: MOA_WITH_DRAW_POPUP_CANCEL
                ) {
                    if UserPreferences.getOAuthService() == OAuthService.Google.rawValue {
                        viewController.logOutByGoogle()
                    } else {
                        viewController.logOutByApple()
                    }
                }
            }
        }
    }
    
    var bindToReason: Binder<WithDrawReason> {
        return Binder<WithDrawReason>(self.base) { viewController, reason in
            for (index, view) in viewController.reasonStackView.arrangedSubviews.enumerated() {
                if let button = view as? SelectCheckButton {
                    button.isSelect = WithDrawReason.allCases[index] == reason
                }
            }
        }
    }
    
    var bindToLogoutEvent: Binder<Bool> {
        return Binder<Bool>(self.base) { viewController, isSuccess in
            //viewController.dismiss(animated: false)
            if isSuccess {
                do {
                    UserPreferences.setSignUp(sign: false)
                    let auth = Auth.auth()
                    try auth.signOut()
                    UIApplication.shared.setRootViewController(viewController: LoginViewController(isWithDraw: true))
                } catch {
                    viewController.logoutFail()
                }
            } else {
                viewController.logoutFail()
            }
        }
    }
}

extension WithDrawViewController {
    func logOutByGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.restorePreviousSignIn(completion: { user, error in
            guard error == nil else {
                MOALogger.loge("restorePreviousSignIn error: \(String(describing: error))")
                return
            }
            
            guard let user = user,
                  let idToken = user.idToken?.tokenString else {
                MOALogger.loge()
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            let currentUser = Auth.auth().currentUser
            currentUser?.reauthenticate(with: credential) { result, error in
                self.logOutSuccess(result: result, error: error)
            }
        })
    }
    
    func logOutByApple() {
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
    
    func logOutSuccess(result: AuthDataResult?, error: Error?) {
        let currentUser = Auth.auth().currentUser
        let auth = Auth.auth()
        
        guard error == nil else {
            MOALogger.loge("user reauthenticate \(String(describing: error))")
            return
        }
        
        currentUser?.delete { error in
            guard error == nil else {
                MOALogger.loge("user delete \(String(describing: error))")
                self.logoutFail()
                return
            }
            
            let reason = self.withDrawViewModel.reason.value.rawValue + (self.withDrawViewModel.reason.value == .Etc ? "(\(String(describing: self.reasonTextField.text)))" : "")
            Analytics.logEvent(
                FirebaseLogEvent.withDraw.rawValue,
                parameters: [
                    FirebaseLogParameter.withDrawReason.rawValue : reason
                ]
            )
            
            if UserPreferences.getOAuthService() == OAuthService.Google.rawValue {
                GIDSignIn.sharedInstance.signOut()
            }
            
            self.withDrawViewModel.deleteGifticons()
//            let loadingVC = RegisterLoadingViewController()
//            self.present(loadingVC, animated: false)
        }
    }
    
    func logoutFail() {
        self.showAlertModal(
            title: GIFTICON_REGISTER_ERROR_POPUP_TITLE,
            subTitle: GIFTICON_REGISTER_ERROR_POPUP_SUBTITLE,
            confirmText: CONFIRM
        )
    }
}

extension WithDrawViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            MOALogger.loge("Unable to retrieve AppleIDCredential")
            logoutFail()
            return
        }
        
        guard let nonce = currentNonce else {
            logoutFail()
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            MOALogger.logd("Unable to fetch identity token")
            logoutFail()
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            MOALogger.loge("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            logoutFail()
            return
        }
 
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        
        let currentUser = Auth.auth().currentUser
        currentUser?.reauthenticate(with: credential) { result, error in
            self.logOutSuccess(result: result, error: error)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        MOALogger.loge(error.localizedDescription)
        self.logoutFail()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        MOALogger.logd()
        return self.view.window!
    }
}

extension WithDrawViewController {
    @objc func tapBackBarButton() {
        let phrase = withDrawViewModel.phrase.value
        let reason = withDrawViewModel.reason.value
        
        switch phrase {
        case .Reason:
            navigationController?.popViewController(animated: true)
        case .ReasonDetail:
            withDrawViewModel.phrase.accept(.Reason)
            reasonTextField.resignFirstResponder()
        case .Notice:
            withDrawViewModel.phrase.accept(reason == .Etc ? .ReasonDetail : .Reason)
        }
    }
}

extension WithDrawViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        reasonTextField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let text = (currentText as NSString).replacingCharacters(in: range, with: string)
        return text.count <= 200
    }
}
