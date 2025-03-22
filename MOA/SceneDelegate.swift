//
//  SceneDelegate.swift
//  MOA
//
//  Created by 오원석 on 8/13/24.
//

import UIKit
import KakaoSDKUser
import KakaoSDKCommon
import KakaoSDKAuth
import RxKakaoSDKAuth
import RxKakaoSDKUser
import RxKakaoSDKCommon
import FirebaseAuth
import FirebaseCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        MOALogger.logd()
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = SplashViewController()
        window?.makeKeyAndVisible()
        
        var rootViewController = UIViewController()
        
        // 알림 이벤트로 앱 시작 시
        if let userInfo = connectionOptions.notificationResponse?.notification.request.content.userInfo,
           let count = userInfo[NotificationManager.count] as? Int,
           let gifticonId = userInfo[NotificationManager.gifticonId] as? String {
            let navigationController = UINavigationController(rootViewController: HomeTabBarController())
            if count > 1 {
                // 다중 기프티콘 알림
                let notificationDataVC = NotificationViewController()
                navigationController.pushViewController(notificationDataVC, animated: false)
            } else {
                // 단일 기프티콘 알림
                let detailVC = GifticonDetailViewController(gifticonId: gifticonId)
                navigationController.pushViewController(detailVC, animated: false)
            }
            rootViewController = navigationController
        } else {
            if UserPreferences.isShouldEntryLogin() {
                if UserPreferences.isSignUp() {
                    let currentUser = Auth.auth().currentUser
                    rootViewController = currentUser == nil ? UINavigationController(rootViewController: LoginViewController()) : UINavigationController(rootViewController: HomeTabBarController())
                } else {
                    rootViewController = UINavigationController(rootViewController: LoginViewController())
                }
            } else {
                rootViewController = WalkThroughViewController()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            guard let window = self.window else { return }
            UIView.transition(
                with: window,
                duration: 0.5,
                options: [.transitionCrossDissolve],
                animations: {
                    window.rootViewController = rootViewController
                }
            )
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
        }
    }
}

