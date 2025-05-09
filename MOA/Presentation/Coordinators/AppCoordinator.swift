//
//  AppCoordinator.swift
//  MOA
//
//  Created by 오원석 on 5/6/25.
//

import UIKit

class AppCoordinator: Coordinator, AuthCoordinatorDelegate, HomeCoordinatorDelegate {
    var childs: [Coordinator] = []
    
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        MOALogger.logd()
    }
    
    func start() {
        self.navigationController.pushViewController(SplashViewController(), animated: true)
    }
    
    func navigateToAuth() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.delegate = self
        childs.append(authCoordinator)
        authCoordinator.start()
    }
    
    func navigateToHome() {
        if let homeCoordinator = childs.first(where: { $0 is HomeCoordinator }) as? HomeCoordinator {
            homeCoordinator.start()
        } else {
            let homeCoordinator = HomeCoordinator(navigationController: navigationController)
            homeCoordinator.delegate = self
            childs.append(homeCoordinator)
            homeCoordinator.start()
        }
    }
    
    func navigateToLoginFromLogout() {
        if let authCoordinator = childs.first(where: { $0 is AuthCoordinator }) as? AuthCoordinator {
            authCoordinator.navigateToLoginFromWithLogout()
        }
    }
    
    func navigateToLoginFromWithDraw() {
        if let authCoordinator = childs.first(where: { $0 is AuthCoordinator }) as? AuthCoordinator {
            authCoordinator.navigateToLoginFromWithDraw()
        }
    }
}
