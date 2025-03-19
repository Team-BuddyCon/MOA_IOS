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
    
    var isFirstFetch: Bool = true
    
    private let gifticonService: GifticonServiceProtocol
    
    private let categoryRelay: BehaviorRelay<StoreCategory> = BehaviorRelay(value: .ALL)
    private let sortTypeRelay: BehaviorRelay<SortType> = BehaviorRelay(value: .EXPIRE_DATE)
    var sortType: SortType { sortTypeRelay.value }
    var sortTitle: Driver<String> {
        sortTypeRelay
            .map { $0.rawValue }
            .asDriver(onErrorJustReturn: SortType.EXPIRE_DATE.rawValue)
    }
    
    let gifticons = BehaviorRelay<[GifticonModel]>(value: [])
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func fetchAllGifticons() {
        MOALogger.logd()
        
        Observable.combineLatest(
            categoryRelay,
            sortTypeRelay
        ).flatMap { [unowned self] category, sortType in
            let count = self.gifticons.value.count
            self.gifticons.accept([GifticonModel](repeating: GifticonModel(), count: count))
            return gifticonService.fetchGifticons(
                category: category,
                sortType: sortType
            )
        }.subscribe(
            onNext: { [unowned self] gifticons in
                let models = gifticons.map { $0.toModel() }
                self.gifticons.accept(models)
                
                if self.isFirstFetch {
                    registerNotifications()
                    self.isFirstFetch = false
                }
            },
            onError: { error in
                MOALogger.loge(error.localizedDescription)
            }
        ).disposed(by: disposeBag)
    }
    
    func changeCategory(category: StoreCategory) {
        MOALogger.logd()
        categoryRelay.accept(category)
    }
    
    func changeSort(type: SortType) {
        MOALogger.logd()
        sortTypeRelay.accept(type)
    }
    
    // 최초 기프티콘 화면 진입 시에 기프티콘 알림 등록
    func registerNotifications() {
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
