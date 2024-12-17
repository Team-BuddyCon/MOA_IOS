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
    
    private let categoryRelay: BehaviorRelay<StoreCategory> = BehaviorRelay(value: .All)
    private let sortTypeRelay: BehaviorRelay<SortType> = BehaviorRelay(value: .EXPIRE_DATE)
    var sortType: SortType { sortTypeRelay.value }
    var sortTitle: Driver<String> {
        sortTypeRelay
            .map { $0.rawValue }
            .asDriver(onErrorJustReturn: SortType.EXPIRE_DATE.rawValue)
    }
    
    private let pageNumberRelay = BehaviorRelay(value: 0)
    var pageNumber: Int { pageNumberRelay.value }
    
    // 기프티콘 마지막 데이터 시 true
    var isScrollEnded = false
    
    // 기프티콘 목록 API 호출 중
    var isLoading = false
    
    // 유효기간, 카테고리 변경 시에는 fetch 하지 않도록
    var isChangedOptions = false
    
    // 상세화면
    var selectedIndex: Int? = nil
    
    let gifticons = BehaviorRelay<[AvailableGifticon]>(value: [])
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func fetch() {
        MOALogger.logd()
        Observable.combineLatest(
            categoryRelay,
            sortTypeRelay,
            pageNumberRelay
        ).flatMapLatest { (category, sortType, pageNumber) in
            return self.gifticonService
                .fetchAvailableGifticon(
                    pageNumber: pageNumber,
                    rowCount: 10,
                    storeCateogry: category,
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
            
            let current = gifticons.value
            isLoading = false
            gifticons.accept(current + data)
        }).disposed(by: disposeBag)
    }
    
    func refresh() {
        if let index = selectedIndex {
            isLoading = true
            gifticonService.fetchAvailableGifticon(
                pageNumber: index / 10,
                rowCount: 10,
                storeCateogry: categoryRelay.value,
                storeType: nil,
                sortType: sortTypeRelay.value
            ).map { result -> [AvailableGifticon] in
                switch result {
                case .success(let response):
                    return response.gifticonInfos.content.map { $0.toModel() }
                case .failure(let error):
                    MOALogger.loge(error.localizedDescription)
                    return []
                }
            }.subscribe(onNext: { [weak self] data in
                guard let self = self else {
                    MOALogger.loge()
                    return
                }
                
                isLoading = false
                selectedIndex = nil
                var current = gifticons.value
                let startIndex = (index / 10) * 10
                let endIndex = startIndex + data.count
                current.replaceSubrange(startIndex..<endIndex, with: data)
                gifticons.accept(current)
            }).disposed(by: disposeBag)
        } else {
            clearPagingData()
        }
    }
    
    func fetchMore() {
        MOALogger.logd()
        pageNumberRelay.accept(pageNumber + 1)
    }
    
    func changeCategory(category: StoreCategory) {
        MOALogger.logd()
        isChangedOptions = true
        clearPagingData()
        categoryRelay.accept(category)
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
