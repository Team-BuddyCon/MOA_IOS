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
    
    fileprivate var checkButton: CheckButton = {
        let button = CheckButton()
        return button
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_medium, size: 15.0)
        label.textColor = .grey60
        return label
    }()
    
    fileprivate let detailButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: FORWARD_BUTTON_IMAGE_ASSET), for: .normal)
        return button
    }()
    
    var isChecked = BehaviorRelay<Bool>(value: false)
    
    init(text: String, hasMore: Bool = false) {
        isChecked = checkButton.isChecked
        super.init(frame: .zero)
        
        textLabel.text = text
        detailButton.isHidden = !hasMore
        setup()
        bind()
    }
    
    required init?(coder: NSCoder) {
        isChecked = checkButton.isChecked
        super.init(coder: coder)
        setup()
        bind()
    }
    
    private func setup() {
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
    
    private func bind() {
        isChecked
            .bind(to: checkButton.rx.isChecked)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: SignUpCheckBox {
    var tap: ControlEvent<Void> {
        self.base.checkButton.rx.tap
    }
    
    var detailTap: ControlEvent<Void> {
        self.base.detailButton.rx.tap
    }
}
