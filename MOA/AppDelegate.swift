//
//  AppDelegate.swift
//  MOA
//
//  Created by 오원석 on 8/13/24.
//

import UIKit
import RxKakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        MOALogger.logd()
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        MOALogger.logd()
        guard let appKey = Bundle.main.infoDictionary?["KakaoApiKey"] as? String else {
            return true
        }
        
        RxKakaoSDK.initSDK(appKey: appKey)
        
        return true
    }

}

