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
    
    let detailGifticonRelay = BehaviorRelay(value: DetailGifticon())
    var detailGifticon: DetailGifticon { detailGifticonRelay.value }
    
    // 사용여부는 usedRelay로 관리
    var usedRelay = PublishRelay<Bool>()
    private var used: Bool = false
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
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
}
