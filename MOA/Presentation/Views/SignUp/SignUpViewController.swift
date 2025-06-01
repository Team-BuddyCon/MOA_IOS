//
//  SignUpViewController.swift
//  MOA
//
//  Created by 오원석 on 10/1/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

protocol SignUpViewControllerDelegate: AnyObject {
    func navigateToTermsOfUse()
    func navigateToPrivacyPolicy()
    func navigateToSignUpComplete()
}

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
        let checkBox = SignUpCheckBox(text: SIGNUP_AGREE_TO_ALL)
        return checkBox
    }()
    
    private lazy var termsOfUseSignUpCheckBox: SignUpCheckBox = {
        let checkBox = SignUpCheckBox(text: SIGNUP_AGREE_TO_TERMS_OF_USE, hasMore: true)
        return checkBox
    }()
    
    private lazy var privacyPolicySignUpCheckBox: SignUpCheckBox = {
        let checkBox = SignUpCheckBox(text: SIGNUP_AGREE_TO_PRIVACY_POLICY, hasMore: true)
        return checkBox
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey30
        return view
    }()
    
    fileprivate let completeButton: CommonButton = {
        let button = CommonButton(title: SIGNUP_COMPLETE, fontName: pretendard_medium)
        return button
    }()
    
    weak var delegate: SignUpViewControllerDelegate?
    
    var signUpViewModel: SignUpViewModel
    
    init(signUpViewModel: SignUpViewModel) {
        self.signUpViewModel = signUpViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        bind()
    }
}

private extension SignUpViewController {
    func setupLayout() {
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
    
    func bind() {
        let input = SignUpViewModel.Input(
            allSignUpCheckBoxTapped: allSignUpCheckBox.rx.tap,
            termsOfUseSignUpCheckBoxTapped: termsOfUseSignUpCheckBox.rx.tap,
            termsOfUseSignUpDetailCheckBoxTapped: termsOfUseSignUpCheckBox.rx.detailTap,
            privacyPolicySignUpCheckBoxTapped: privacyPolicySignUpCheckBox.rx.tap,
            privacyPolicySignUpDetailCheckBoxTapped: privacyPolicySignUpCheckBox.rx.detailTap,
            completeButtonTapped: completeButton.rx.tap
        )
        
        let output = signUpViewModel.transform(input: input)
        
        output.changeAllSignUpCheckBox
            .drive(allSignUpCheckBox.isChecked)
            .disposed(by: disposeBag)
        
        output.changeTermsOfUseCheckBox
            .drive(termsOfUseSignUpCheckBox.isChecked)
            .disposed(by: disposeBag)
        
        output.changePrivacyPolicyCheckBox
            .drive(privacyPolicySignUpCheckBox.isChecked)
            .disposed(by: disposeBag)
        
        output.showTermsOfUseDetailWebView
            .emit(to: self.rx.showTermsOfUseDetailWebView)
            .disposed(by: disposeBag)
        
        output.showPrivacyPolicyWebView
            .emit(to: self.rx.showPrivacyPolicyDetailWebView)
            .disposed(by: disposeBag)
        
        output.changeCompleteStatus
            .drive(self.rx.changeCompletButtonStatus)
            .disposed(by: disposeBag)
        
        output.navigateSignUpComplete
            .emit(to: self.rx.navigateToSignUpComplete)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: SignUpViewController {
    var showTermsOfUseDetailWebView: Binder<Void> {
        return Binder(self.base) { viewController, _ in
            viewController.delegate?.navigateToTermsOfUse()
        }
    }
    
    var showPrivacyPolicyDetailWebView: Binder<Void> {
        return Binder(self.base) { viewController, _ in
            viewController.delegate?.navigateToPrivacyPolicy()
        }
    }
    
    var changeCompletButtonStatus: Binder<Bool> {
        return Binder(self.base) { viewController, isChecked in
            viewController.completeButton.status.accept(isChecked ? .active : .disabled)
        }
    }
    
    var navigateToSignUpComplete: Binder<Void> {
        return Binder(self.base) { viewController, _ in
            viewController.delegate?.navigateToSignUpComplete()
        }
    }
}
