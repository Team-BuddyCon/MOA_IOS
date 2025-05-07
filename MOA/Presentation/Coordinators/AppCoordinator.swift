//
//  AppCoordinator.swift
//  MOA
//
//  Created by 오원석 on 5/6/25.
//

import UIKit

class AppCoordinator: Coordinator, AuthCoordinatorDelegate {
    var childs: [Coordinator] = []
    
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
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
        //재로그인
        //childs.removeAll(where: { $0 is AuthCoordinator })
        
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        childs.append(homeCoordinator)
        homeCoordinator.start()
    }
}
