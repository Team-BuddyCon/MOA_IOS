//
//  SortType.swift
//  MOA
//
//  Created by 오원석 on 11/9/24.
//

import Foundation

enum SortType: String {
    case EXPIRE_DATE = "유효기간순"
    case CREATED_AT = "등록순"
    case NAME = "이름순"
    
    var field: String {
        switch self {
        case .EXPIRE_DATE:
            return HttpKeys.Gifticon.expireDate
        case .CREATED_AT:
            return HttpKeys.Gifticon.uplodeDate
        case .NAME:
            return HttpKeys.Gifticon.name
        }
    }
}
