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
    private let gifticonService: GifticonServiceProtocol
    private let kakaoService: KakaoServiceProtocol
    
    let detailGifticonRelay = BehaviorRelay(value: DetailGifticon())
    var detailGifticon: DetailGifticon { detailGifticonRelay.value }
    
    // 사용여부는 usedRelay로 관리
    var usedRelay = PublishRelay<Bool>()
    private var used: Bool = false
    
    init(
        gifticonService: GifticonServiceProtocol,
        kakaoService: KakaoServiceProtocol
    ) {
        self.gifticonService = gifticonService
        self.kakaoService = kakaoService
    }
    
    func fetchDetail(gifticonId: Int) {
        gifticonService.fetchDetailGifticon(gifticonId: gifticonId)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    MOALogger.logd("\(response)")
                    detailGifticonRelay.accept(response.info.toModel())
                    usedRelay.accept(response.info.used)
                    used = response.info.used
                case .failure(let error):
                    MOALogger.loge(error.localizedDescription)
                }
            }).disposed(by: disposeBag)
    }
    
    func fetchUpdateUsed(gifticonId: Int) {
        gifticonService.fetchUpdateUsedGifticon(gifticonId: gifticonId, used: !used)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    MOALogger.logd("\(response)")
                    usedRelay.accept(!used)
                    used = !used
                case .failure(let error):
                    MOALogger.loge(error.localizedDescription)
                }
            }).disposed(by: disposeBag)
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
            case .failure(let error):
                MOALogger.loge(error.localizedDescription)
            }
        }).disposed(by: disposeBag)
    }
}
