//
//  UIApplication+.swift
//  MOA
//
//  Created by 오원석 on 9/21/24.
//

import UIKit

extension UIApplication {
    func setRootViewController(viewController: UIViewController) {
        MOALogger.logd("\(viewController)")
        if let windowScene = connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            window.rootViewController = UINavigationController(rootViewController: viewController)
            window.makeKeyAndVisible()
        }
    }
    
    func navigateToHome() {
        MOALogger.logd()
        let tabBarController = UITabBarController()
        let gifticonViewController = GifticonViewController()
        let mapViewController = MapViewController()
        let mypageViewController = MypageViewController()
        tabBarController.setViewControllers([gifticonViewController, mapViewController, mypageViewController], animated: true)
        
        if let windowScene = connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
}
