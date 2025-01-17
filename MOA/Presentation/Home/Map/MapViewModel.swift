//
//  MapViewModel.swift
//  MOA
//
//  Created by 오원석 on 1/17/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

final class MapViewModel: BaseViewModel {
    let kakaoService: KakaoServiceProtocol
    let searchPlaceRelay = BehaviorRelay<[SearchPlace]>(value: [])
    
    var selectStoreType = StoreType.ALL
    
    init(kakaoService: KakaoServiceProtocol) {
        self.kakaoService = kakaoService
    }
    
    func searchPlaceByKeyword() {
        // TODO 전체는 가지고 있는 기프티콘, 기타는 모든 마커 제거
        let keyword = (selectStoreType == StoreType.ALL || selectStoreType == StoreType.OTHERS) ? StoreType.STARBUCKS.rawValue : selectStoreType.rawValue
        
        guard let latitude = LocationManager.shared.latitude else { return }
        guard let longitude = LocationManager.shared.longitude else { return }
        kakaoService.searchPlaceByKeyword(
            query: keyword,
            x: String(longitude),
            y: String(latitude),
            radius: 2000
        ).subscribe(onNext: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                MOALogger.logd("\(response)")
                searchPlaceRelay.accept(response.places.map { $0.toModel() })
            case .failure(let error):
                MOALogger.loge(error.localizedDescription)
            }
        }).disposed(by: disposeBag)
    }
}
