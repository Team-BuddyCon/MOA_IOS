//
//  NetworkUrl.swift
//  MOA
//
//  Created by 오원석 on 9/23/24.
//

import Foundation

enum NetworkService {
    case MOA
    case KAKAO
}

final class UrlProvider {
    
    private static let MOA_URL = "http://3.37.254.182:8080"
    private static let KAKAO_URL = "https://dapi.kakao.com/v2"
    
    static func getUrl(service: NetworkService) -> String {
        switch service {
        case .MOA:
            return MOA_URL
        case .KAKAO:
            return KAKAO_URL
        }
    }
}
