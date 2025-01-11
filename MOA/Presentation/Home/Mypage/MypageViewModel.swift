//
//  MypageViewModel.swift
//  MOA
//
//  Created by 오원석 on 1/11/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

final class MypageViewModel: BaseViewModel {
    
    private let gifticonService: GifticonServiceProtocol
    let count = BehaviorRelay(value: 0)
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func fetchGifticonCount() {
        gifticonService.fetchGifticonCount(
            used: true,
            storeCateogry: nil,
            storeType: nil,
            remainingDays: nil
        ).subscribe(onNext: { [weak self] result in
            guard let self = self else {
                MOALogger.loge()
                return
            }
            
            switch result {
            case .success(let response):
                count.accept(response.count)
            case .failure(let error):
                MOALogger.loge(error.localizedDescription)
            }
        }).disposed(by: disposeBag)
    }
}
