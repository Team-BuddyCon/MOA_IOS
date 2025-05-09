//
//  HomeCoordinator.swift
//  MOA
//
//  Created by 오원석 on 5/8/25.
//

import UIKit

protocol HomeCoordinatorDelegate: AnyObject {
    func navigateToLoginFromLogout()
    func navigateToLoginFromWithDraw()
    func navigateFromNotification(isSingle: Bool, gifticonId: String)
    func navigateToNotificationDetail(isSingle: Bool, gifticonId: String)
}

class HomeCoordinator: Coordinator, HomeTabBarControllerDelegate, GifticonCoordinatorDelegate, MapCoordinatorDelegate, MyPageCoordinatorDelegate, NotificationViewControllerDelegate {
    var childs: [Coordinator] = []
    
    private var navigationController: UINavigationController
    
    weak var delegate: HomeCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        MOALogger.logd()
    }
    
    func start() {
        let gifticonCoordinator = GifticonCoordinator(navigationController: navigationController)
        gifticonCoordinator.delegate = self
        childs.append(gifticonCoordinator)
        gifticonCoordinator.start()
        
        let mapCoordinator = MapCoordinator(navigationController: navigationController)
        mapCoordinator.delegate = self
        childs.append(mapCoordinator)
        mapCoordinator.start()
        
        let mypageCoordinator = MyPageCoordinator(navigationController: navigationController)
        mypageCoordinator.delegate = self
        childs.append(mypageCoordinator)
        mypageCoordinator.start()
        
        let homeTabBarController = HomeTabBarController(
            gifticonDelegate: gifticonCoordinator,
            mapDelegate: mapCoordinator,
            mypageDelegate: mypageCoordinator
        )
        homeTabBarController.homeTabDelegate = self
        self.navigationController.viewControllers = [homeTabBarController]
    }
    
    // MARK: HomeCoordinatorDelegate
    func navigateToHomeTab() {
        if let homeTabBarController = navigationController.viewControllers.first as? HomeTabBarController {
            self.navigationController.popToViewController(homeTabBarController, animated: true)
        }
    }
    
    func navigateToHomeGifticonTab() {
        if let homeTabBarController = navigationController.viewControllers.first as? HomeTabBarController {
            self.navigationController.popToViewController(homeTabBarController, animated: true)
            homeTabBarController.selectedViewController = homeTabBarController.viewControllers?.first
            homeTabBarController.setupTopBarWithLargeTitleAndNotification(title: GIFTICON_MENU_TITLE)
        }
    }
    
    // MARK: MapCoordinatorDelegate
    func navigateToGifticonDetail(gifticonId: String) {
        if let gifticonCoordinator = childs.first(where: { $0 is GifticonCoordinator }) as? GifticonCoordinator {
            gifticonCoordinator.navigateToGifticonDetail(gifticonId: gifticonId)
        }
    }

    // MARK: MyPageCoordinatorDelegate
    func navigateToLoginFromLogout() {
        childs.removeAll()
        self.delegate?.navigateToLoginFromLogout()
    }
    
    func navigateToLoginFromWithDraw() {
        childs.removeAll()
        self.delegate?.navigateToLoginFromWithDraw()
    }
    
    func navigateToNotification() {
        let notificationVC = NotificationViewController()
        notificationVC.delegate = self
        self.navigationController.pushViewController(notificationVC, animated: true)
    }
    
    func navigateFromNotification(isSingle: Bool, gifticonId: String) {
        self.delegate?.navigateFromNotification(isSingle: isSingle, gifticonId: gifticonId)
    }
    
    func navigateToNotificationDetail(isSingle: Bool, gifticonId: String) {
        self.delegate?.navigateToNotificationDetail(isSingle: isSingle, gifticonId: gifticonId)
    }
}
