//
//  NotificationViewModel.swift
//  MOA
//
//  Created by 오원석 on 3/21/25.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class NotificationViewModel: BaseViewModel {
    
    let notificationsRelay = BehaviorRelay<[NotificationModel]>(value: [])
    var notifcationModels: [NotificationModel] {
        notificationsRelay.value
    }
    
    override init() {
        let notifications = LocalNotificationDataManager.shared.fetchNotification()
        notificationsRelay.accept(notifications)
    }
}
