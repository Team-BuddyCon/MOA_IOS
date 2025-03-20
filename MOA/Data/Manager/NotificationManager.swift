//
//  NotificationManager.swift
//  MOA
//
//  Created by 오원석 on 2/28/25.
//

import UserNotifications
import UIKit

final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // [expireDate : [gifticonId]]
    private var identifierDic: [String: [String]] = [:] {
        didSet {
            MOALogger.logd("\(identifierDic.sorted(by: { $0.key > $1.key }))")
        }
    }
    
    // [gifticonId : name]
    private var nameDic: [String: String] = [:] {
        didSet {
            MOALogger.logd("\(nameDic)")
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
                UserPreferences.setNotificationTriggerDay(NotificationDday.day14)
            }
        }
    }
    
    func register(
        _ identifier: String,
        name: String,
        gifticonId: String
    ) {
        guard UserPreferences.isNotificationOn() else { return }
        UserPreferences.getNotificationTriggerDays().forEach { triggerDay in
            register(identifier, triggerDay: triggerDay, name: name, gifticonId: gifticonId)
        }
        
        notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
            MOALogger.logd("getPendingNotificationRequests: \(requests.map { $0.identifier })")
        })
    }
    
    func register(
        _ identifier: String,
        triggerDay: NotificationDday,
        name: String,
        gifticonId: String
    ) {
        let notificationId = "\(identifier)-\(triggerDay.rawValue)"
        if identifierDic.contains(where: { $0.key == notificationId }) {
            
            // 이미 등록된 알림이 있는 경우
            if identifierDic[notificationId]?.firstIndex(of: gifticonId) != nil {
                return
            }
            
            identifierDic[notificationId]?.append(gifticonId)
            nameDic[gifticonId] = name
        } else {
            identifierDic[notificationId] = [gifticonId]
            nameDic[gifticonId] = name
        }
        
        guard let count = identifierDic[notificationId]?.count else {
            return
        }
        
        // 알림 등록
        let expireDate = identifier.toDate(format: AVAILABLE_GIFTICON_TIME_FORMAT)
        registerNotification(
            notificationId,
            expireDate: expireDate,
            triggerDay: triggerDay,
            name: name,
            count: count,
            gifticonId: gifticonId
        )
    }
    
    func remove(
        _ identifier: String,
        name: String,
        gifticonId: String
    ) {
        UserPreferences.getNotificationTriggerDays().forEach { triggerDay in
            remove(identifier, triggerDay: triggerDay, name: name, gifticonId: gifticonId)
        }
        
        notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
            MOALogger.logd("getPendingNotificationRequests: \(requests.map { $0.identifier })")
        })
    }
    
    func remove(
        _ identifier: String,
        triggerDay: NotificationDday,
        name: String,
        gifticonId: String
    ) {
        MOALogger.logd("\(identifier)")
        
        let notificationId = "\(identifier)-\(triggerDay.rawValue)"
        
        // notificationId로 등록된 알림 없으면 무시
        if !identifierDic.contains(where: { $0.key == notificationId }) {
            return
        }
        
        // notificationId로 등록된 알림 중 name으로 설정된 알림이 없을 경우 무시
        if identifierDic[notificationId]?.firstIndex(of: gifticonId) == nil {
            return
        }
        
        // 알림 수정하여 등록 (다중 기프티콘 알림 -> 단건 기프티콘 알림, 또는 기프티콘 갯수 변경)
        if let count = identifierDic[notificationId]?.count, count > 1 {
            if let index = identifierDic[notificationId]?.firstIndex(of: gifticonId) {
                identifierDic[notificationId]?.remove(at: index)
            }
        } else {
            // notificationId에 gifticonId 알림 1개만 등록된 경우 삭제 후 종료
            identifierDic.removeValue(forKey: notificationId)
        }
        
        // gifticonId에 해당된 name 제거
        if isNotRegistered(identifier: notificationId) {
            nameDic.removeValue(forKey: gifticonId)
            
            // 시스템에 notificationId 알림 삭제 요청
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationId])
            return
        }
        
        guard let lastId = identifierDic[notificationId]?.last,
              let lastName = nameDic[lastId],
              let count = identifierDic[notificationId]?.count else {
            return
        }
        
        // 재알림 등록
        let expireDate = identifier.toDate(format: AVAILABLE_GIFTICON_TIME_FORMAT)
        registerNotification(
            notificationId,
            expireDate: expireDate,
            triggerDay: triggerDay,
            name: lastName,
            count: count,
            gifticonId: lastId
        )
    }
    
    func removeAll() {
        notificationCenter.removeAllPendingNotificationRequests()
        identifierDic.removeAll()
    }
    
    private func isNotRegistered(identifier: String) -> Bool {
        return identifierDic.values.allSatisfy({ gifticons in
            !gifticons.contains(where: { $0 == identifier })
        })
    }
    
    private func registerNotification(
        _ identifier: String,
        expireDate: Date?,
        triggerDay: NotificationDday,
        name: String,
        count: Int,
        gifticonId: String? = nil
    ) {
        let current = Date()
        if let notificationDate = triggerDay.getNotificationDate(target: expireDate),
           let expireDate = expireDate,
           let future = Calendar.current.date(byAdding: .day, value: 90, to: current),
           notificationDate > current && expireDate < future {  // 알림 시간이 현재 시간보다 미래이고, 현재+90일 내에 만료되는 경우에만 등록
            let content = makeNotificationContent(
                triggerDay: triggerDay,
                name: name,
                count: count,
                gifticonId: gifticonId
            )
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
        }
    }
    
    // TODO: 삭제
    func registerTestNotification(
        _ identifier: String,
        expireDate: Date?,
        name: String,
        count: Int,
        gifticonId: String? = nil
    ) {
        guard let expireDate = expireDate else { return }
        let title = name
        let body = count == 1 ? "\(title)이 얼마 남지 않았습니다." : "\(title)이외 \(count)개가 얼마 남지 않았습니다."
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        if let gifticonId = gifticonId {
            content.userInfo = ["gifticonId" : gifticonId]
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: expireDate)
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
    
    private func makeNotificationContent(
        triggerDay: NotificationDday,
        name: String,
        count: Int,
        gifticonId: String? = nil
    ) -> UNMutableNotificationContent {
        let title = name
        let body = triggerDay.getBody(name: name, count: count)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        if let gifticonId = gifticonId {
            content.userInfo = ["gifticonId" : gifticonId]
        }
        
        return content
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    // 앱이 포그라운드 상태일 때 알림 어떻게 처리할지 결정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        MOALogger.logd()
        completionHandler([.list, .banner, .badge, .sound])
    }
    
    // 앱이 포그라운드나 백그라운드 있을 때 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        MOALogger.logd()
        
        let userInfo = response.notification.request.content.userInfo
        if let gifticonId = userInfo["gifticonId"] as? String {
            UIApplication.shared.navigationGifticonDetail(gifticonId: gifticonId)
        }
        
        completionHandler()
    }
}
