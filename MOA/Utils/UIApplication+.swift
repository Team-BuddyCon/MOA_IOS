//
//  UIApplication+.swift
//  MOA
//
//  Created by 오원석 on 9/21/24.
//

import UIKit

extension UIApplication {
    
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

    
    func setRootViewController(viewController: UIViewController) {
        MOALogger.logd("\(viewController)")
        if let windowScene = connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            window.rootViewController = UINavigationController(rootViewController: viewController)
            window.makeKeyAndVisible()
        }
    }
    
    func navigationHome() {
        MOALogger.logd()
        if let windowScene = connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            window.rootViewController = UINavigationController(rootViewController: HomeTabBarController()) 
            window.makeKeyAndVisible()
        }
    }
}
