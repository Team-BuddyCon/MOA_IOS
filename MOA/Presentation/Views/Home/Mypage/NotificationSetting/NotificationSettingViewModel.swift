//
//  NotificationSettingViewModel.swift
//  MOA
//
//  Created by 오원석 on 3/4/25.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

final class NotificationSettingViewModel: BaseViewModel, ViewModelType {
    struct Input {
        let viewWillAppear: PublishRelay<Void>
        let tapUnSwitchedView: ControlEvent<UITapGestureRecognizer>
        let changeNotiSwitch: ControlProperty<Bool>
        let tapNotiDday14: ControlEvent<UITapGestureRecognizer>
        let tapNotiDday7: ControlEvent<UITapGestureRecognizer>
        let tapNotiDday3: ControlEvent<UITapGestureRecognizer>
        let tapNotiDday1: ControlEvent<UITapGestureRecognizer>
        let tapNotiDday: ControlEvent<UITapGestureRecognizer>
    }
    
    struct Output {
        let goNotificationSetting: Signal<UITapGestureRecognizer>
        let updateNotiSwitch: Signal<Bool>
        let updateNotiDday14: Signal<UITapGestureRecognizer>
        let updateNotiDday7: Signal<UITapGestureRecognizer>
        let updateNotiDday3: Signal<UITapGestureRecognizer>
        let updateNotiDday1: Signal<UITapGestureRecognizer>
        let updateNotiDday: Signal<UITapGestureRecognizer>
    }
    
    private let gifticonService: GifticonServiceProtocol
    private let gifticons = BehaviorRelay<[GifticonModel]>(value: [])
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func transform(input: Input) -> Output {
        input.viewWillAppear
            .flatMap { [unowned self] in
                gifticonService.fetchGifticons(
                    category: StoreCategory.ALL,
                    sortType: SortType.EXPIRE_DATE
                )
            }.subscribe(onNext: { [unowned self] gifticons in
                self.gifticons.accept(gifticons.map { $0.toModel() })
            }).disposed(by: disposeBag)
        
    
        return Output(
            goNotificationSetting: input.tapUnSwitchedView.asSignal(),
            updateNotiSwitch: input.changeNotiSwitch.asSignal(onErrorJustReturn: false),
            updateNotiDday14: input.tapNotiDday14.asSignal(),
            updateNotiDday7: input.tapNotiDday7.asSignal(),
            updateNotiDday3: input.tapNotiDday3.asSignal(),
            updateNotiDday1: input.tapNotiDday1.asSignal(),
            updateNotiDday: input.tapNotiDday.asSignal()
        )
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
