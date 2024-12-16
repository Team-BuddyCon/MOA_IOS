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
                case .failure(let error):
                    MOALogger.loge(error.localizedDescription)
                }
            }).disposed(by: disposeBag)
    }
}
