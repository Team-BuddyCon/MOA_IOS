//
//  UserPreferences.swift
//  MOA
//
//  Created by 오원석 on 9/22/24.
//

import UIKit

private let SHOULD_ENTRY_LOGIN = "SHOULD_ENTRY_LOGIN"
private let LOGIN_USER_NAME = "LOGIN_USER_NAME"
private let USER_ID = "USER_ID"
private let SIGN_UP = "SIGN_UP"
private let OAUTH_SERVICE = "OAUTH_SERVICE"

enum OAuthService: String {
    case Google = "Google"
    case Apple = "Apple"
}

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
    
    static func setSignUp(sign: Bool) {
        MOALogger.logd()
        UserDefaults.standard.set(sign, forKey: SIGN_UP)
    }
    
    static func getUserID() -> String {
        let userID = UserDefaults.standard.string(forKey: USER_ID) ?? ""
        return userID
    }
    
    static func setUserID(userID: String) {
        MOALogger.logd()
        UserDefaults.standard.set(userID, forKey: USER_ID)
    }
    
    static func getOAuthService() -> String {
        let service = UserDefaults.standard.string(forKey: OAUTH_SERVICE) ?? ""
        return service
    }
    
    static func setOAuthService(service: String) {
        MOALogger.logd()
        UserDefaults.standard.set(service, forKey: OAUTH_SERVICE)
    }
}
