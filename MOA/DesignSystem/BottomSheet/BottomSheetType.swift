//
//  BottomSheetType.swift
//  MOA
//
//  Created by 오원석 on 11/9/24.
//

import Foundation

enum BottomSheetType: Equatable {
    case Sort(type: SortType)
    case Date(date: Date)
    case Store
    case Other_Store
    case MapStore(place: SearchPlace)
    case MapDeepLink
    
    var height: Int {
        switch self {
        case .Sort:
            return 230
        case .Date:
            return 313
        case .Store:
            return 498
        case .Other_Store:
            return 400
        case .MapStore:
            return 180
        case .MapDeepLink:
            return 254
        }
    }
    
    static func == (lhs: BottomSheetType, rhs: BottomSheetType) -> Bool {
        switch (lhs, rhs) {
        case (.Sort, .Sort):
            return true
        case (.Date, .Date):
            return true
        case (.Store, .Store):
            return true
        case (.Other_Store, .Other_Store):
            return true
        case (.MapStore, .MapStore):
            return true
        case (.MapDeepLink, .MapDeepLink):
            return true
        default:
            return false
        }
    }
}
