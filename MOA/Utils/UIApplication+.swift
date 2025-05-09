//
//  UIApplication+.swift
//  MOA
//
//  Created by 오원석 on 9/21/24.
//

import UIKit
import SnapKit

extension UIApplication {
    
    var topBarHeight: CGFloat {
        return topViewController?.navigationController?.navigationBar.frame.height ?? 0.0
    }
    
    var tabBarHeight: CGFloat {
        return (topViewController as? HomeTabBarController)?.tabBar.frame.height ?? 0.0
    }
    
    var safeAreaTopHeight: CGFloat {
        if let windowScene = connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window.safeAreaInsets.top
        }
        return 0.0
    }
    
    var safeAreaBottomHeight: CGFloat {
        if let windowScene = connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window.safeAreaInsets.bottom
        }
        return 0.0
    }
    
    var topViewController: UIViewController? {
        if let windowScene = connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            if let viewController = window.rootViewController as? UINavigationController {
                return viewController.visibleViewController
            } else {
                return window.rootViewController
            }
        }
        return nil
    }
    
    func navigateGifticonDetail(gifticonId: String) {
        MOALogger.logd()
        if let windowScene = connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            
            let navigationController = UINavigationController(rootViewController: HomeTabBarController())
            let detailVC = GifticonDetailViewController(gifticonId: gifticonId)
            navigationController.pushViewController(detailVC, animated: false)
            
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
    
    func navigateNotification() {
        MOALogger.logd()
        if let windowScene = connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            
            let navigationController = UINavigationController(rootViewController: HomeTabBarController())
            let notificationDataVC = NotificationViewController()
            navigationController.pushViewController(notificationDataVC, animated: false)
            
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
}
