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
    
    let gifticons = BehaviorRelay<[AvailableGifticon]>(value: [])
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func fetchAllGifticons() {
        MOALogger.logd()
        
        Observable.combineLatest(
            categoryRelay,
            sortTypeRelay
        ).flatMap { category, sortType in
            FirebaseManager.shared.getAllGifticon(
                categoryType: category,
                sortType: sortType
            )
        }.subscribe(onNext: { [unowned self] gifticons in
            self.gifticons.accept(gifticons)
        }).disposed(by: disposeBag)
    }
    
    func refresh() {
        clearPagingData()
    }
    
    func changeCategory(category: StoreCategory) {
        MOALogger.logd()
        clearPagingData()
        categoryRelay.accept(category)
    }
    
    func changeSort(type: SortType) {
        MOALogger.logd()
        clearPagingData()
        sortTypeRelay.accept(type)
    }
    
    private func clearPagingData() {
        gifticons.accept([])
    }
}
