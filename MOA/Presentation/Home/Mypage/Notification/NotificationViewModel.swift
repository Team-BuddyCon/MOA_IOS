//
//  NotificationViewModel.swift
//  MOA
//
//  Created by 오원석 on 3/4/25.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class NotificationViewModel: BaseViewModel {
    private let gifticonService: GifticonServiceProtocol
    let gifticons = BehaviorRelay<[GifticonModel]>(value: [])
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func fetchAllGifticons() {
        MOALogger.logd()
        
        gifticonService.fetchGifticons(
            category: StoreCategory.ALL,
            sortType: SortType.EXPIRE_DATE
        ).subscribe(
            onNext: { [unowned self] gifticons in
                let models = gifticons.map { $0.toModel() }
                self.gifticons.accept(models)
            },
            onError: { error in
                MOALogger.loge(error.localizedDescription)
            }
        ).disposed(by: disposeBag)
    }
    
    func updateNotifications() {
        MOALogger.logd()
        NotificationManager.shared.removeAll()
        gifticons.value.forEach { gifticon in
            NotificationManager.shared.register(
                gifticon.expireDate,
                name: gifticon.name,
                gifticonId: gifticon.gifticonId
            )
        }
    }
}
