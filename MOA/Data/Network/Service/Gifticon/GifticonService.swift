//
//  GifticonService.swift
//  MOA
//
//  Created by 오원석 on 11/11/24.
//

import Foundation
import RxSwift

protocol GifticonServiceProtocol {
    func fetchAvailableGifticon(
        pageNumber: Int,
        rowCount: Int,
        storeCateogry: StoreCategory,
        sortType: SortType
    ) -> Observable<Result<AvailableGifticonResponse, URLError>>
}


final class GifticonService: GifticonServiceProtocol {
    static let shared = GifticonService()
    private init() {}
    
    func fetchAvailableGifticon(
        pageNumber: Int,
        rowCount: Int,
        storeCateogry: StoreCategory,
        sortType: SortType
    ) -> Observable<Result<AvailableGifticonResponse, URLError>> {
        let request = AvailableGifticonRequest(
            pageNumber: pageNumber,
            rowCount: rowCount,
            storeCategory: storeCateogry,
            sortType: sortType
        )
        
        return NetworkManager.shared.request(request: request)
    }
}
