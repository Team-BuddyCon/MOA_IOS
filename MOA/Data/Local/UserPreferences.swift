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
        UserDefaults.standard.bool(forKey: IS_NEEDED_SHOW_LOGIN)
    }
    
    static func setIsNeededShowLogin(isShow: Bool) {
        UserDefaults.standard.set(isShow, forKey: IS_NEEDED_SHOW_LOGIN)
    }
}
