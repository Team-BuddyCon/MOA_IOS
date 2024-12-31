//
//  File.swift
//  MOA
//
//  Created by 오원석 on 12/1/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class OtherStoreSheetView: UIView {
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 16.0)
        label.text = OTHER_STORE
        label.textColor = .grey90
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: CLOSE_BUTTON), for: .normal)
        return button
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: OTHERS_IMAGE)
        return imageView
    }()
    
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_medium, size: 14.0)
        label.textColor = .grey90
        label.text = GIFTICON_REGISTER_OTHER_STORE_GUIDE
        return label
    }()
    
    lazy var textInput: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: pretendard_bold, size: 15.0)
        textField.textColor = .grey90
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.placeholder = GIFTICON_REGISTER_OTHER_STORE_PLACEHOLDER
        textField.delegate = self
        return textField
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_regular, size: 12.0)
        label.textColor = .grey60
        label.text = GIFTICON_REGISTER_OTHER_STORE_INFO
        return label
    }()
    
    let prevButton: CommonButton = {
        let button = CommonButton(
            status: .cancel,
            title: GIFTICON_REGISTER_OTHER_STORE_PREVIOUS_BUTTON
        )
        return button
    }()
    
    let completeButton: CommonButton = {
        let button = CommonButton(
            status: .active,
            title: GIFTICON_REGISTER_OTHER_STORE_COMPLETED
        )
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textInput.underLine(width: 1.0, color: .grey30)
    }
    
    private func setupLayout() {
        let width = Int(UIScreen.main.bounds.width)
        let height = BottomSheetType.Other_Store.rawValue
        frame = CGRect(x: 0, y: 0, width: width, height: height)
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backgroundColor = .white
        
        [
            titleLabel,
            closeButton,
            iconImageView,
            guideLabel,
            textInput,
            infoLabel,
            prevButton,
            completeButton
        ].forEach {
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
        
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(68)
            $0.leading.equalToSuperview().inset(20)
            $0.size.equalTo(40)
        }
        
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom)
            $0.leading.equalToSuperview().inset(20)
        }
        
        textInput.snp.makeConstraints {
            $0.top.equalTo(guideLabel.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(21)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(textInput.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        let buttonW = UIScreen.getWidthByDivision(division: 2, exclude: 48)
        prevButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(buttonW)
            $0.height.equalTo(54)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(11.5)
        }
        
        completeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(buttonW)
            $0.height.equalTo(54)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(11.5)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        textInput.endEditing(true)
    }
}

extension OtherStoreSheetView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textInput.resignFirstResponder()
        return true
    }
}
