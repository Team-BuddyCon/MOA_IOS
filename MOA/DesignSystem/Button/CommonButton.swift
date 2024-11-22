//
//  MOAUIButton.swift
//  MOA
//
//  Created by 오원석 on 8/18/24.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa

enum ButtonStatus {
    case active
    case disabled
    case cancel
}

final class CommonButton: UIButton {
    
    private let disposeBag = DisposeBag()
    let status: BehaviorRelay<ButtonStatus>
    
    init(
        status: ButtonStatus = .active,
        title: String,
        fontName: String = pretendard_bold,
        fontSize: CGFloat = 15.0
    ) {
        self.status = BehaviorRelay(value: status)
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont(name: fontName, size: fontSize)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 12.0
    }
    
    func bind() {
        status.asDriver()
            .drive { [weak self] status in
                guard let self = self else {
                    MOALogger.loge()
                    return
                }
                
                switch status {
                case .active:
                    backgroundColor = .pink100
                    setTitleColor(.white, for: .normal)
                case .disabled:
                    backgroundColor = .grey40
                    setTitleColor(.grey60, for: .normal)
                case .cancel:
                    backgroundColor = .grey30
                    setTitleColor(.grey70, for: .normal)
                }
            }.disposed(by: disposeBag)
    }
}
