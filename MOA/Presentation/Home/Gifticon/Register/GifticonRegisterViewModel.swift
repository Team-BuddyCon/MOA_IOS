//
//  GifticonRegisterViewModel.swift
//  MOA
//
//  Created by 오원석 on 12/9/24.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

final class GifticonRegisterViewModel: BaseViewModel {
    private let gifticonService: GifticonServiceProtocol
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func createGifticon(
        image: UIImage,
        name: String,
        expireDate: String,
        gifticonStore: String,
        memo: String?,
        onLoading: @escaping () -> Void,
        onSucess: @escaping (String) -> Void,
        onError: @escaping () -> Void
    ) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            onLoading()
            gifticonService.createGifticon(
                data: data,
                name: name,
                expireDate: expireDate,
                gifticonStore: gifticonStore,
                memo: memo
            ).subscribe(
                onNext: { gifticonId in
                    if !gifticonId.isEmpty {
                        self.registerNotification(
                            expireDate: expireDate,
                            name: name
                        )
                        onSucess(gifticonId)
                    }
                },
                onError: { error in
                    MOALogger.loge(error.localizedDescription)
                    onError()
                }
            ).disposed(by: disposeBag)
        }
    }
    
    private func registerNotification(
        expireDate: String,
        name: String
    ) {
        MOALogger.logd()
        guard UserPreferences.isNotificationOn() else { return }
        
        let date = expireDate.toDate(format: AVAILABLE_GIFTICON_TIME_FORMAT)
        let notificationDate = UserPreferences.getNotificationDday().getNotificationDate(target: date)
        
        guard let notificationDate = notificationDate else { return }
        if notificationDate <= Date() { return }
        
        NotificationManager.shared.register(
            expireDate,
            date: notificationDate,
            name: name
        )
    }
}
