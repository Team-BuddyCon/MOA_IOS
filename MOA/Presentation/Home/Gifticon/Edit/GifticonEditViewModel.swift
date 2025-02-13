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
    let navigationResult = PublishRelay<EditResult>()
    
    func deleteGifticon(gifticonId: String) {
        FirebaseManager.shared.deleteGifticon(gifticonId: gifticonId)
            .subscribe(onNext: { [unowned self] success in
                if success {
                    navigationResult.accept(.delete)
                }
            }).disposed(by: disposeBag)
    }
    
    func updateGifticon(
        gifticonId: String,
        name: String,
        expireDate: String,
        gifticonStore: String,
        memo: String?
    ) {
        FirebaseManager.shared.updateGifticon(
            gifticonId: gifticonId,
            name: name,
            expireDate: expireDate,
            gifticonStore: gifticonStore,
            memo: memo
        ).subscribe(onNext: { [unowned self] success in
            if success {
                navigationResult.accept(.update)
            }
        }).disposed(by: disposeBag)
//        gifticonService.fetchUpdateGifticon(
//            gifticonId: gifticonId,
//            name: name,
//            expireDate: expireDate,
//            store: store,
//            memo: memo
//        ).subscribe(onNext: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let response):
//                MOALogger.logd("\(response)")
//                
//                if response.isSuccess {
//                    navigationResult.accept(.update)
//                }
//            case .failure(let error):
//                MOALogger.loge(error.localizedDescription)
//            }
//        }).disposed(by: disposeBag)
    }
}
