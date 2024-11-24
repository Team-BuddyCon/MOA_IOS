//
//  SignUpViewController.swift
//  MOA
//
//  Created by 오원석 on 10/1/24.
//

import UIKit
import SnapKit
import RxSwift

final class SignUpViewController: BaseViewController {
    
    private let titleLable: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.setTextWithLineHeight(
            text: SIGNUP_TERMS_GUIDE_TITLE,
            font: pretendard_bold,
            size: 22.0,
            lineSpacing: 30.8
        )
        label.textAlignment = .left
        return label
    }()
    
    private lazy var allSignUpCheckBox: SignUpCheckBox = {
        let checkBox = SignUpCheckBox(frame: .zero,text: SIGNUP_AGREE_TO_ALL)
        return checkBox
    }()
    
    private lazy var termsOfUseSignUpCheckBox: SignUpCheckBox = {
        let checkBox = SignUpCheckBox(frame: .zero,text: SIGNUP_AGREE_TO_TERMS_OF_USE, hasMore: true) {
            let vc = SignUpWebViewController(title: SIGNUP_MOA_TERMS_OF_USE_TITLE, url: SIGNUP_SERVICE_TERMS_URL)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return checkBox
    }()
    
    private lazy var privacyPolicySignUpCheckBox: SignUpCheckBox = {
        let checkBox = SignUpCheckBox(frame: .zero,text: SIGNUP_AGREE_TO_PRIVACY_POLICY, hasMore: true) {
            let vc = SignUpWebViewController(title: SIGNUP_PRIVACY_POLICY_TITLE, url: SIGNUP_PRIVACY_INFORMATION_URL)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return checkBox
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey30
        return view
    }()
    
    private lazy var completeButton: CommonButton = {
        let button = CommonButton(title: SIGNUP_COMPLETE, fontName: pretendard_medium)
        button.addTarget(self, action: #selector(tapCompletButton), for: .touchUpInside)
        return button
    }()
    
    private let kakaoAuth: KakaoAuth
    private let signUpViewModel = SignUpViewModel(authService: AuthService.shared)
    
    init(kakaoAuth: KakaoAuth) {
        self.kakaoAuth = kakaoAuth
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupAppearance()
        subscribe()
    }
}

private extension SignUpViewController {
    func setupAppearance() {
        setupTopBarWithBackButton(title: SIGNUP_TITLE)
        [
            titleLable,
            allSignUpCheckBox,
            termsOfUseSignUpCheckBox,
            privacyPolicySignUpCheckBox,
            dividerView,
            completeButton
        ].forEach {
            view.addSubview($0)
        }
        
        titleLable.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        allSignUpCheckBox.snp.makeConstraints {
            $0.top.equalTo(titleLable.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(24)
        }
        
        dividerView.snp.makeConstraints {
            $0.top.equalTo(allSignUpCheckBox.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        termsOfUseSignUpCheckBox.snp.makeConstraints {
            $0.top.equalTo(dividerView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(24)
        }
        
        privacyPolicySignUpCheckBox.snp.makeConstraints {
            $0.top.equalTo(termsOfUseSignUpCheckBox.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(24)
        }
        
        completeButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
            $0.height.equalTo(54)
        }
    }
    
    func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        let backButtonItem = UIBarButtonItem(
            image: UIImage(named: BACK_BUTTON_IMAGE_ASSET),
            style: .plain,
            target: self,
            action: #selector(tapBackButton)
        )
        backButtonItem.tintColor = .grey90
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.title = SIGNUP_TITLE
    }
    
    func subscribe() {
        allSignUpCheckBox.tap
            .subscribe(
                onNext: { [weak self] _ in
                    guard let self = self else { return }
                    let check = allSignUpCheckBox.isChecked.value
                    allSignUpCheckBox.isChecked.accept(!check)
                    termsOfUseSignUpCheckBox.isChecked.accept(!check)
                    privacyPolicySignUpCheckBox.isChecked.accept(!check)
                }
            ).disposed(by: disposeBag)
            
        termsOfUseSignUpCheckBox.tap
            .subscribe(
                onNext: { [weak self] _ in
                    guard let self = self else { return }
                    let termsOfUseCheck = termsOfUseSignUpCheckBox.isChecked.value
                    let privacyPolicyCheck = privacyPolicySignUpCheckBox.isChecked.value
                    termsOfUseSignUpCheckBox.isChecked.accept(!termsOfUseCheck)
                    allSignUpCheckBox.isChecked.accept(!termsOfUseCheck && privacyPolicyCheck)
                }
            ).disposed(by: disposeBag)
        
        privacyPolicySignUpCheckBox.tap
            .subscribe(
                onNext: { [weak self] _ in
                    guard let self = self else { return }
                    let termsOfUseCheck = termsOfUseSignUpCheckBox.isChecked.value
                    let privacyPolicyCheck = privacyPolicySignUpCheckBox.isChecked.value
                    privacyPolicySignUpCheckBox.isChecked.accept(!privacyPolicyCheck)
                    allSignUpCheckBox.isChecked.accept(termsOfUseCheck && !privacyPolicyCheck)
                }
            ).disposed(by: disposeBag)
        
        allSignUpCheckBox.isChecked
            .asDriver()
            .drive { [weak self] check in
                guard let self = self else { return }
                completeButton.status.accept(check ? .active : .disabled)
            }.disposed(by: disposeBag)
        
        signUpViewModel.tokenInfoDriver
            .drive { [weak self] token in
                let userName = UserPreferences.getLoginUserName()
                let viewController = SignUpCompleteViewController(name: userName)
                viewController.modalPresentationStyle = .fullScreen
                viewController.modalTransitionStyle = .crossDissolve
                self?.present(viewController, animated: true)
            }.disposed(by: disposeBag)
    }
}

private extension SignUpViewController {
    @objc func tapCompletButton() {
        signUpViewModel.signUp(
            acecssToken: kakaoAuth.accessToken,
            name: kakaoAuth.profileName
        )
    }
}
