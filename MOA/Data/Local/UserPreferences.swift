//
//  UserPreferences.swift
//  MOA
//
//  Created by 오원석 on 9/22/24.
//

import UIKit

private let IS_NEEDED_SHOW_LOGIN = "IS_NEEDED_SHOW_LOGIN"

final class UserPreferences {
    
    private init() {}
    
    static func getIsNeededShowLogin() -> Bool {
        let isShow = UserDefaults.standard.bool(forKey: IS_NEEDED_SHOW_LOGIN)
        MOALogger.logd("\(isShow)")
        return isShow
    }
    
    static func setIsNeededShowLogin(isShow: Bool) {
        MOALogger.logd("\(isShow)")
        UserDefaults.standard.set(isShow, forKey: IS_NEEDED_SHOW_LOGIN)
    }
}
