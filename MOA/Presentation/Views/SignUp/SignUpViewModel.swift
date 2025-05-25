//
//  SignUpViewModel.swift
//  MOA
//
//  Created by 오원석 on 5/15/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

final class SignUpViewModel: BaseViewModel {
    struct Input {
        let allSignUpCheckBoxTapped: ControlEvent<Void>
        let termsOfUseSignUpCheckBoxTapped: ControlEvent<Void>
        let termsOfUseSignUpDetailCheckBoxTapped: ControlEvent<Void>
        let privacyPolicySignUpCheckBoxTapped: ControlEvent<Void>
        let privacyPolicySignUpDetailCheckBoxTapped: ControlEvent<Void>
        let completeButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let changeAllSignUpCheckBox: Driver<Bool>
        let changeTermsOfUseCheckBox: Driver<Bool>
        let showTermsOfUseDetailWebView: Signal<Void>
        let changePrivacyPolicyCheckBox: Driver<Bool>
        let showPrivacyPolicyWebView: Signal<Void>
        let changeCompleteStatus: Driver<Bool>
        let navigateSignUpComplete: Signal<Void>
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private let allSignUpCheckBoxRelay = BehaviorRelay(value: false)
    private let termsOfUseCheckBoxRelay = BehaviorRelay(value: false)
    private let privacyPolicyCheckBoxRelay = BehaviorRelay(value: false)
    private let completeStatusRelay = BehaviorRelay(value: false)
    
    func transform(input: Input) -> Output {
        input.allSignUpCheckBoxTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let isChecked = allSignUpCheckBoxRelay.value
                allSignUpCheckBoxRelay.accept(!isChecked)
                termsOfUseCheckBoxRelay.accept(!isChecked)
                privacyPolicyCheckBoxRelay.accept(!isChecked)
                completeStatusRelay.accept(!isChecked)
            }).disposed(by: disposeBag)
        
        input.termsOfUseSignUpCheckBoxTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let termsOfUseChecked = termsOfUseCheckBoxRelay.value
                let privacyPolicyChecked = privacyPolicyCheckBoxRelay.value
                termsOfUseCheckBoxRelay.accept(!termsOfUseChecked)
                allSignUpCheckBoxRelay.accept(!termsOfUseChecked && privacyPolicyChecked)
                completeStatusRelay.accept(!termsOfUseChecked && privacyPolicyChecked)
            }).disposed(by: disposeBag)
        
        input.privacyPolicySignUpCheckBoxTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let termsOfUseChecked = termsOfUseCheckBoxRelay.value
                let privacyPolicyChecked = privacyPolicyCheckBoxRelay.value
                privacyPolicyCheckBoxRelay.accept(!privacyPolicyChecked)
                allSignUpCheckBoxRelay.accept(termsOfUseChecked && !privacyPolicyChecked)
                completeStatusRelay.accept(termsOfUseChecked && !privacyPolicyChecked)
            }).disposed(by: disposeBag)
        
        return Output(
            changeAllSignUpCheckBox: allSignUpCheckBoxRelay.asDriver(),
            changeTermsOfUseCheckBox: termsOfUseCheckBoxRelay.asDriver(),
            showTermsOfUseDetailWebView: input.termsOfUseSignUpDetailCheckBoxTapped.asSignal(),
            changePrivacyPolicyCheckBox: privacyPolicyCheckBoxRelay.asDriver(),
            showPrivacyPolicyWebView: input.privacyPolicySignUpDetailCheckBoxTapped.asSignal(),
            changeCompleteStatus: completeStatusRelay.asDriver(),
            navigateSignUpComplete: input.completeButtonTapped.asSignal()
        )
    }
}
