//
//  NotificationManager.swift
//  MOA
//
//  Created by 오원석 on 2/28/25.
//

import Foundation
import UserNotifications

final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuhthorization() {
        MOALogger.logd()
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationCenter.requestAuthorization(options: authOptions) { isGranted, error in
            if let error = error {
                MOALogger.loge(error.localizedDescription)
                return
            }
            
            MOALogger.logd("\(isGranted)")
            UserPreferences.setNotificationOn(isOn: isGranted)
            if isGranted {
                UserPreferences.setNotificationDday(dday: NotificationDday.day14)
            }
        }
    }
    
    func register(
        _ identifier: String,
        date: Date,
        title: String,
        body: String
    ) {
        MOALogger.logd("\(identifier)")
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                MOALogger.loge(error.localizedDescription)
                return
            }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    // 앱이 포그라운드 상태일 때 알림 어떻게 처리할지 결정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        MOALogger.logd()
        completionHandler([.list, .banner, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        MOALogger.logd()
    }
}
