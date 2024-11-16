//
//  GifticonViewModel.swift
//  MOA
//
//  Created by 오원석 on 11/14/24.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class GifticonViewModel: BaseViewModel {
    
    private let gifticonService: GifticonServiceProtocol
    private let sortTypeRelay: BehaviorRelay<SortType> = BehaviorRelay(value: .EXPIRE_DATE)
    var sortType: SortType { sortTypeRelay.value }
    private let pageNumberRelay = BehaviorRelay(value: 0)
    var pageNumber: Int { pageNumberRelay.value }
    
    var isScrollEnded = false
    var isLoading = false
    var isChangedOptions = false
    
    let gifticons = BehaviorRelay<[AvailableGifticon]>(value: [])
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func fetch() {
        MOALogger.logd()
        Observable.combineLatest(
            sortTypeRelay,
            pageNumberRelay
        ).flatMapLatest { (sortType, pageNumber) in
            return self.gifticonService
                .fetchAvailableGifticon(
                    pageNumber: pageNumber,
                    rowCount: 10,
                    storeCateogry: nil,
                    storeType: nil,
                    sortType: sortType
                )
        }.map { [weak self] result -> [AvailableGifticon] in
            guard let self = self else {
                MOALogger.loge()
                return []
            }
            switch result {
            case .success(let response):
                let data = response.gifticonInfos.content.map { $0.toModel() }
                if data.isEmpty {
                    isScrollEnded = true
                }
                return data
            case .failure(let error):
                MOALogger.loge(error.localizedDescription)
                isScrollEnded = true
                return []
            }
        }.subscribe(onNext: { [weak self] data in
            guard let self = self else {
                MOALogger.loge()
                return
            }
            
            isLoading = false
            let current = gifticons.value
            gifticons.accept(current + data)
        }).disposed(by: disposeBag)
    }
    
    func fetchMore() {
        MOALogger.logd()
        pageNumberRelay.accept(pageNumber + 1)
    }
    
    func changeSort(type: SortType) {
        MOALogger.logd()
        isChangedOptions = true
        clearPagingData()
        sortTypeRelay.accept(type)
    }
    
    private func clearPagingData() {
        isScrollEnded = false
        gifticons.accept([])
        pageNumberRelay.accept(0)
    }
}
