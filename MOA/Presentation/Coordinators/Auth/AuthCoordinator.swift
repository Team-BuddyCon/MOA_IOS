//
//  AuthCoordinator.swift
//  MOA
//
//  Created by 오원석 on 5/6/25.
//

import UIKit
import FirebaseAuth
import FirebaseCore

protocol AuthCoordinatorDelegate: AnyObject {
    func navigateToHome()
}

class AuthCoordinator: Coordinator, WalkThroughViewControllerDelegate, LoginViewControllerDelegate, SignUpCoordinatorDelegate {
    var childs: [Coordinator] = []
    
    private var navigationController: UINavigationController
    
    weak var delegate: AuthCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        if UserPreferences.isShouldEntryLogin() {
            if UserPreferences.isSignUp() {
                if let currentUser = Auth.auth().currentUser {
                    navigateToHome()
                } else {
                    navigateToLogin()
                }
            } else {
                navigateToLogin()
            }
        } else {
            navigateToWalkThrough()
        }
    }
    
    func navigateToWalkThrough() {
        MOALogger.logd()
        let walkThroughVC = WalkThroughViewController()
        walkThroughVC.delegate = self
        self.navigationController.viewControllers = [walkThroughVC]
    }
        
    // MARK: WalkThroughViewControllerDelegate
    func navigateToLogin() {
        MOALogger.logd()
        let loginVC = LoginViewController()
        loginVC.delegate = self
        self.navigationController.viewControllers = [loginVC]
    }
    
    // MARK: LoginViewControllerDelegate
    func loginInSuccess(isNewUser: Bool) {
        if isNewUser {
            if UserPreferences.isSignUp() {
                navigateToHome()
            } else {
                navigateToSignUp()
            }
        } else {
            UserPreferences.setSignUp(sign: true)
            navigateToHome()
        }
    }
    
    func navigateToSignUp() {
        let signUpCoordinator = SignUpCoordinator(navigationController: navigationController)
        signUpCoordinator.delegate = self
        childs.append(signUpCoordinator)
        signUpCoordinator.start()
    }
    
    // MARK: SignUpCoordinatorDelegate
    func navigateToHome() {
        childs.removeAll(where: { $0 is SignUpCoordinator })
        self.delegate?.navigateToHome()
    }
}
