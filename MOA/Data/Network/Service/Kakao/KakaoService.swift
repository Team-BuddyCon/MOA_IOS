//
//  KakaoService.swift
//  MOA
//
//  Created by 오원석 on 12/30/24.
//

import Foundation
import RxSwift

protocol KakaoServiceProtocol {
    func searchPlaceByKeyword(
        query: String,
        x: String,
        y: String,
        radius: Int
    ) -> Observable<Result<SearchPlaceByKeywordResponse, URLError>>
}

final class KakaoService: KakaoServiceProtocol {
    static let shared = KakaoService()
    private init() {}
    
    func searchPlaceByKeyword(
        query: String,
        x: String,
        y: String,
        radius: Int = 2000
    ) -> Observable<Result<SearchPlaceByKeywordResponse, URLError>> {
        let request = SearchPlaceByKeywordRequest(
            query: query,
            x: x,
            y: y,
            radius: radius
        )
        
        return NetworkManager.shared.request(request: request)
    }
}
