//
//  UserPreferences.swift
//  MOA
//
//  Created by 오원석 on 9/22/24.
//

import UIKit

private let SHOULD_ENTRY_LOGIN = "SHOULD_ENTRY_LOGIN"
private let LOGIN_USER_NAME = "LOGIN_USER_NAME"
private let SIGN_UP = "SIGN_UP"

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
    
    static func isSignUp() -> Bool {
        let isSignUp = UserDefaults.standard.bool(forKey: SIGN_UP)
        MOALogger.logd("\(isSignUp)")
        return isSignUp
    }
    
    static func setSignUp() {
        MOALogger.logd()
        UserDefaults.standard.set(true, forKey: SIGN_UP)
    }
}
