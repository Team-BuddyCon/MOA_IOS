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
        guard UserPreferences.isNotificationOn() else { return }
        
        // 등록된 알림 모두 제거
        NotificationManager.shared.removeAll()
        
        let expireGroup = Dictionary(grouping: gifticons.value) { $0.expireDate }
        let expireDateGroup = Dictionary(uniqueKeysWithValues: expireGroup.compactMap {
            if let date = $0.key.toDate(format: AVAILABLE_GIFTICON_TIME_FORMAT) {
                return (date, $0.value)
            } else {
                return nil
            }
        })
        
        expireDateGroup.forEach {
            let expireDate = $0.key.toString(format: AVAILABLE_GIFTICON_TIME_FORMAT)
            let notificationDate = UserPreferences.getNotificationDday().getNotificationDate(target: $0.key)
            let gifticons = $0.value
            
            guard let notificationDate = notificationDate else { return }
            if notificationDate <= Date() { return }
            
            MOALogger.logd("notificationDate: \(notificationDate), expireDate: \(expireDate)")
            
            gifticons.forEach { gifticon in
                NotificationManager.shared.register(
                    expireDate,
                    date: notificationDate,
                    name: gifticon.name
                )
            }
        }
    }
}
