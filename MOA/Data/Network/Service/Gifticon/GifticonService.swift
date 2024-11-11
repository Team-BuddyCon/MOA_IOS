//
//  GifticonService.swift
//  MOA
//
//  Created by 오원석 on 11/11/24.
//

import Foundation
import RxSwift

let GIFTICON_AVAILABLE_PATH = "/api/v1/gifticons/available"

protocol GifticonServiceProtocol {
    func fetchAvailable(
        pageNumber: Int,
        rowCount: Int,
        storeCateogry: StoreCategory,
        storeType: StoreType,
        sortType: SortType
    )
}
