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
    var coordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        MOALogger.logd()
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let navigationController = UINavigationController()
        window?.rootViewController = navigationController
        window?.backgroundColor = .white
        
        coordinator = AppCoordinator(navigationController: navigationController)
        coordinator?.start()
        
        window?.makeKeyAndVisible()

        // 알림 이벤트로 앱 시작 시
        if let userInfo = connectionOptions.notificationResponse?.notification.request.content.userInfo,
           let body = connectionOptions.notificationResponse?.notification.request.content.body,
           let count = userInfo[NotificationManager.count] as? Int,
           let gifticonId = userInfo[NotificationManager.gifticonId] as? String,
           let expireDate = userInfo[NotificationManager.notificationDate] as? String {
            let _ = LocalNotificationDataManager.shared.insertNotification(
                NotificationModel(
                    count: count,
                    date: expireDate,
                    message: body,
                    gifticonId: gifticonId,
                    isRead: false
                )
            )
            
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
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.coordinator?.navigateToAuth()
            }
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

