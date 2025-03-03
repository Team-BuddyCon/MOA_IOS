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
    
    func updateNotifications(dday: NotificationDday) {
        MOALogger.logd()
        NotificationManager.shared.removeAll()
        
        let expireGroup = Dictionary(grouping: gifticons.value) { $0.expireDate }
        let expireDateGroup = Dictionary(uniqueKeysWithValues: expireGroup.compactMap {
            if let date = $0.key.toDate(format: AVAILABLE_GIFTICON_TIME_FORMAT) {
                return (date, $0.value)
            } else {
                return nil
            }
        })
        
        expireDateGroup.forEach {
            let expireDate = $0.key.toString(format: AVAILABLE_GIFTICON_TIME_FORMAT)
            let notificationDate = dday.getNotificationDate(target: $0.key)
            let gifticons = $0.value
            
            guard let notificationDate = notificationDate else { return }
            if notificationDate <= Date() { return }
            
            MOALogger.logd("notificationDate: \(notificationDate), expireDate: \(expireDate)")
            
            gifticons.forEach { gifticon in
                NotificationManager.shared.register(
                    expireDate,
                    date: notificationDate,
                    name: gifticon.name
                )
            }
        }
    }
}
