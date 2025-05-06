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
    let gifticonRelay: BehaviorRelay<[GifticonModel]> = BehaviorRelay(value: [])
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func fetchUsedGifticons() {
        gifticonService.fetchUsedGifticons()
            .subscribe(
                onNext: { [unowned self] gifticons in
                    gifticonRelay.accept(gifticons.map { $0.toModel() })
                },
                onError: { error in
                    MOALogger.loge(error.localizedDescription)
                }
            ).disposed(by: disposeBag)
    }
}
