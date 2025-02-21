//
//  WithDrawViewModel.swift
//  MOA
//
//  Created by 오원석 on 2/1/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

final class WithDrawViewModel: BaseViewModel {
    
    let gifticonService: GifticonServiceProtocol
    let phrase = BehaviorRelay(value: WithDrawPhrase.Reason)
    let reason = BehaviorRelay(value: WithDrawReason.NotUseApp)
    let logoutTrigger = PublishRelay<Bool>()
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func deleteGifticons() {
        gifticonService.deleteGifticons()
            .subscribe(
                onNext: { isSuccess in
                    self.logoutTrigger.accept(isSuccess)
                },
                onError: { error in
                    MOALogger.loge(error.localizedDescription)
                    self.logoutTrigger.accept(false)
                }
            ).disposed(by: disposeBag)
    }
}

