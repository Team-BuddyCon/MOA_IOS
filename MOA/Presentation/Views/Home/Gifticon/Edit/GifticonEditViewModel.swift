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
    
    struct Input {
        let tapImageZoomIn: ControlEvent<Void>
        let tapDelete: ControlEvent<Void>
        let tapComplete: ControlEvent<Void>
        let deleteGifticon: PublishRelay<(String, String, String)>
        let updateGifticon: PublishRelay<(GifticonModel, String, String, String, String?)>
    }
    
    struct Output {
        let showFullGifticonImage: Signal<Void>
        let showDeleteAlert: Signal<Void>
        let showCompleteAlert: Signal<Void>
        let showDeleteCompleteAlert: Signal<Void>
        let showUpdateCompleteAlert: Signal<Void>
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private let gifticonService: GifticonServiceProtocol
    private let deleteComplete = PublishRelay<Void>()
    private let updateComplete = PublishRelay<Void>()
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func transform(input: Input) -> Output {
        handleDeleteGifticon(input: input)
        handleUpdateGifticon(input: input)
        
        return Output(
            showFullGifticonImage: input.tapImageZoomIn.asSignal(),
            showDeleteAlert: input.tapDelete.asSignal(),
            showCompleteAlert: input.tapComplete.asSignal(),
            showDeleteCompleteAlert: deleteComplete.asSignal(),
            showUpdateCompleteAlert: updateComplete.asSignal()
        )
    }
    
    private func handleUpdateGifticon(input: GifticonEditViewModel.Input) {
        input.updateGifticon
            .flatMap { [unowned self] gifticon, name, expireDate, gifticonStore, memo in
                gifticonService.updateGifticon(
                    gifticonId: gifticon.gifticonId,
                    name: name,
                    expireDate: expireDate,
                    gifticonStore: gifticonStore,
                    memo: memo,
                    used: nil
                ).map { isSuccess in
                    (isSuccess, gifticon, expireDate, name)
                }
            }.subscribe(onNext: { [unowned self] isSuccess, gifticon, expireDate, name in
                if isSuccess {
                    updateNotification(
                        prev_expireDate: gifticon.expireDate,
                        prev_name: gifticon.name,
                        prev_gifticonId: gifticon.gifticonId,
                        next_expireDate: expireDate,
                        next_name: name,
                        next_gifticonId: gifticon.gifticonId
                    )
                    updateComplete.accept(())
                }
            }).disposed(by: disposeBag)
    }
    
    private func handleDeleteGifticon(input: GifticonEditViewModel.Input) {
        input.deleteGifticon
            .flatMap { [unowned self] gifticonId, name, expireDate in
                gifticonService.deleteGifticon(gifticonId: gifticonId).map { isSuccess in
                    (isSuccess, gifticonId, name, expireDate)
                }
            }.subscribe(onNext: { [unowned self] isSuccess, gifticonId, name, expireDate in
                if isSuccess {
                    NotificationManager.shared.remove(
                        expireDate,
                        name: name,
                        gifticonId: gifticonId
                    )
                    deleteComplete.accept(())
                }
            }).disposed(by: disposeBag)
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
