//
//  BottomSheetViewControllerDelegate.swift
//  MOA
//
//  Created by 오원석 on 6/3/25.
//

import Foundation

@objc protocol BottomSheetViewControllerDelegate {
    @objc optional func dismiss()
}

protocol SortBottomSheetViewControllerDelegate: BottomSheetViewControllerDelegate {
    func didSelectSort(type: SortType)
}

protocol ExpireDateBottomSheetViewControllerDelegate: BottomSheetViewControllerDelegate {
    func didSelectDate(date: Date)
}

protocol StoreBottomSheetViewControllerDelegate: BottomSheetViewControllerDelegate {
    func didSelectStore(store: StoreType)
    func didSelectOther(store: String)
}
