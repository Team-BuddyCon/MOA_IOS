//
//  StoreCategory.swift
//  MOA
//
//  Created by 오원석 on 11/11/24.
//

import Foundation

enum StoreCategory: String, CaseIterable {
    case All = "전체"
    case CAFE = "카페"
    case CONVENIENCE_STORE = "편의점"
    case OTHERS = "기타"
    
    static func from(typeCode: String) -> StoreCategory? {
        switch typeCode {
        case StoreType.STARBUCKS.code:
            return .CAFE
        case StoreType.TWOSOME_PLACE.code:
            return .CAFE
        case StoreType.ANGELINUS.code:
            return .CAFE
        case StoreType.MEGA_COFFEE.code:
            return .CAFE
        case StoreType.COFFEE_BEAN.code:
            return .CAFE
        case StoreType.GONG_CHA.code:
            return .CAFE
        case StoreType.BASKIN_ROBBINS.code:
            return .CAFE
        case StoreType.MACDONALD.code:
            return .OTHERS
        case StoreType.GS25.code:
            return .CONVENIENCE_STORE
        case StoreType.CU.code:
            return .CONVENIENCE_STORE
        case StoreType.OTHERS.code:
            return .OTHERS
        default:
            fatalError()
        }
    }
    
    var code: String? {
        switch self {
        case .CAFE:
            return "CAFE"
        case .CONVENIENCE_STORE:
            return "CONVENIENCE_STORE"
        case .OTHERS:
            return "OTHERS"
        default:
            return nil
        }
    }
}
