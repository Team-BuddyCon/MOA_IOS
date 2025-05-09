//
//  AppCoordinator.swift
//  MOA
//
//  Created by 오원석 on 5/6/25.
//

import UIKit

class AppCoordinator: Coordinator, AuthCoordinatorDelegate, HomeCoordinatorDelegate, NotificationManagerDelegate {
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
        NotificationManager.shared.delegate = self
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
    
    func navigateFromNotification(isSingle: Bool, gifticonId: String) {
        if isSingle {
            navigateToGifticonDetail(gifticonId: gifticonId)
        } else {
            navigateToNotification()
        }
    }
    
    func navigateToNotificationDetail(isSingle: Bool, gifticonId: String) {
        if isSingle {
            navigateToGifticonDetail(gifticonId: gifticonId)
        } else {
            navigateToHomeTab()
        }
    }
    
    func navigateToHomeTab() {
        if let homeCoordinator = childs.first(where: { $0 is HomeCoordinator }) as? HomeCoordinator {
            homeCoordinator.navigateToHomeTab()
        }
    }
    
    func navigateToNotification() {
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        homeCoordinator.delegate = self
        childs.append(homeCoordinator)
        homeCoordinator.start()
        homeCoordinator.navigateToNotification()
    }
    
    func navigateToGifticonDetail(gifticonId: String) {
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        homeCoordinator.delegate = self
        childs.append(homeCoordinator)
        homeCoordinator.start()
        homeCoordinator.navigateToGifticonDetail(gifticonId: gifticonId)
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
