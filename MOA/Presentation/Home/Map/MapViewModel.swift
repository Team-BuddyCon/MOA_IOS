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
    let gifticonService: GifticonServiceProtocol
    let kakaoService: KakaoServiceProtocol
    let searchPlaceRelay = BehaviorRelay<[SearchPlace]>(value: [])
    var selectStoreTypeRelay: BehaviorRelay<StoreType> = BehaviorRelay(value: StoreType.ALL)
    var gifticonCountRelay = BehaviorRelay(value: 0)
    var imminentCountRelay = BehaviorRelay(value: 0)
    
    init(
        gifticonService: GifticonServiceProtocol,
        kakaoService: KakaoServiceProtocol
    ) {
        self.gifticonService = gifticonService
        self.kakaoService = kakaoService
    }
    
    func searchPlaceByKeyword() {
        // TODO 전체는 가지고 있는 기프티콘, 기타는 모든 마커 제거
        let storeType = selectStoreTypeRelay.value
        let keyword = (storeType == StoreType.ALL || storeType == StoreType.OTHERS) ? StoreType.STARBUCKS.rawValue : storeType.rawValue
        
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
    
    func getGifticonCount() {
        selectStoreTypeRelay
            .flatMapLatest{ [unowned self] storeType in
                Observable.zip(
                    gifticonService.fetchGifticonCount(
                        used: false,
                        storeCateogry: nil,
                        storeType: storeType == .ALL ? nil : storeType,
                        remainingDays: nil
                    ),
                    gifticonService.fetchGifticonCount(
                        used: false,
                        storeCateogry: nil,
                        storeType: storeType == .ALL ? nil : storeType,
                        remainingDays: 14
                    )
                )
            }
            .subscribe(onNext: { [unowned self] result1, result2 in
                switch result1 {
                case .success(let response):
                    gifticonCountRelay.accept(response.count)
                case .failure(let error):
                    MOALogger.loge(error.localizedDescription)
                }
                
                switch result2 {
                case .success(let response):
                    imminentCountRelay.accept(response.count)
                case .failure(let error):
                    MOALogger.logd(error.localizedDescription)
                }
            }).disposed(by: disposeBag)
    }
}
