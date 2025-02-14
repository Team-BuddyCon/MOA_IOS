//
//  StoreType.swift
//  MOA
//
//  Created by 오원석 on 11/11/24.
//

import UIKit

enum StoreType: String, CaseIterable {
    case ALL = "전체"
    case STARBUCKS = "스타벅스"
    case TWOSOME_PLACE = "투썸플레이스"
    case ANGELINUS = "엔젤리너스"
    case MEGA_COFFEE = "메가커피"
    case COFFEE_BEAN = "커피빈"
    case GONG_CHA = "공차"
    case BASKIN_ROBBINS = "배스킨라빈스"
    case MACDONALD = "맥도날드"
    case GS25 = "GS25"
    case CU = "CU"
    case OTHERS = "기타"
    
    var styleID: StyleID {
        switch self {
        case .STARBUCKS, .TWOSOME_PLACE, .ANGELINUS, .MEGA_COFFEE, .COFFEE_BEAN, .GONG_CHA, .BASKIN_ROBBINS:
            return StyleID.Cafe
        case .MACDONALD:
            return StyleID.FastFood
        default:
            return StyleID.Store
        }
    }
    
    var upStyleID: StyleID {
        switch self {
        case .STARBUCKS, .TWOSOME_PLACE, .ANGELINUS, .MEGA_COFFEE, .COFFEE_BEAN, .GONG_CHA, .BASKIN_ROBBINS:
            return StyleID.CafeUp
        case .MACDONALD:
            return StyleID.FastFoodUp
        default:
            return StyleID.StoreUp
        }
    }
    
    var layerID: LayerID {
        switch self {
        case .STARBUCKS, .TWOSOME_PLACE, .ANGELINUS, .MEGA_COFFEE, .COFFEE_BEAN, .GONG_CHA, .BASKIN_ROBBINS:
            return LayerID.Cafe
        case .MACDONALD:
            return LayerID.FastFood
        default:
            return LayerID.Store
        }
    }
    
    var image: UIImage? {
        switch self {
        case .ALL: return nil
        case .STARBUCKS: return UIImage(named: STARBUCKS_IMAGE)
        case .TWOSOME_PLACE: return UIImage(named: TWOSOME_PLACE_IMAGE)
        case .ANGELINUS: return UIImage(named: ANGELINUS_IMAGE)
        case .MEGA_COFFEE: return UIImage(named: MEGA_COFFEE_IMAGE)
        case .COFFEE_BEAN: return UIImage(named: COFFEE_BEAN_IMAGE)
        case .GONG_CHA: return UIImage(named: GONG_CHA_IMAGE)
        case .BASKIN_ROBBINS: return UIImage(named: BASKIN_ROBBINS_IMAGE)
        case .MACDONALD: return UIImage(named: MACDONALD_IMAGE)
        case .GS25: return UIImage(named: GS25_IMAGE)
        case .CU: return UIImage(named: CU_IMAGE)
        case .OTHERS: return UIImage(named: OTHERS_IMAGE)
        }
    }
    
    var code: String? {
        switch self {
        case .STARBUCKS: return "STARBUCKS"
        case .TWOSOME_PLACE: return "TWOSOME_PLACE"
        case .ANGELINUS: return "ANGELINUS"
        case .MEGA_COFFEE: return "MEGA_COFFEE"
        case .COFFEE_BEAN: return "COFFEE_BEAN"
        case .GONG_CHA: return "GONG_CHA"
        case .BASKIN_ROBBINS: return "BASKIN_ROBBINS"
        case .MACDONALD: return "MACDONALD"
        case .GS25: return "GS25"
        case .CU: return "CU"
        case .OTHERS: return "OTHERS"
        default: return nil
        }
    }
    
    var fields: [String] {
        switch self {
        case .ALL:
            return StoreType.allCases.compactMap(\.code)
        default:
            if let code = self.code {
                return [code]
            }
            return []
        }
    }
    
    
    static func from(string: String) -> StoreType? {
        switch string {
        case "STARBUCKS":
            return .STARBUCKS
        case "TWOSOME_PLACE":
            return .TWOSOME_PLACE
        case "ANGELINUS":
            return .ANGELINUS
        case "MEGA_COFFEE":
            return .MEGA_COFFEE
        case "COFFEE_BEAN":
            return .COFFEE_BEAN
        case "GONG_CHA":
            return .GONG_CHA
        case "BASKIN_ROBBINS":
            return .BASKIN_ROBBINS
        case "MACDONALD":
            return .MACDONALD
        case "GS25":
            return .GS25
        case "CU":
            return .CU
        case "OTHERS":
            return .OTHERS
        default:
            return nil
        }
    }
}
