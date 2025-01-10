//
//  UnAvailableGifticonViewModel.swift
//  MOA
//
//  Created by 오원석 on 1/10/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

final class UnAvailableGifticonViewModel: BaseViewModel {
    
    private let gifticonService: GifticonServiceProtocol
    
    private let pageNumberRelay = BehaviorRelay(value: 0)
    var pageNumber: Int { pageNumberRelay.value }
    
    var isScrollEnded = false
    var isLoading = false
    
    let count = BehaviorRelay(value: 0)
    let gifticons = BehaviorRelay<[UnAvailableGifticon]>(value: [])
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func fetch() {
        MOALogger.logd()
        pageNumberRelay.flatMapLatest { pageNumber in
            return self.gifticonService
                .fetchUnAvailableGifticon(
                    pageNumber: pageNumber,
                    rowCount: 10
                )
        }.map { [weak self] result -> [UnAvailableGifticon] in
            guard let self = self else {
                MOALogger.loge()
                return []
            }
            
            switch result {
            case .success(let response):
                let data = response.gifticonInfos.content.map {
                    $0.toModel()
                }
                
                if data.isEmpty {
                    isScrollEnded = true
                    return []
                }
                return data
            case .failure(let error):
                MOALogger.logd(error.localizedDescription)
                isScrollEnded = true
                return []
            }
        }.subscribe(onNext: { [weak self] data in
            guard let self = self else {
                MOALogger.logd()
                return
            }
            
            let current = gifticons.value.filter { $0.gifticonId != Int.min }
            isLoading = false
            gifticons.accept(current + data)
        }).disposed(by: disposeBag)
    }
    
    func fetchGifticonCount() {
        gifticonService.fetchGifticonCount(
            used: true,
            storeCateogry: nil,
            storeType: nil,
            remainingDays: nil
        ).subscribe(onNext: { [weak self] result in
            guard let self = self else {
                MOALogger.loge()
                return
            }
            
            switch result {
            case .success(let response):
                count.accept(response.count)
            case .failure(let error):
                MOALogger.loge(error.localizedDescription)
            }
        }).disposed(by: disposeBag)
    }
    
    func refresh() {
        clearPagingData()
    }
    
    func fetchMore() {
        MOALogger.logd()
        pageNumberRelay.accept(pageNumber + 1)
    }
    
    private func clearPagingData() {
        isScrollEnded = false
        gifticons.accept([])
        pageNumberRelay.accept(0)
    }
}
