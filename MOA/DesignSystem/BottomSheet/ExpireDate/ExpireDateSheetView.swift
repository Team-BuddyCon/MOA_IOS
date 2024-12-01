//
//  ExpireDateSheetView.swift
//  MOA
//
//  Created by 오원석 on 11/27/24.
//

import UIKit
import SnapKit

final class ExpireDateSheetView: UIView {
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
    
    init(date: Date = Date()) {
        super.init(frame: .zero)
        datePicker.setDate(date, animated: false)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        let width = Int(UIScreen.main.bounds.width)
        let height = BottomSheetType.Date.rawValue
        frame = CGRect(x: 0, y: 0, width: width, height: height)
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 16
        backgroundColor = .white
        
        [titleLabel, closeButton, datePicker].forEach {
            addSubview($0)
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
}
