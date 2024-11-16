//
//  GifticonViewModel.swift
//  MOA
//
//  Created by 오원석 on 11/14/24.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class GifticonViewModel: BaseViewModel {
    private let gifticonService: GifticonServiceProtocol
    
    var isScrollEnded = false
    var pageNumber = 0
    var isLoading = false
    
    private let gifticonsRelay: BehaviorRelay<[AvailableGifticon]> = BehaviorRelay(value: [])
    var gifticonDriver: Driver<[AvailableGifticon]> {
        gifticonsRelay.asDriver(onErrorJustReturn: [])
    }
    
    var gifticons: [AvailableGifticon] { gifticonsRelay.value }
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func fetchAvailableGifticon() {
        isLoading = true
        
        
        gifticonService
            .fetchAvailableGifticon(
                pageNumber: pageNumber,
                rowCount: 6,
                storeCateogry: nil,
                storeType: nil,
                sortType: .EXPIRE_DATE
            ).subscribe(
                onNext: { [weak self] result in
                    switch result {
                    case .success(let response):
                        MOALogger.logd("\(response)")
                        
                        if response.gifticonInfos.content.isEmpty {
                            self?.isScrollEnded = true
                            return
                        }
                        
                        if let gifticons = self?.gifticons {
                            self?.gifticonsRelay.accept(gifticons + response.gifticonInfos.content.map { $0.toModel() })
                        }
                    case .failure(let error):
                        MOALogger.loge(error.localizedDescription)
                    }
                    self?.isLoading = false
                }
            ).disposed(by: disposeBag)
    }
}
