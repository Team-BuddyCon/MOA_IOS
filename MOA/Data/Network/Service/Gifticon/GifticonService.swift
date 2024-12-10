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
        storeCateogry: StoreCategory?,
        storeType: StoreType?,
        sortType: SortType
    ) -> Observable<Result<AvailableGifticonResponse, URLError>>
    
    func fetchCreateGifticon(
        image: Data,
        name: String,
        expireDate: String,
        store: String,
        memo: String?
    ) -> Observable<Result<CreateGifticonResponse, URLError>>
}


final class GifticonService: GifticonServiceProtocol {
    static let shared = GifticonService()
    private init() {}
    
    func fetchAvailableGifticon(
        pageNumber: Int,
        rowCount: Int = 20,
        storeCateogry: StoreCategory?,
        storeType: StoreType?,
        sortType: SortType
    ) -> Observable<Result<AvailableGifticonResponse, URLError>> {
        let request = AvailableGifticonRequest(
            pageNumber: pageNumber,
            rowCount: rowCount,
            storeCategory: storeCateogry,
            storeType: storeType,
            sortType: sortType
        )
        
        return NetworkManager.shared.request(request: request)
    }
    
    func fetchCreateGifticon(
        image: Data,
        name: String,
        expireDate: String,
        store: String,
        memo: String?
    ) -> Observable<Result<CreateGifticonResponse, URLError>> {
        let request = CreateGifticonRequest(
            image: image,
            name: name,
            expireDate: expireDate,
            store: store,
            memo: memo
        )
        
        return NetworkManager.shared.request(request: request)
    }
}
