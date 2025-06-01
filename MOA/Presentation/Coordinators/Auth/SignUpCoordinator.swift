//
//  SignUpCoordinator.swift
//  MOA
//
//  Created by 오원석 on 5/7/25.
//

import UIKit

protocol SignUpCoordinatorDelegate: AnyObject {
    func navigateToHome()
}

class SignUpCoordinator: Coordinator, SignUpViewControllerDelegate, SignUpCompleteViewControllerDelegate {
    var childs: [Coordinator] = []
    
    private var navigationController: UINavigationController
    
    weak var delegate: SignUpCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        MOAContainer.shared.registerSignUpDependencies()
    }
    
    deinit {
        MOALogger.logd()
    }
    
    func start() {
        guard let signUpVC = MOAContainer.shared.resolve(SignUpViewController.self) else { return }
        signUpVC.delegate = self
        self.navigationController.pushViewController(signUpVC, animated: true)
    }
    
    // MARK: SignUpViewControllerDelegate
    func navigateToTermsOfUse() {
        guard let termsOfUseVC = MOAContainer.shared.resolve(SignUpWebViewController.self, arguments: SIGNUP_MOA_TERMS_OF_USE_TITLE, SERVICE_TERMS_URL) else { return }
        self.navigationController.pushViewController(termsOfUseVC, animated: true)
    }
    
    func navigateToPrivacyPolicy() {
        guard let privacyPolicyVC = MOAContainer.shared.resolve(SignUpWebViewController.self, arguments: SIGNUP_PRIVACY_POLICY_TITLE, PRIVACY_INFORMATION_URL) else { return }
        self.navigationController.pushViewController(privacyPolicyVC, animated: true)
    }
    
    func navigateToSignUpComplete() {
        guard let signUpCompleteVC = MOAContainer.shared.resolve(SignUpCompleteViewController.self) else { return }
        signUpCompleteVC.delegate = self
        signUpCompleteVC.modalPresentationStyle = .fullScreen
        signUpCompleteVC.modalTransitionStyle = .crossDissolve
        self.navigationController.present(signUpCompleteVC, animated: true)
    }
    
    // MARK: SignUpCompleteViewControllerDelegate
    func navigateToHome() {
        self.navigationController.dismiss(animated: true)
        self.delegate?.navigateToHome()
    }
}
