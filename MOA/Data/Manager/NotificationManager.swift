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
    private var identifierDic: [String: [String]] = [:] {
        didSet {
            MOALogger.logd("\(identifierDic)")
        }
    }
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuhthorization() {
        MOALogger.logd()
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationCenter.requestAuthorization(options: authOptions) { isGranted, error in
            UserPreferences.setCheckNotificationAuthorization()
            
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
        name: String
    ) {
        MOALogger.logd("\(identifier)")
        
        var isRegistered: Bool = false
        if identifierDic.contains(where: { $0.key == identifier }) {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
            isRegistered = true
            self.identifierDic[identifier]?.append(name)
        } else {
            self.identifierDic[identifier] = [name]
        }
        
        let content = UNMutableNotificationContent()
        content.title = isRegistered ? "\(name)외에 \(String(describing: identifierDic[identifier]?.count)) 개 만료 임박" : "\(name) 만료 임박"
        content.body = isRegistered ? "\(name)외에 \(String(describing: identifierDic[identifier]?.count)) 개가 곧 만료돼요" : "\(name) 곧 만료돼요"
        
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
    
    func remove(
        _ identifier: String,
        name: String
    ) {
        MOALogger.logd("\(identifier)")
        
        if var count = identifierDic[identifier]?.count {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
            if count > 1 {
                if let index = identifierDic[identifier]?.firstIndex(of: name) {
                    identifierDic[identifier]?.remove(at: index)
                    count -= 1
                }
                
                let content = UNMutableNotificationContent()
                content.title = count > 1 ? "\(name)외에 \(count) 개 만료 임박" : "\(name) 만료 임박"
                content.body = count > 1 ? "\(name)외에 \(count) 개가 곧 만료돼요" : "\(name) 곧 만료돼요"
                
                let date = identifier.toDate(format: AVAILABLE_GIFTICON_TIME_FORMAT)
                let notificationDate = UserPreferences.getNotificationDday().getNotificationDate(target: date)
                guard let notificationDate = notificationDate else { return }
                
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
                
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
                
            } else {
                identifierDic.removeValue(forKey: identifier)
            }
        }
    }
    
    func removeAll() {
        notificationCenter.removeAllPendingNotificationRequests()
        identifierDic.removeAll()
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
