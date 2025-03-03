//
//  NotificationViewController.swift
//  MOA
//
//  Created by 오원석 on 1/11/25.
//

import UIKit
import SnapKit

enum NotificationDday: Int {
    case day14 = 14
    case day7 = 7
    case day3 = 3
    case day1 = 1
    case day = 0
    
    func getNotificationDate(target: Date?) -> Date? {
        guard let target = target else { return nil }
        return target.addingTimeInterval(-Double((self.rawValue * 24 * 3600)))
    }
}

final class NotificationViewController: BaseViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 15.0)
        label.textColor = .grey90
        label.text = NOTIFICATION
        return label
    }()
    
    private lazy var notiSwitch: UISwitch = {
        let noti = UISwitch()
        noti.onTintColor = .pink100
        noti.tintColor = .grey40
        noti.transform = CGAffineTransformMakeScale(40 / 51.0, 24 / 31.0)
        return noti
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
    
    private lazy var notiDday14: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY_14)
        view.isSelect = isOnNotification && dday == .day14
        return view
    }()
    
    private lazy var  notiDday7: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY_7)
        view.isSelect = isOnNotification && dday == .day7
        return view
    }()
    
    private lazy var  notiDday3: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY_3)
        view.isSelect = isOnNotification && dday == .day3
        return view
    }()
    
    private lazy var  notiDday1: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY_1)
        view.isSelect = isOnNotification && dday == .day1
        return view
    }()
    
    private lazy var  notiDday: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY)
        view.isSelect = isOnNotification && dday == .day
        return view
    }()
    
    var isOnNotification: Bool = true {
        didSet {
            notiSwitch.isOn = isOnNotification
            if isOnNotification {
                notiDday14.isSelect = dday == .day14
                notiDday7.isSelect = dday == .day7
                notiDday3.isSelect = dday == .day3
                notiDday1.isSelect = dday == .day1
                notiDday.isSelect = dday == .day
            } else {
                notiDday14.isSelect = false
                notiDday7.isSelect = false
                notiDday3.isSelect = false
                notiDday1.isSelect = false
                notiDday.isSelect = false
            }
        }
    }
    
    var dday: NotificationDday = .day {
        didSet {
            notiDday14.isSelect = isOnNotification && dday == .day14
            notiDday7.isSelect = isOnNotification && dday == .day7
            notiDday3.isSelect = isOnNotification && dday == .day3
            notiDday1.isSelect = isOnNotification && dday == .day1
            notiDday.isSelect = isOnNotification && dday == .day
        }
    }
    
    private let notificationViewModel = NotificationViewModel(gifticonService: GifticonService.shared)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        bind()
        
        isOnNotification = UserPreferences.isNotificationOn()
        dday = UserPreferences.getNotificationDday()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationViewModel.fetchAllGifticons()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        MOALogger.logd()
        
        if isOnNotification {
            if NotificationManager.shared.notificationDay != dday {
                notificationViewModel.updateNotifications(dday: dday)
            }
        } else {
            NotificationManager.shared.removeAll()
        }
        
        UserPreferences.setNotificationOn(isOn: isOnNotification)
        UserPreferences.setNotificationDday(dday: dday)
    }
}

private extension NotificationViewController {
    func setupLayout() {
        setupTopBarWithBackButton(title: SETTING_NOTIFICATION_TITLE)
        [
            titleLabel,
            notiSwitch,
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
        notiSwitch.rx.isOn
            .subscribe(onNext: { [unowned self] isOn in
                self.isOnNotification = isOn
            }).disposed(by: disposeBag)
        
        notiDday14.tapGesture.rx.event
            .subscribe(onNext: { [unowned self] _ in
                self.dday = .day14
            }).disposed(by: disposeBag)
        
        notiDday7.tapGesture.rx.event
            .subscribe(onNext: { [unowned self] _ in
                self.dday = .day7
            }).disposed(by: disposeBag)
        
        notiDday3.tapGesture.rx.event
            .subscribe(onNext: { [unowned self] _ in
                self.dday = .day3
            }).disposed(by: disposeBag)
        
        notiDday1.tapGesture.rx.event
            .subscribe(onNext: { [unowned self] _ in
                self.dday = .day1
            }).disposed(by: disposeBag)
        
        notiDday.tapGesture.rx.event
            .subscribe(onNext: { [unowned self] _ in
                self.dday = .day
            }).disposed(by: disposeBag)
    }
}
