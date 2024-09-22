//
//  SceneDelegate.swift
//  MOA
//
//  Created by 오원석 on 8/13/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = SplashViewController()
        window?.makeKeyAndVisible()
        
        let isNeededShowLogin = UserPreferences.getIsNeededShowLogin()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            guard let window = self.window else { return }
            UIView.transition(
                with: window,
                duration: 0.5,
                options: [.transitionCrossDissolve],
                animations: {
                    window.rootViewController = isNeededShowLogin ? LoginViewController() : WalkThroughViewController()
                }
            )
        }
    }
}

