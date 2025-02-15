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
    
    private let refreshSubject = BehaviorRelay(value: Void())
    
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
        
        Observable.combineLatest(
            refreshSubject,
            selectStoreTypeRelay
        ).flatMap { [unowned self] _, storeType -> Observable<[GifticonResponse]> in
            return gifticonService.fetchGifticons(storeType: storeType)
        }.subscribe(
            onNext: { [unowned self] gifticons in
                MOALogger.logd("fetchAllGifticon success")
                self.gifticons.accept(gifticons.map { $0.toModel() })
                self.searchPlaceByKeyword()
            }
        ).disposed(by: disposeBag)
    }
    
    func searchPlaceByKeyword() {
        MOALogger.logd()
        
        let storeType = selectStoreTypeRelay.value
        guard storeType != StoreType.OTHERS else { return }
        guard let latitude = LocationManager.shared.latitude else { return }
        guard let longitude = LocationManager.shared.longitude else { return }
        
        if storeType == .ALL {
            let keywords = Array(Set(gifticons.value.map { $0.gifticonStore.rawValue }.filter { $0 != StoreType.OTHERS.rawValue }))
            var searchPlaces: [SearchPlace] = []
            Observable.from(keywords).flatMap { keyword in
                self.kakaoService.searchPlaceByKeyword(
                    query: keyword,
                    x: String(longitude),
                    y: String(latitude),
                    radius: 2000
                )
            }.subscribe(
                onNext: { result in
                    switch result {
                    case .success(let response):
                        MOALogger.logd("\(response)")
                        searchPlaces.append(contentsOf: response.places.map { $0.toModel() })
                    case .failure(let error):
                        MOALogger.loge(error.localizedDescription)
                    }
                },
                onCompleted: {
                    self.searchPlaceRelay.accept(searchPlaces)
                }
            ).disposed(by: disposeBag)
        } else {
            let keyword = storeType.rawValue
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
    
    func changeStoreType(storeType: StoreType) {
        MOALogger.logd()
        selectStoreTypeRelay.accept(storeType)
    }
    
    func refresh() {
        refreshSubject.accept(Void())
    }
}
