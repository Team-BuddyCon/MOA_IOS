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
    
    var isCheckedRelay: BehaviorRelay<Bool>
    var checkState: Driver<Bool>
    
    init(
        frame: CGRect,
        text: String,
        hasMore: Bool = false
    ) {
        isCheckedRelay = checkButton.isChecked
        checkState = isCheckedRelay.asDriver(onErrorJustReturn: false)
        
        super.init(frame: frame)
        textLabel.text = text
        detailButton.isHidden = !hasMore
        setupApperance()
        subscribe()
    }
    
    required init?(coder: NSCoder) {
        isCheckedRelay = checkButton.isChecked
        checkState = isCheckedRelay.asDriver(onErrorJustReturn: false)
        
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
        checkButton.rx.tap
            .subscribe(
                onNext: { [weak self] _ in
                    guard let self = self else { return }
                    let check = self.checkButton.isChecked.value
                    self.checkButton.isChecked.accept(!check)
                }
            ).disposed(by: disposeBag)
        
        checkButton.isChecked
            .bind(to: checkButton.rx.isChecked)
            .disposed(by: disposeBag)
    }
    
    @objc func tapDetailButton() {
        print("tapDetailButton")
    }
}
