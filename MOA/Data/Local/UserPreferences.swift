//
//  UserPreferences.swift
//  MOA
//
//  Created by 오원석 on 9/22/24.
//

import UIKit
import Algorithms

private let SHOULD_ENTRY_LOGIN = "SHOULD_ENTRY_LOGIN"
private let LOGIN_USER_NAME = "LOGIN_USER_NAME"
private let USER_ID = "USER_ID"
private let SIGN_UP = "SIGN_UP"
private let SHOW_LOGIN_POPUP = "SHOW_LOGIN_POPUP"
private let OAUTH_SERVICE = "OAUTH_SERVICE"
private let NOTIFICATION_ISON = "NOTIFICATION_ISON"
private let NOTIFICATION_TRIGGER_DAYS = "NOTIFICATION_TRIGGER_DAYS"
private let NOTIFICATION_AUTHORIZATION_CHECK = "NOTIFICATION_AUTHORIZATION_CHECK"

enum OAuthService: String {
    case Google = "Google"
    case Apple = "Apple"
}

final class UserPreferences {
    
    private init() {}
    
    // 워크쓰루 이미 본 경우 넘기기 위한 Bool 변수
    static func isShouldEntryLogin() -> Bool {
        let isShould = UserDefaults.standard.bool(forKey: SHOULD_ENTRY_LOGIN)
        return isShould
    }
    
    static func setShouldEntryLogin() {
        MOALogger.logd()
        UserDefaults.standard.set(true, forKey: SHOULD_ENTRY_LOGIN)
    }
    
    // 이미 회원가입한 경우
    static func isSignUp() -> Bool {
        let isSignUp = UserDefaults.standard.bool(forKey: SIGN_UP)
        return isSignUp
    }
    
    static func setSignUp(sign: Bool) {
        MOALogger.logd("\(sign)")
        UserDefaults.standard.set(sign, forKey: SIGN_UP)
    }
    
    static func isShowLoginPopup() -> Bool {
        let isShow = UserDefaults.standard.bool(forKey: SHOW_LOGIN_POPUP)
        return isShow
    }
    
    static func setShowLogin(isShow: Bool) {
        MOALogger.logd("\(isShow)")
        UserDefaults.standard.set(isShow, forKey: SHOW_LOGIN_POPUP)
    }
    
    static func getLoginUserName() -> String {
        let userName = UserDefaults.standard.string(forKey: LOGIN_USER_NAME) ?? ""
        return userName
    }
    
    static func setLoginUserName(name: String?) {
        MOALogger.logd(name)
        UserDefaults.standard.set(name, forKey: LOGIN_USER_NAME)
    }
    
    static func getUserID() -> String {
        let userID = UserDefaults.standard.string(forKey: USER_ID) ?? ""
        return userID
    }
    
    static func setUserID(userID: String) {
        MOALogger.logd(userID)
        UserDefaults.standard.set(userID, forKey: USER_ID)
    }
    
    static func getOAuthService() -> String {
        let service = UserDefaults.standard.string(forKey: OAUTH_SERVICE) ?? ""
        return service
    }
    
    static func setOAuthService(service: String) {
        MOALogger.logd(service)
        UserDefaults.standard.set(service, forKey: OAUTH_SERVICE)
    }
    
    static func isNotificationOn() -> Bool {
        let isOn = UserDefaults.standard.bool(forKey: NOTIFICATION_ISON)
        return isOn
    }
    
    static func setNotificationOn(isOn: Bool) {
        MOALogger.logd("\(isOn)")
        UserDefaults.standard.set(isOn, forKey: NOTIFICATION_ISON)
    }
    
    static func getNotificationTriggerDays() -> [NotificationDday] {
        let days = UserDefaults.standard.value(forKey: NOTIFICATION_TRIGGER_DAYS)
        MOALogger.logd("\((days as? [Int])?.compactMap { NotificationDday(rawValue: $0) } ?? [])")
        return (days as? [Int])?.compactMap { NotificationDday(rawValue: $0) } ?? []
    }
    
    static func setNotificationTriggerDay(_ day: NotificationDday) {
        MOALogger.logd("\(day)")
        let days = getNotificationTriggerDays().map { $0.rawValue } + [day].map { $0.rawValue }
        let uniqueDays = Array(Set(days)).sorted(by: >)
        UserDefaults.standard.set(uniqueDays, forKey: NOTIFICATION_TRIGGER_DAYS)
    }
    
    static func removeNotificationTriggerDay(_ day: NotificationDday) {
        MOALogger.logd("\(day)")
        var days = getNotificationTriggerDays().map { $0.rawValue }
        days.removeAll(where: { $0 == day.rawValue })
        UserDefaults.standard.set(days, forKey: NOTIFICATION_TRIGGER_DAYS)
    }
    
    static func removeAllNotificationTriggerDays() {
        MOALogger.logd()
        UserDefaults.standard.set([], forKey: NOTIFICATION_TRIGGER_DAYS)
    }
    
    static func isCheckNotificationAuthorization() -> Bool {
        let isCheck = UserDefaults.standard.bool(forKey: NOTIFICATION_AUTHORIZATION_CHECK)
        return isCheck
    }
    
    static func setCheckNotificationAuthorization() {
        MOALogger.logd()
        UserDefaults.standard.set(true, forKey: NOTIFICATION_AUTHORIZATION_CHECK)
    }
}
