//
//  MypageViewModel.swift
//  MOA
//
//  Created by 오원석 on 1/11/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

final class MypageViewModel: BaseViewModel, ViewModelType {
    
    struct Input {
        let viewWillAppear: PublishRelay<Void>
        let tapUnavilableBox: ControlEvent<UITapGestureRecognizer>
        let tapNotification: PublishRelay<Void>
        let tapInquery: PublishRelay<Void>
        let tapVersion: PublishRelay<Void>
        let tapPolicy: PublishRelay<Void>
        let tapOpenSourceLicense: PublishRelay<Void>
        let tapLogout: PublishRelay<Void>
        let tapSignOut: PublishRelay<Void>
    }
    
    struct Output {
        let showUsedGifticonCount: Driver<String>
        let tapUnavilableBox: Signal<Void>
        let showNotificationSetting: Signal<Void>
        let showInqueryAlert: Signal<Void>
        let showVersion: Signal<Void>
        let showPolicy: Signal<Void>
        let showOpenSourceLicense: Signal<Void>
        let showLogoutAlert: Signal<Void>
        let showSignOut: Signal<Void>
    }
    
    private let gifticonService: GifticonServiceProtocol
    
    private let usedGifticonCount = BehaviorRelay<String>(value: String(format: UNAVAILABLE_GIFTICON_COUNT_FORMAT, 0))
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func transform(input: Input) -> Output {
        input.viewWillAppear
            .flatMap { [unowned self] in
                gifticonService.fetchUsedGifticons()
            }.subscribe(onNext: { [unowned self] gifticons in
                usedGifticonCount.accept(String(format: UNAVAILABLE_GIFTICON_COUNT_FORMAT, gifticons.count))
            }).disposed(by: disposeBag)
        
   
        
        return Output(
            showUsedGifticonCount: usedGifticonCount.asDriver(),
            tapUnavilableBox: input.tapUnavilableBox.map { _ in }.asSignal(onErrorJustReturn: ()),
            showNotificationSetting: input.tapNotification.asSignal(),
            showInqueryAlert: input.tapInquery.asSignal(),
            showVersion: input.tapVersion.asSignal(),
            showPolicy: input.tapPolicy.asSignal(),
            showOpenSourceLicense: input.tapOpenSourceLicense.asSignal(),
            showLogoutAlert: input.tapLogout.asSignal(),
            showSignOut: input.tapSignOut.asSignal()
        )
    }
}
