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
import KakaoMapsSDK

final class MapViewModel: BaseViewModel {
    let gifticonService: GifticonServiceProtocol
    let kakaoService: KakaoServiceProtocol
    
    let searchPlaceRelay = BehaviorRelay<[SearchPlace]>(value: [])
    var selectStoreTypeRelay: BehaviorRelay<StoreType> = BehaviorRelay(value: StoreType.ALL)
    
    let gifticons = BehaviorRelay<[GifticonModel]>(value: [])
    
    var selectedLayerID: String? = nil
    var selectedPoiID: String? = nil
    
    init(
        gifticonService: GifticonServiceProtocol,
        kakaoService: KakaoServiceProtocol
    ) {
        self.gifticonService = gifticonService
        self.kakaoService = kakaoService
    }
    
    func fetchAllGifticons() {
        MOALogger.logd()
        
        selectStoreTypeRelay.flatMap { [unowned self] storeType -> Observable<[GifticonResponse]> in
            return gifticonService.fetchGifticons(storeType: storeType)
        }.subscribe(
            onNext: { [unowned self] gifticons in
                self.gifticons.accept(gifticons.map { $0.toModel() })
            },
            onError: { error in
                MOALogger.loge(error.localizedDescription)
            }
        ).disposed(by: disposeBag)
    }
    
    func searchPlaceByKeyword() {
        MOALogger.logd()
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
    
    func changeStoreType(storeType: StoreType) {
        MOALogger.logd()
        selectStoreTypeRelay.accept(storeType)
    }
}
