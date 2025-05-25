//
//  NotificationSettingViewController.swift
//  MOA
//
//  Created by 오원석 on 1/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

enum NotificationDday: Int {
    case day14 = 14
    case day7 = 7
    case day3 = 3
    case day1 = 1
    case day = 0
    
    func getNotificationDate(target: Date?) -> Date? {
        guard let target = target else { return nil }
        
        // 10시 기준으로 알림 보내기
        return target.addingTimeInterval(-Double((self.rawValue * 24 * 3600)) + 10 * 3600)
    }
    
    func getBody(name: String, count: Int) -> String {
        var format = ""
        switch self {
        case .day14:
            format = count == 1 ? NOTIFICATION_14_SINGLE_TITLE_FORMAT : NOTIFICATION_14_MULTI_TITLE_FORMAT
        case .day7:
            format = count == 1 ? NOTIFICATION_7_SINGLE_TITLE_FORMAT : NOTIFICATION_7_MULTI_TITLE_FORMAT
        case .day3:
            format = count == 1 ? NOTIFICATION_3_SINGLE_TITLE_FORMAT : NOTIFICATION_3_MULTI_TITLE_FORMAT
        case .day1:
            format = count == 1 ? NOTIFICATION_1_SINGLE_TITLE_FORMAT : NOTIFICATION_1_MULTI_TITLE_FORMAT
        case .day:
            format = count == 1 ? NOTIFICATION_SINGLE_TITLE_FORMAT : NOTIFICATION_MULTI_TITLE_FORMAT
        }
        
        return count == 1 ? String(format: format, name) : String(format: format, name, count - 1)
    }
}

final class NotificationSettingViewController: BaseViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 15.0)
        label.textColor = .grey90
        label.text = NOTIFICATION
        return label
    }()
    
    fileprivate lazy var notiSwitch: UISwitch = {
        let noti = UISwitch()
        noti.onTintColor = .pink100
        noti.tintColor = .grey40
        noti.transform = CGAffineTransformMakeScale(40 / 51.0, 24 / 31.0)
        noti.isEnabled = UserPreferences.isCheckNotificationAuthorization()
        noti.isOn = UserPreferences.isCheckNotificationAuthorization() && UserPreferences.isNotificationOn()
        return noti
    }()
    
    private lazy var switchView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = UserPreferences.isCheckNotificationAuthorization()
        return view
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey30
        return view
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_regular, size: 14.0)
        label.textColor = .grey60
        label.text = NOTIFICATION_DESCRIPTION_TEXT
        return label
    }()
    
    fileprivate lazy var notiDday14: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY_14)
        return view
    }()
    
    fileprivate lazy var  notiDday7: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY_7)
        return view
    }()
    
    fileprivate lazy var  notiDday3: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY_3)
        return view
    }()
    
    fileprivate lazy var  notiDday1: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY_1)
        return view
    }()
    
    fileprivate lazy var  notiDday: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY)
        return view
    }()
    
    var isOnNotification: Bool = true {
        didSet {
            if isOnNotification {
                notiDday14.isSelect = triggerDays.contains(where: { $0 == .day14 })
                notiDday7.isSelect = triggerDays.contains(where: { $0 == .day7 })
                notiDday3.isSelect = triggerDays.contains(where: { $0 == .day3 })
                notiDday1.isSelect = triggerDays.contains(where: { $0 == .day1 })
                notiDday.isSelect = triggerDays.contains(where: { $0 == .day })
            } else {
                notiDday14.isSelect = false
                notiDday7.isSelect = false
                notiDday3.isSelect = false
                notiDday1.isSelect = false
                notiDday.isSelect = false
            }
        }
    }
    
    let prevTriggerDays: [NotificationDday] = UserPreferences.getNotificationTriggerDays()
    var triggerDays: [NotificationDday] = UserPreferences.getNotificationTriggerDays()
    
    private let viewWillAppear = PublishRelay<Void>()
    private let notificationViewModel = NotificationSettingViewModel(gifticonService: GifticonService.shared)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        bind()
        isOnNotification = UserPreferences.isCheckNotificationAuthorization() && UserPreferences.isNotificationOn()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear.accept(())
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        MOALogger.logd()
        
        UserPreferences.setNotificationOn(isOn: isOnNotification)
        UserPreferences.removeAllNotificationTriggerDays()
        UserPreferences.setNotificationUpdateDate()
        if isOnNotification {
            triggerDays.forEach { triggerDay in
                UserPreferences.setNotificationTriggerDay(triggerDay)
            }
            
            if prevTriggerDays != UserPreferences.getNotificationTriggerDays() {
                NotificationManager.shared.removeAll()
                notificationViewModel.updateNotifications()
            }
        } else {
            NotificationManager.shared.removeAll()
            UserPreferences.setNotificationTriggerDay(.day14)
        }
    }
}

