//
//  HomeCoordinator.swift
//  MOA
//
//  Created by 오원석 on 5/8/25.
//

import UIKit

protocol HomeCoordinatorDelegate: AnyObject {
    func navigateToHomeTab()
}

class HomeCoordinator: Coordinator, HomeCoordinatorDelegate {
    var childs: [Coordinator] = []
    
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let gifticonCoordinator = GifticonCoordinator(navigationController: navigationController)
        gifticonCoordinator.delegate = self
        childs.append(gifticonCoordinator)
        gifticonCoordinator.start()
        
        let mapCoordinator = MapCoordinator(navigationController: navigationController)
        childs.append(mapCoordinator)
        mapCoordinator.start()
        
        let mypageCoordinator = MyPageCoordinator(navigationController: navigationController)
        childs.append(mypageCoordinator)
        mypageCoordinator.start()
        
        let homeTabBarController = HomeTabBarController(
            gifticonDelegate: gifticonCoordinator
        )
        self.navigationController.viewControllers = [homeTabBarController]
    }
    
    // MARK: HomeCoordinatorDelegate
    func navigateToHomeTab() {
        if let homeTabBarController = navigationController.viewControllers.first as? HomeTabBarController {
            self.navigationController.popToViewController(homeTabBarController, animated: true)
        }
    }
}
