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

final class MapViewModel: BaseViewModel, ViewModelType {
    
    struct Input {
        let selectStoreType: BehaviorRelay<StoreType>
        let refreshGifticons: PublishRelay<Void>
        let tapGifticon: PublishRelay<String>
        let searchPlaces: PublishRelay<StoreType>
        let panGestureOnBottomSheet: ControlEvent<UIPanGestureRecognizer>
        let changeBottomSheetState: BehaviorRelay<BottomSheetState>
        let changeBottomSheetHeight: BehaviorRelay<Double>
    }
    
    struct Output {
        let updateStoreType: Driver<StoreType>
        let updateGifticons: Driver<[GifticonModel]>
        let markSearchPlaces: Driver<[SearchPlace]>
        let moveBottomSheet: Signal<UIPanGestureRecognizer>
        let changeBottomSheetState: Driver<BottomSheetState>
        let changeBottomSheetHeight: Driver<Double>
    }
    
    let gifticonService: GifticonServiceProtocol
    let kakaoService: KakaoServiceProtocol
    
    private let gifticons = BehaviorRelay<[GifticonModel]>(value: [])
    private let searchPlacesRelay = BehaviorRelay<[SearchPlace]>(value: [])
    var searchPlaces: [SearchPlace] { searchPlacesRelay.value }
    
    // Marker 클릭 해제 시 기존에 선택된 마커 표시
    var selectedLayerID: String? = nil
    var selectedPoiID: String? = nil
    
    init(
        gifticonService: GifticonServiceProtocol,
        kakaoService: KakaoServiceProtocol
    ) {
        self.gifticonService = gifticonService
        self.kakaoService = kakaoService
    }
    
    func transform(input: Input) -> Output {
        Observable.combineLatest(
            input.selectStoreType,
            input.refreshGifticons
        ).flatMap { [unowned self] storeType, _ in
            gifticonService.fetchGifticons(storeType: storeType)
        }.subscribe(onNext: { [unowned self] gifticons in
            self.gifticons.accept(gifticons.map { $0.toModel() })
        }).disposed(by: disposeBag)
        
        handleSearchPlaces(input: input)
        
        return Output(
            updateStoreType: input.selectStoreType.asDriver(),
            updateGifticons: gifticons.asDriver(),
            markSearchPlaces: searchPlacesRelay.asDriver().debounce(RxTimeInterval.milliseconds(100)),
            moveBottomSheet: input.panGestureOnBottomSheet.asSignal(),
            changeBottomSheetState: input.changeBottomSheetState.asDriver(),
            changeBottomSheetHeight: input.changeBottomSheetHeight.asDriver()
        )
    }
    
    private func handleSearchPlaces(input: MapViewModel.Input) {
        input.searchPlaces
            .flatMap { [unowned self] storeType -> Observable<Result<SearchPlaceByKeywordResponse, URLError>> in
                guard storeType != .OTHERS else {
                    return Observable.just(Result.success(SearchPlaceByKeywordResponse(places: [])))
                }
                guard let latitude = LocationManager.shared.latitude else {
                    return Observable.just(Result.failure(URLError(.dataNotAllowed)))
                }
                guard let longitude = LocationManager.shared.longitude else {
                    return Observable.just(Result.failure(URLError(.dataNotAllowed)))
                }
                
                // API 호출 전에 초기화
                searchPlacesRelay.accept([])
                
                if storeType == .ALL {
                    let keywords = Array(
                        Set(gifticons.value
                            .map { $0.gifticonStore.rawValue }
                            .filter { $0 != StoreType.OTHERS.rawValue }
                        )
                    )
                    return Observable.from(keywords).flatMap { keyword in
                        self.kakaoService.searchPlaceByKeyword(
                            query: keyword,
                            x: String(longitude),
                            y: String(latitude),
                            radius: 2000
                        )
                    }
                } else {
                    let keyword = storeType.rawValue
                    return self.kakaoService.searchPlaceByKeyword(
                        query: keyword,
                        x: String(longitude),
                        y: String(latitude),
                        radius: 2000
                    )
                }
            }.subscribe(
                onNext: { [unowned self] result in
                    switch result {
                    case .success(let response):
                        var current = searchPlacesRelay.value
                        current.append(contentsOf: response.places.map { $0.toModel() })
                        searchPlacesRelay.accept(current)
                    case .failure(let error):
                        MOALogger.loge(error.localizedDescription)
                    }
                }
            ).disposed(by: disposeBag)
    }
}
