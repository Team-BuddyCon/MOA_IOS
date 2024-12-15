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
    
    func deleteGifticon(gifticonId: Int) {
        gifticonService.fetchDeleteGifticon(gifticonId: gifticonId)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    MOALogger.logd("\(response)")
                    
                    if response.isSuccess {
                        navigationResult.accept(.delete)
                    }
                case .failure(let error):
                    MOALogger.loge(error.localizedDescription)
                }
            }).disposed(by: disposeBag)
    }
    
    func updateGifticon(
        gifticonId: Int,
        name: String,
        expireDate: String,
        store: String,
        memo: String?
    ) {
        gifticonService.fetchUpdateGifticon(
            gifticonId: gifticonId,
            name: name,
            expireDate: expireDate,
            store: store,
            memo: memo
        ).subscribe(onNext: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                MOALogger.logd("\(response)")
                
                if response.isSuccess {
                    navigationResult.accept(.update)
                }
            case .failure(let error):
                MOALogger.loge(error.localizedDescription)
            }
        }).disposed(by: disposeBag)
    }
}