private extension NotificationSettingViewController {
    func setupLayout() {
        setupTopBarWithBackButton(title: SETTING_NOTIFICATION_TITLE)
        [
            titleLabel,
            notiSwitch,
            switchView,
            lineView,
            descLabel,
            notiDday14,
            notiDday7,
            notiDday3,
            notiDday1,
            notiDday
        ].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(25.5)
            $0.leading.equalToSuperview().inset(20)
        }
        
        notiSwitch.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        switchView.snp.makeConstraints {
            $0.edges.equalTo(notiSwitch)
        }
        
        lineView.snp.makeConstraints {
            $0.top.equalTo(notiSwitch.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        notiDday14.snp.makeConstraints {
            $0.top.equalTo(descLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(45)
        }
        
        notiDday7.snp.makeConstraints {
            $0.top.equalTo(notiDday14.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(45)
        }
        
        notiDday3.snp.makeConstraints {
            $0.top.equalTo(notiDday7.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(45)
        }
        
        notiDday1.snp.makeConstraints {
            $0.top.equalTo(notiDday3.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(45)
        }
        
        notiDday.snp.makeConstraints {
            $0.top.equalTo(notiDday1.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(45)
        }
    }
    
    func bind() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        let tapGesture = UITapGestureRecognizer()
        switchView.addGestureRecognizer(tapGesture)
        
        let input = NotificationSettingViewModel.Input(
            viewWillAppear: viewWillAppear,
            tapUnSwitchedView: tapGesture.rx.event,
            changeNotiSwitch: notiSwitch.rx.isOn,
            tapNotiDday14: notiDday14.tapGesture.rx.event,
            tapNotiDday7: notiDday7.tapGesture.rx.event,
            tapNotiDday3: notiDday3.tapGesture.rx.event,
            tapNotiDday1: notiDday1.tapGesture.rx.event,
            tapNotiDday: notiDday.tapGesture.rx.event
        )
        
        let output = notificationViewModel.transform(input: input)
        
        output.goNotificationSetting
            .emit(to: self.rx.goNotificationSetting)
            .disposed(by: disposeBag)
        
        output.updateNotiSwitch
            .emit(to: self.rx.updateNotiSwitch)
            .disposed(by: disposeBag)
        
        output.updateNotiDday14
            .emit(to: self.rx.updateNotiDday14)
            .disposed(by: disposeBag)
        
        output.updateNotiDday7
            .emit(to: self.rx.updateNotiDday7)
            .disposed(by: disposeBag)
        
        output.updateNotiDday3
            .emit(to: self.rx.updateNotiDday3)
            .disposed(by: disposeBag)
        
        output.updateNotiDday1
            .emit(to: self.rx.updateNotiDday1)
            .disposed(by: disposeBag)
        
        output.updateNotiDday
            .emit(to: self.rx.updateNotiDday)
            .disposed(by: disposeBag)
    }
    
    @objc func didBecomeActive() {
        MOALogger.logd()
        NotificationManager.shared.checkNotificationAuthorization {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                notiSwitch.isOn = UserPreferences.isCheckNotificationAuthorization() && UserPreferences.isNotificationOn()
                notiSwitch.isEnabled = UserPreferences.isCheckNotificationAuthorization()
                switchView.isHidden = UserPreferences.isCheckNotificationAuthorization()
                
                if UserPreferences.isNotificationOn() {
                    triggerDays.removeAll()
                    triggerDays.append(.day14)
                }
                
                isOnNotification = UserPreferences.isCheckNotificationAuthorization() && UserPreferences.isNotificationOn()
            }
        }
    }
    
    @objc func tapSwitch() {
        MOALogger.logd()
        
        showSelectModal(
            title: NOTIFICATION_AUTHORIZATION_POPUP_TITLE,
            subTitle: NOTIFICATION_AUTHORIZATION_POPUP_SUBTITLE,
            confirmText: NOTIFICATION_AUTHORIZATION_POPUP_CONFIRM,
            cancelText: CANCEL
        ) {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }
}

extension Reactive where Base: NotificationSettingViewController {
    var goNotificationSetting: Binder<UITapGestureRecognizer> {
        return Binder<UITapGestureRecognizer>(self.base) { viewController, _ in
            MOALogger.logd()
            
            viewController.showSelectModal(
                title: NOTIFICATION_AUTHORIZATION_POPUP_TITLE,
                subTitle: NOTIFICATION_AUTHORIZATION_POPUP_SUBTITLE,
                confirmText: NOTIFICATION_AUTHORIZATION_POPUP_CONFIRM,
                cancelText: CANCEL
            ) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    var updateNotiSwitch: Binder<Bool> {
        return Binder<Bool>(self.base) { viewController, isOn in
            viewController.isOnNotification = isOn
        }
    }
    
    var updateNotiDday14: Binder<UITapGestureRecognizer> {
        return Binder<UITapGestureRecognizer>(self.base) { viewController, _ in
            viewController.notiDday14.isSelect = !viewController.notiDday14.isSelect
            
            if viewController.notiDday14.isSelect {
                viewController.triggerDays.append(.day14)
            } else {
                viewController.triggerDays.removeAll(where: { $0 == .day14 })
            }
        }
    }
    
    var updateNotiDday7: Binder<UITapGestureRecognizer> {
        return Binder<UITapGestureRecognizer>(self.base) { viewController, _ in
            viewController.notiDday7.isSelect = !viewController.notiDday7.isSelect
            
            if viewController.notiDday7.isSelect {
                viewController.triggerDays.append(.day7)
            } else {
                viewController.triggerDays.removeAll(where: { $0 == .day7 })
            }
        }
    }
    
    var updateNotiDday3: Binder<UITapGestureRecognizer> {
        return Binder<UITapGestureRecognizer>(self.base) { viewController, _ in
            viewController.notiDday3.isSelect = !viewController.notiDday3.isSelect
            
            if viewController.notiDday3.isSelect {
                viewController.triggerDays.append(.day3)
            } else {
                viewController.triggerDays.removeAll(where: { $0 == .day3 })
            }
        }
    }
    
    var updateNotiDday1: Binder<UITapGestureRecognizer> {
        return Binder<UITapGestureRecognizer>(self.base) { viewController, _ in
            viewController.notiDday1.isSelect = !viewController.notiDday1.isSelect
            
            if viewController.notiDday1.isSelect {
                viewController.triggerDays.append(.day1)
            } else {
                viewController.triggerDays.removeAll(where: { $0 == .day1 })
            }
        }
    }
    
    var updateNotiDday: Binder<UITapGestureRecognizer> {
        return Binder<UITapGestureRecognizer>(self.base) { viewController, _ in
            viewController.notiDday.isSelect = !viewController.notiDday.isSelect
            
            if viewController.notiDday.isSelect {
                viewController.triggerDays.append(.day)
            } else {
                viewController.triggerDays.removeAll(where: { $0 == .day })
            }
        }
    }
}
