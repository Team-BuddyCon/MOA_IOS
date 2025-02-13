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
    
    let gifticonRelay = BehaviorRelay(value: AvailableGifticon())
    var gifticon: AvailableGifticon { gifticonRelay.value }
    
    let detailGifticonRelay = BehaviorRelay(value: DetailGifticon())
    var detailGifticon: DetailGifticon { detailGifticonRelay.value }
    
    // 사용여부는 usedRelay로 관리
    var usedRelay = PublishRelay<Bool>()
    private var used: Bool = false
    
    let searchPlaceRelay = BehaviorRelay<[SearchPlace]>(value: [])
    
    init(kakaoService: KakaoServiceProtocol) {
        self.kakaoService = kakaoService
    }
    
    func fetchDetail(gifticonId: String) {
        MOALogger.logd()
        FirebaseManager.shared.getGifticon(gifticonId: gifticonId)
            .subscribe(onNext: { [unowned self] gifticon in
                MOALogger.logd("\(gifticon)")
                gifticonRelay.accept(gifticon)
                //detailGifticonRelay.accept(gifticon)
//                switch result {
//                case .success(let response):
//                    MOALogger.logd("\(response)")
//                    detailGifticonRelay.accept(response.info.toModel())
//                    usedRelay.accept(response.info.used)
//                    used = response.info.used
//                case .failure(let error):
//                    MOALogger.loge(error.localizedDescription)
//                }
            }).disposed(by: disposeBag)
    }
    
    func updateGifticon(gifticonId: String) {
        MOALogger.logd()
        FirebaseManager.shared.updateGifticon(gifticonId: gifticonId, used: !gifticon.used)
            .subscribe(onNext: { [unowned self] success in
                MOALogger.logd("\(success)")
                if success {
                    fetchDetail(gifticonId: gifticonId)
                }
            }).disposed(by: disposeBag)
//        gifticonService.fetchUpdateUsedGifticon(gifticonId: gifticonId, used: !used)
//            .subscribe(onNext: { [weak self] result in
//                guard let self = self else { return }
//                switch result {
//                case .success(let response):
//                    MOALogger.logd("\(response)")
//                    usedRelay.accept(!used)
//                    used = !used
//                case .failure(let error):
//                    MOALogger.loge(error.localizedDescription)
//                }
//            }).disposed(by: disposeBag)
    }
    
    func searchByKeyword(keyword: String) {
        let longitude = LocationManager.shared.longitude ?? LocationManager.defaultLongitude
        let latitude = LocationManager.shared.latitude ?? LocationManager.defaultLatitude
        
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
