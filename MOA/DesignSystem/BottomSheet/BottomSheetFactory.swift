//
//  BottomSheetFactory.swift
//  MOA
//
//  Created by 오원석 on 6/6/25.
//

import UIKit

final class BottomSheetFactory {
    
    static func create(
        sheetType: BottomSheetType,
        delegate: BottomSheetViewControllerDelegate? = nil
    ) -> BottomSheetViewController {
        switch sheetType {
        case .Sort(let type):
            let bottomSheetVC = SortBottomSheetViewController(sheetType: sheetType)
            bottomSheetVC.delegate = delegate
            return bottomSheetVC
        case .Date(let date):
            let bottomSheetVC = ExpireDateBottomSheetViewController(sheetType: sheetType)
            bottomSheetVC.delegate = delegate
            return bottomSheetVC
        case .Store:
            let bottomSheetVC = StoreBottomSheetViewController(sheetType: sheetType)
            bottomSheetVC.delegate = delegate
            return bottomSheetVC
        case .MapStore(let place):
            let bottomSheetVC = MapLocationBottomSheetViewController(sheetType: sheetType)
            bottomSheetVC.delegate = delegate
            bottomSheetVC.searchPlace = place
            return bottomSheetVC
        default:
            fatalError()
        }
    }
}
