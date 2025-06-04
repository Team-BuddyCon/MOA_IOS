//
//  BottomSheetDelegate.swift
//  MOA
//
//  Created by 오원석 on 11/10/24.
//

import Foundation

protocol WillBottomSheetDelegate {
    func selectSortType(type: SortType)
    func selectDate(date: Date)
    func selectStore(type: StoreType)
    func selectOtherStore(store: String)
}

// optional
extension WillBottomSheetDelegate {
    func selectSortType(type: SortType) {}
    func selectDate(date: Date) {}
    func selectStore(type: StoreType) {}
    func selectOtherStore(store: String) {}
}
