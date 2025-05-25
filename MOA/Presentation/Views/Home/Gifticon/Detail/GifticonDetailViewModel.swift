//
//  GifticonDetailViewModel.swift
//  MOA
//
//  Created by 오원석 on 12/15/24.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

final class GifticonDetailViewModel: BaseViewModel {
    
    struct Input {
        let viewWillAppear: PublishRelay<String>
        let navigateFromRegister: BehaviorRelay<Bool>
        let searchGifticonPlaces: PublishRelay<Void>
        let tapGifticonUse: ControlEvent<Void>
        let tapImageZoomIn: ControlEvent<Void>
        let tapMapZoomIn: ControlEvent<Void>
    }
    
    struct Output {
        let showGifticon: Driver<GifticonModel>
        let markSearchPlaces: Driver<[SearchPlace]>
        let showRegisterSuccessAlert: Signal<Void>
        let showFullGifticonImage: Signal<Void>
        let showFullMap: Signal<Void>
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private let gifticonService: GifticonServiceProtocol
    private let kakaoService: KakaoServiceProtocol
    
    private let gifticonModel = BehaviorRelay(value: GifticonModel())
    var gifticon: GifticonModel { gifticonModel.value }
    
    private let showRegisterSuccessAlert = PublishRelay<Void>()
    private let searchPlaces = BehaviorRelay<[SearchPlace]>(value: [])
    var places: [SearchPlace] { searchPlaces.value }
    
    init(
        gifticonService: GifticonServiceProtocol,
        kakaoService: KakaoServiceProtocol
    ) {
        self.gifticonService = gifticonService
        self.kakaoService = kakaoService
    }
    
    func transform(input: Input) -> Output {
        handleViewWillAppear(input: input)
        handleNavigateFromRegister(input: input)
        handleTapGifticonUse(input: input)
        handleSearchGifticonPlaces(input: input)
        
        return Output(
            showGifticon: gifticonModel.asDriver(),
            markSearchPlaces: searchPlaces.asDriver(),
            showRegisterSuccessAlert: showRegisterSuccessAlert.asSignal(),
            showFullGifticonImage: input.tapImageZoomIn.asSignal(),
            showFullMap: input.tapMapZoomIn.asSignal()
        )
    }
    
    private func handleViewWillAppear(input: GifticonDetailViewModel.Input) {
        input.viewWillAppear
            .flatMap { [unowned self] gifticonId in
                gifticonService.fetchGifticon(gifticonId: gifticonId)
            }.subscribe(onNext: { [unowned self] gifticon in
                gifticonModel.accept(gifticon.toModel())
            }).disposed(by: disposeBag)
    }
    
    private func handleNavigateFromRegister(input: GifticonDetailViewModel.Input) {
        Observable.combineLatest(
            input.viewWillAppear,
            input.navigateFromRegister
        ).subscribe(onNext: { [unowned self] _, isFrormRegister in
            if isFrormRegister {
                showRegisterSuccessAlert.accept(())
            }
        }).disposed(by: disposeBag)
    }
    
    private func handleTapGifticonUse(input: GifticonDetailViewModel.Input) {
        input.tapGifticonUse
            .flatMap { [unowned self] in
                gifticonService.updateGifticon(
                    gifticonId: gifticonModel.value.gifticonId,
                    name: nil,
                    expireDate: nil,
                    gifticonStore: nil,
                    memo: nil,
                    used: !gifticonModel.value.used
                )
            }.subscribe(
                onNext: { [unowned self] isSuccess in
                    if isSuccess {
                        input.viewWillAppear.accept(gifticonModel.value.gifticonId)
                    }
                }
            ).disposed(by: disposeBag)
    }
    
    private func handleSearchGifticonPlaces(input: GifticonDetailViewModel.Input) {
        input.searchGifticonPlaces
            .flatMap { [unowned self] _ -> Observable<Result<SearchPlaceByKeywordResponse, URLError>> in
                let storeType = gifticonModel.value.gifticonStore
                let keyword = storeType.rawValue
                
                guard storeType != StoreType.OTHERS && storeType != StoreType.ALL else {
                    return Observable.just(Result.failure(URLError(URLError.Code.unknown)))
                }
                
                guard let latitude = LocationManager.shared.latitude else {
                    return Observable.just(Result.failure(URLError(URLError.Code.unknown)))
                }
                guard let longitude = LocationManager.shared.longitude else {
                    return Observable.just(Result.failure(URLError(URLError.Code.unknown)))
                }
                
                return kakaoService.searchPlaceByKeyword(
                    query: keyword,
                    x: String(longitude),
                    y: String(latitude),
                    radius: 2000
                )
            }.subscribe(onNext: { [unowned self] result in
                switch result {
                case .success(let response):
                    MOALogger.logd("\(response)")
                    searchPlaces.accept(response.places.map { $0.toModel() })
                case .failure(let error):
                    MOALogger.loge(error.localizedDescription)
                }
            }).disposed(by: disposeBag)
    }
}
