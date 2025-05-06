//
//  AppCoordinator.swift
//  MOA
//
//  Created by 오원석 on 5/6/25.
//

import UIKit

class AppCoordinator: Coordinator {
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
        childs.append(authCoordinator)
        authCoordinator.start()
    }
}
