//
//  SignUpCheckBox.swift
//  MOA
//
//  Created by 오원석 on 10/1/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxSwift

final class SignUpCheckBox: UIView {
    
    private let disposeBag = DisposeBag()
    private let checkButton: CheckButton = {
        let button = CheckButton()
        return button
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_medium, size: 15.0)
        label.textColor = .grey60
        return label
    }()
    
    private lazy var detailButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: FORWARD_BUTTON_IMAGE_ASSET), for: .normal)
        button.addTarget(self, action: #selector(tapDetailButton), for: .touchUpInside)
        return button
    }()
    
    var tapDetailClosure: (() -> Void)?
    var isChecked = BehaviorRelay<Bool>(value: false)
    var tap: ControlEvent<Void>
    
    init(
        frame: CGRect,
        text: String,
        hasMore: Bool = false,
        onDetailClosure: @escaping () -> Void = {}
    ) {
        isChecked = checkButton.isChecked
        tap = checkButton.rx.tap
        
        super.init(frame: frame)
        textLabel.text = text
        detailButton.isHidden = !hasMore
        tapDetailClosure = onDetailClosure
        
        setupApperance()
        subscribe()
    }
    
    required init?(coder: NSCoder) {
        isChecked = checkButton.isChecked
        tap = checkButton.rx.tap
        super.init(coder: coder)
        setupApperance()
        subscribe()
    }
    
    private func setupApperance() {
        [checkButton, textLabel, detailButton].forEach {
            addSubview($0)
        }
        
        checkButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalTo(checkButton.snp.height).multipliedBy(1.0)
        }
        
        textLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(checkButton.snp.trailing).offset(8)
        }
        
        detailButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(textLabel.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalTo(detailButton.snp.height).multipliedBy(1.0)
        }
    }
    
    private func subscribe() {
        isChecked
            .bind(to: checkButton.rx.isChecked)
            .disposed(by: disposeBag)
    }
    
    @objc func tapDetailButton() {
        MOALogger.logd()
        tapDetailClosure?()
    }
}
