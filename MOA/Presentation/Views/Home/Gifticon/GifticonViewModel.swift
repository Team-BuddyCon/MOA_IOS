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

final class GifticonViewModel: BaseViewModel, ViewModelType {
    
    struct Input {
        let changeCategory: BehaviorRelay<StoreCategory>
        let changeSort: BehaviorRelay<SortType>
    }
    
    struct Output {
        let updateGifticons: Driver<[GifticonModel]>
    }
    
    private let gifticonService: GifticonServiceProtocol
    
    private var isFirstFetch: Bool = true
    
    var gifticonCount: Int {
        return gifticonModelsRelay.value.count
    }
    
    var gifticons: [GifticonModel] {
        return gifticonModelsRelay.value
    }
    
    private let gifticonModelsRelay = BehaviorRelay<[GifticonModel]>(value: [])
//    private let categoryRelay: BehaviorRelay<StoreCategory> = BehaviorRelay(value: .ALL)
//    private let sortTypeRelay: BehaviorRelay<SortType> = BehaviorRelay(value: .EXPIRE_DATE)
//    var sortType: SortType { sortTypeRelay.value }
//    var sortTitle: Driver<String> {
//        sortTypeRelay
//            .map { $0.rawValue }
//            .asDriver(onErrorJustReturn: SortType.EXPIRE_DATE.rawValue)
//    }
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func transform(input: Input) -> Output {
        Observable.combineLatest(
            input.changeCategory,
            input.changeSort
        ).flatMap { [unowned self] category, sortType in
            // 페이징 처리는 하지 않고 category, sort 변경 시에 기프티콘 조회
            // 스켈레톤 UI는 현재 기프티콘만큼 스켈레콘 UI 처리하고 조회 완료되면 변경
            gifticonModelsRelay.accept([GifticonModel](repeating: GifticonModel(), count: gifticonCount > 0 ? gifticonCount : 6))
            return gifticonService.fetchGifticons(category: category, sortType: sortType)
        }.subscribe(onNext: { [unowned self] gifticons in
            gifticonModelsRelay.accept(gifticons.map { $0.toModel() })
            
            if isFirstFetch {
                registerNotifications()
                insertLocatlNotificiations()
                removeLocalNotifications()
                isFirstFetch = false
            }
        }).disposed(by: disposeBag)
        
        return Output(
            updateGifticons: gifticonModelsRelay.asDriver()
        )
    }
    
//    func fetchAllGifticons() {
//        Observable.combineLatest(
//            categoryRelay,
//            sortTypeRelay
//        ).flatMap { [unowned self] category, sortType in
//
//            self.gifticonModelsRelay.accept([GifticonModel](repeating: GifticonModel(), count: gifticonCount))
//            return gifticonService.fetchGifticons(
//                category: category,
//                sortType: sortType
//            )
//        }.subscribe(
//            onNext: { [unowned self] gifticons in
//                let models = gifticons.map { $0.toModel() }
//                self.gifticonModelsRelay.accept(models)
//                
//                if self.isFirstFetch {
//                    registerNotifications()
//                    insertLocatlNotificiations()
//                    removeLocalNotifications()
//                    self.isFirstFetch = false
//                }
//            },
//            onError: { error in
//                MOALogger.loge(error.localizedDescription)
//            }
//        ).disposed(by: disposeBag)
//    }
    
//    func changeCategory(category: StoreCategory) {
//        MOALogger.logd()
//        categoryRelay.accept(category)
//    }
//    
//    func changeSort(type: SortType) {
//        MOALogger.logd()
//        sortTypeRelay.accept(type)
//    }
    
    // 최초 기프티콘 화면 진입 시에 기프티콘 알림 등록
    func registerNotifications() {
        MOALogger.logd()
        
        NotificationManager.shared.removeAll()
        gifticons.forEach { gifticon in
            NotificationManager.shared.register(
                gifticon.expireDate,
                name: gifticon.name,
                gifticonId: gifticon.gifticonId
            )
        }
        
//        let date = Date()
//        let dummy = Calendar.current.date(byAdding: .second, value: 10, to: date)
//        NotificationManager.shared.registerTestNotification(
//            "test",
//            expireDate: dummy,
//            name: "테스트",
//            count: 1,
//            gifticonId: "5E64F632-7EB3-4ED5-8E28-318223244346"
//        )
    }
    
    // 30일이 지난 알림 삭제
    func removeLocalNotifications() {
        MOALogger.logd()
        
        LocalNotificationDataManager.shared.fetchNotification()
            .filter {
                if let expireDate = $0.date.toDate(format: AVAILABLE_GIFTICON_TIME_FORMAT),
                   let removeDate = Calendar.current.date(byAdding: .day, value: 30, to: expireDate) {
                    return removeDate < Date()
                }
                return false
            }.forEach {
                let _ = LocalNotificationDataManager.shared.deleteNotification($0)
            }
    }
    
    // 알림은 보내졌지만 내부 저장소에 저장이 안된 알림 저장 로직 (서버리스 문제)
    func insertLocatlNotificiations() {
        MOALogger.logd()
        guard UserPreferences.isNotificationOn() else { return }
        
        let current = Date()
        let expireDateGroup = gifticons.grouped(by: { $0.expireDate })
        
        UserPreferences.getNotificationTriggerDays().forEach { triggerDay in
            Array(expireDateGroup.keys).forEach { (date: String) in
                if let expireDate = date.toDate(format: AVAILABLE_GIFTICON_TIME_FORMAT),
                   let triggerDate = triggerDay.getNotificationDate(target: expireDate),
                   triggerDate < current && current <= expireDate {
                    
                    // triggerDate 보다 더 나중에 알림 주기 업데이트 시에는 알림에 표시되지 않음
                    let triggerDateString = triggerDate.toString(format: AVAILABLE_GIFTICON_TIME_FORMAT)
                    guard UserPreferences.getNotifcationUpdateDate() < triggerDateString else { return }
                    
                    // 알림이 업로드 시점보다 더 이전이라면 알림 데이터 화면에는 보여지면 안됨
                    guard let models = expireDateGroup[date]?.filter({ $0.uploadDate < triggerDateString }) else { return }
                    guard let firstModel = models.first else { return }
                    let isMaxLenght = firstModel.name.count > 10
                    let title = isMaxLenght ? String(firstModel.name.prefix(10)) + "..." : firstModel.name
                    let message = triggerDay.getBody(name: title, count: models.count)
                    let gifticonId = firstModel.gifticonId
                    let _ = LocalNotificationDataManager.shared.insertNotification(
                        NotificationModel(
                            count: models.count,
                            date: triggerDate.toString(format: AVAILABLE_GIFTICON_TIME_FORMAT),
                            message: message,
                            gifticonId: gifticonId,
                            isRead: false
                        )
                    )
                }
            }
        }
    }
}
