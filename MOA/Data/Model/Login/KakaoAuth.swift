//
//  KakaoAuth.swift
//  MOA
//
//  Created by 오원석 on 10/30/24.
//

import Foundation

struct KakaoAuth {
    let accessToken: String
    let profileName: String
    
    init(
        accessToken: String = "",
        profileName: String = ""
    ) {
        self.accessToken = accessToken
        self.profileName = profileName
    }
}
