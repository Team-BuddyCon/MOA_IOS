//
//  BottomSheetViewControllerDelegate.swift
//  MOA
//
//  Created by 오원석 on 6/3/25.
//

import Foundation

protocol BottomSheetViewControllerDelegate {
}

protocol SortBottomSheetViewControllerDelegate: BottomSheetViewControllerDelegate {
    func didSelectSort(type: SortType)
}

protocol ExpireDateBottomSheetViewControllerDelegate: BottomSheetViewControllerDelegate {
    func didSelectDate(date: Date)
}
