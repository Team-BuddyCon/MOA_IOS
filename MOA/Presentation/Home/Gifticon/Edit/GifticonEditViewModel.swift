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
                        prev_expireDate: prev_model.expireDate,
                        prev_name: prev_model.name,
                        prev_gifticonId: prev_model.gifticonId,
                        next_expireDate: expireDate,
                        next_name: name,
                        next_gifticonId: gifticonId
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
                    NotificationManager.shared.remove(
                        expireDate,
                        name: name,
                        gifticonId: gifticonId
                    )
                    navigationResult.accept(.delete)
                },
                onError: { error in
                    MOALogger.loge(error.localizedDescription)
                }
            ).disposed(by: disposeBag)
    }
    
    private func updateNotification(
        prev_expireDate: String,
        prev_name: String,
        prev_gifticonId: String,
        next_expireDate: String,
        next_name: String,
        next_gifticonId: String
    ) {
        MOALogger.logd()
        
        // 이전 expireDate, name, gifticonId로 된 알림 제거
        NotificationManager.shared.remove(
            prev_expireDate,
            name: prev_name,
            gifticonId: prev_gifticonId
        )
        
        // 신규 알림 등록
        NotificationManager.shared.register(
            next_expireDate,
            name: next_name,
            gifticonId: next_gifticonId
        )
    }
}
