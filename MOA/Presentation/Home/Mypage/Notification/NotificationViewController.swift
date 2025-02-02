//
//  NotificationViewController.swift
//  MOA
//
//  Created by 오원석 on 1/11/25.
//

import UIKit
import SnapKit

final class NotificationViewController: BaseViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 15.0)
        label.textColor = .grey90
        label.text = NOTIFICATION
        return label
    }()
    
    private let notiSwitch: UISwitch = {
        let noti = UISwitch()
        noti.isOn = true
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
    
    private let notiDday14: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY_14, isOn: true)
        return view
    }()
    
    private let notiDday7: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY_7)
        return view
    }()
    
    private let notiDday3: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY_3)
        view.isSelect = false
        return view
    }()
    
    private let notiDday1: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY_1)
        view.isSelect = false
        return view
    }()
    
    private let notiDday: SelectCheckButton = {
        let view = SelectCheckButton(title: NOTIFICATION_D_DAY)
        view.isSelect = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        bind()
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
        notiDday14.tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.notiDday14.isSelect = true
                self?.notiDday7.isSelect = false
                self?.notiDday3.isSelect = false
                self?.notiDday1.isSelect = false
                self?.notiDday.isSelect = false
            }).disposed(by: disposeBag)
        
        notiDday7.tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.notiDday14.isSelect = false
                self?.notiDday7.isSelect = true
                self?.notiDday3.isSelect = false
                self?.notiDday1.isSelect = false
                self?.notiDday.isSelect = false
            }).disposed(by: disposeBag)
        
        notiDday3.tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.notiDday14.isSelect = false
                self?.notiDday7.isSelect = false
                self?.notiDday3.isSelect = true
                self?.notiDday1.isSelect = false
                self?.notiDday.isSelect = false
            }).disposed(by: disposeBag)
        
        notiDday1.tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.notiDday14.isSelect = false
                self?.notiDday7.isSelect = false
                self?.notiDday3.isSelect = false
                self?.notiDday1.isSelect = true
                self?.notiDday.isSelect = false
            }).disposed(by: disposeBag)
        
        notiDday.tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.notiDday14.isSelect = false
                self?.notiDday7.isSelect = false
                self?.notiDday3.isSelect = false
                self?.notiDday1.isSelect = false
                self?.notiDday.isSelect = true
            }).disposed(by: disposeBag)
    }
}
