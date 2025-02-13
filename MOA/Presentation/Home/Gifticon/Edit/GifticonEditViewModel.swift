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
                    navigationResult.accept(.update)
                }
            },
            onError: { error in
                MOALogger.loge(error.localizedDescription)
            }
        ).disposed(by: disposeBag)
    }
    
    func deleteGifticon(gifticonId: String) {
        gifticonService.deleteGifticon(gifticonId: gifticonId)
            .subscribe(
                onNext: { [unowned self] isSuccess in
                    navigationResult.accept(.delete)
                },
                onError: { error in
                    MOALogger.loge(error.localizedDescription)
                }
            ).disposed(by: disposeBag)
    }
}
