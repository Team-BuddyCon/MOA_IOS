//
//  GifticonEditViewModel.swift
//  MOA
//
//  Created by 오원석 on 12/15/24.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class GifticonEditViewModel: BaseViewModel {
    
    private let gifticonService: GifticonServiceProtocol
    let navigationResult = PublishRelay<EditResult>()
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func updateGifticon(
        _ prev_model: GifticonModel,
        gifticonId: String,
        name: String,
        expireDate: String,
        gifticonStore: String,
        memo: String?
    ) {
        gifticonService.updateGifticon(
            gifticonId: gifticonId,
            name: name,
            expireDate: expireDate,
            gifticonStore: gifticonStore,
            memo: memo,
            used: nil
        ).subscribe(
            onNext: { [unowned self] isSuccess in
                if isSuccess {
                    updateNotification(
                        prev_id: prev_model.expireDate,
                        prev_name: prev_model.name,
                        identifier: expireDate,
                        expireDate: expireDate.toDate(format: AVAILABLE_GIFTICON_TIME_FORMAT),
                        name: name
                    )
                    navigationResult.accept(.update)
                }
            },
            onError: { error in
                MOALogger.loge(error.localizedDescription)
            }
        ).disposed(by: disposeBag)
    }
    
    func deleteGifticon(
        gifticonId: String,
        name: String,
        expireDate: String
    ) {
        gifticonService.deleteGifticon(gifticonId: gifticonId)
            .subscribe(
                onNext: { [unowned self] isSuccess in
                    removeNotification(identifier: expireDate, name: name)
                    navigationResult.accept(.delete)
                },
                onError: { error in
                    MOALogger.loge(error.localizedDescription)
                }
            ).disposed(by: disposeBag)
    }
    
    private func updateNotification(
        prev_id: String,
        prev_name: String,
        identifier: String,
        expireDate: Date?,
        name: String
    ) {
        MOALogger.logd()
        guard UserPreferences.isNotificationOn() else { return }
        
        NotificationManager.shared.remove(prev_id, name: prev_name)
        
        let notificationDate = UserPreferences.getNotificationDday().getNotificationDate(target: expireDate)
        
        guard let notificationDate = notificationDate else { return }
        if notificationDate <= Date() { return }
        
        NotificationManager.shared.register(
            identifier,
            date: notificationDate,
            name: name
        )
    }
    
    private func removeNotification(
        identifier: String,
        name: String
    ) {
        MOALogger.logd()
        guard UserPreferences.isNotificationOn() else { return }
        NotificationManager.shared.remove(identifier, name: name)
    }
}
