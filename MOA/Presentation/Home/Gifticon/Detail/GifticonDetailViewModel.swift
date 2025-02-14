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
    private let kakaoService: KakaoServiceProtocol
    private let gifticonService: GifticonServiceProtocol
    
    let gifticonRelay = BehaviorRelay(value: GifticonModel())
    var gifticon: GifticonModel { gifticonRelay.value }
    
    let searchPlaceRelay = BehaviorRelay<[SearchPlace]>(value: [])
    
    init(
        gifticonService: GifticonServiceProtocol,
        kakaoService: KakaoServiceProtocol
    ) {
        self.gifticonService = gifticonService
        self.kakaoService = kakaoService
    }
    
    func fetchGifticon(gifticonId: String) {
        MOALogger.logd()
        gifticonService.fetchGifticon(gifticonId: gifticonId)
            .subscribe(
                onNext: { [unowned self] gifticon in
                    MOALogger.logd("\(gifticon)")
                    self.gifticonRelay.accept(gifticon.toModel())
                },
                onError: { error in
                    MOALogger.loge(error.localizedDescription)
                }
            ).disposed(by: disposeBag)
    }
    
    func updateGifticonUsed(gifticonId: String) {
        MOALogger.logd()
        gifticonService.updateGifticon(
            gifticonId: gifticonId,
            name: nil,
            expireDate: nil,
            gifticonStore: nil,
            memo: nil,
            used: !gifticon.used
        ).subscribe(
            onNext: { [unowned self] isSuccess in
                if isSuccess {
                    fetchGifticon(gifticonId: gifticonId)
                }
            },
            onError: { error in
                MOALogger.loge(error.localizedDescription)
            }
        ).disposed(by: disposeBag)
    }
    
    func searchPlaceByKeyword() {
        MOALogger.logd()
        
        let storeType = gifticon.gifticonStore
        guard storeType != StoreType.OTHERS && storeType != StoreType.ALL else { return }
        let keyword = storeType.rawValue
        
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
