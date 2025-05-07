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
    }
    
    func start() {
        let signUpVC = SignUpViewController()
        signUpVC.delegate = self
        self.navigationController.pushViewController(signUpVC, animated: true)
    }
    
    // MARK: SignUpViewControllerDelegate
    func navigateToTermsOfUse() {
        let termsOfUseVC = SignUpWebViewController(title: SIGNUP_MOA_TERMS_OF_USE_TITLE, url: SERVICE_TERMS_URL)
        self.navigationController.pushViewController(termsOfUseVC, animated: true)
    }
    
    func navigateToPrivacyPolicy() {
        let privacyPolicyVC = SignUpWebViewController(title: SIGNUP_PRIVACY_POLICY_TITLE, url: PRIVACY_INFORMATION_URL)
        self.navigationController.pushViewController(privacyPolicyVC, animated: true)
    }
    
    func navigateToSignUpComplete() {
        let signUpCompleteVC = SignUpCompleteViewController()
        signUpCompleteVC.modalPresentationStyle = .fullScreen
        signUpCompleteVC.modalTransitionStyle = .crossDissolve
        self.navigationController.present(signUpCompleteVC, animated: true)
    }
    
    // MARK: SignUpCompleteViewControllerDelegate
    func navigateToHome() {
        self.delegate?.navigateToHome()
    }
}
