//
//  AuthCoordinator.swift
//  MOA
//
//  Created by 오원석 on 5/6/25.
//

import UIKit

class AuthCoordinator: Coordinator, WalkThroughViewControllerDelegate {
    var childs: [Coordinator] = []
    
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        if UserPreferences.isShouldEntryLogin() {
            if UserPreferences.isSignUp() {
                
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
    
    func login() {
        MOALogger.logd()
        let loginVC = LoginViewController()
        self.navigationController.viewControllers = [loginVC]
    }
}
