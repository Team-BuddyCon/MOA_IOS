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
    var gifticonCountRelay = BehaviorRelay(value: 0)
    var imminentCountRelay = BehaviorRelay(value: 0)
    
    private let pageNumberRelay = BehaviorRelay(value: 0)
    var pageNumber: Int { pageNumberRelay.value }
    
    // 기프티콘 마지막 데이터 시 true
    var isScrollEnded = false
    
    // 기프티콘 목록 API 호출 중
    var isLoading = false
    
    let gifticons = BehaviorRelay<[AvailableGifticon]>(value: [])
    
    var selectedLayerID: String? = nil
    var selectedPoiID: String? = nil
    
    init(
        gifticonService: GifticonServiceProtocol,
        kakaoService: KakaoServiceProtocol
    ) {
        self.gifticonService = gifticonService
        self.kakaoService = kakaoService
    }
    
    func fetch() {
        MOALogger.logd()
        Observable.combineLatest(
            pageNumberRelay,
            selectStoreTypeRelay
        ).flatMapLatest { [unowned self] pageNumber, storeType in
            self.isLoading = true
            self.gifticons.accept(self.gifticons.value + [AvailableGifticon](repeating: AvailableGifticon(), count: 6))
            return self.gifticonService
                .fetchAvailableGifticon(
                    pageNumber: pageNumber,
                    rowCount: 10,
                    storeCateogry: nil,
                    storeType: storeType,
                    sortType: SortType.EXPIRE_DATE
                )
        }.map { [unowned self] result -> [AvailableGifticon] in
            switch result {
            case .success(let response):
                let data = response.gifticonInfos.content.map { $0.toModel() }
                if data.isEmpty {
                    isScrollEnded = true
                }
                return data
            case .failure(let error):
                MOALogger.loge(error.localizedDescription)
                isScrollEnded = true
                return []
            }
        }.subscribe(onNext: { [unowned self] data in
            let current = gifticons.value
            isLoading = false
            gifticons.accept(current + data)
        }).disposed(by: disposeBag)
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
    
    func getGifticonCount() {
        MOALogger.logd()
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
    
    func refresh() {
        clearPagingData()
    }
    
    func fetchMore() {
        MOALogger.logd()
        pageNumberRelay.accept(pageNumber + 1)
    }
    
    func changeStoreType(storeType: StoreType) {
        MOALogger.logd()
        clearPagingData()
        selectStoreTypeRelay.accept(storeType)
    }
    
    private func clearPagingData() {
        isScrollEnded = false
        gifticons.accept([])
        pageNumberRelay.accept(0)
    }
}
