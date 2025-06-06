//
//  ExpireDateBottomSheetViewController.swift
//  MOA
//
//  Created by 오원석 on 6/4/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class ExpireDateBottomSheetViewController: BottomSheetViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 16.0)
        label.text = EXPIRE_DATE
        label.textColor = .grey90
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: CLOSE_BUTTON), for: .normal)
        return button
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko_kr")
        return picker
    }()
    
    override init(sheetType: BottomSheetType) {
        switch sheetType {
        case .Date(let date):
            datePicker.setDate(date, animated: false)
            super.init(sheetType: sheetType)
        default:
            fatalError()
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        [titleLabel, closeButton, datePicker].forEach {
            contentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(19)
            $0.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(24)
        }
        
        datePicker.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(253)
        }
    }
    
    override func bind() {
        super.bind()
        
        let tapGesture = UITapGestureRecognizer()
        contentView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let date = datePicker.date
                
                guard let delegate = delegate as? ExpireDateBottomSheetViewControllerDelegate else { return }
                delegate.didSelectDate(date: date)
            }).disposed(by: disposeBag)
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let date = datePicker.date
                
                guard let delegate = delegate as? ExpireDateBottomSheetViewControllerDelegate else { return }
                delegate.didSelectDate(date: date)
            }).disposed(by: disposeBag)
    }
}
