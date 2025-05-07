//
//  HomeCoordinator.swift
//  MOA
//
//  Created by 오원석 on 5/8/25.
//

import UIKit

class HomeCoordinator: Coordinator {
    var childs: [Coordinator] = []
    
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeTabBarController = HomeTabBarController()
        self.navigationController.viewControllers = [homeTabBarController]
    }
}
