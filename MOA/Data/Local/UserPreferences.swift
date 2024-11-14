//
//  UserPreferences.swift
//  MOA
//
//  Created by 오원석 on 9/22/24.
//

import UIKit

private let SHOULD_ENTRY_LOGIN = "SHOULD_ENTRY_LOGIN"
private let LOGIN_USER_NAME = "LOGIN_USER_NAME"
private let MOA_ACCESS_TOKEN = "MOA_ACCESS_TOKEN"

final class UserPreferences {
    
    private init() {}
    
    static func isShouldEntryLogin() -> Bool {
        let isShould = UserDefaults.standard.bool(forKey: SHOULD_ENTRY_LOGIN)
        MOALogger.logd("\(isShould)")
        return isShould
    }
    
    static func setShouldEntryLogin() {
        MOALogger.logd()
        UserDefaults.standard.set(true, forKey: SHOULD_ENTRY_LOGIN)
    }
    
    static func getLoginUserName() -> String {
        let userName = UserDefaults.standard.string(forKey: LOGIN_USER_NAME) ?? ""
        MOALogger.logd(userName)
        return userName
    }
    
    static func setLoginUserName(name: String?) {
        MOALogger.logd(name)
        UserDefaults.standard.set(name, forKey: LOGIN_USER_NAME)
    }
    
    static func getAccessToken() -> String {
        let accessToken = UserDefaults.standard.string(forKey: MOA_ACCESS_TOKEN) ?? ""
        return accessToken
    }
    
    static func setAccessToken(accessToken: String) {
        MOALogger.logd(accessToken)
        UserDefaults.standard.set(accessToken, forKey: MOA_ACCESS_TOKEN)
    }
}
