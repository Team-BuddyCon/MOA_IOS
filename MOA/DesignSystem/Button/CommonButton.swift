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
    var status = BehaviorRelay<ButtonStatus>(value: .active)
    
    init(
        frame: CGRect = .zero,
        title: String,
        fontName: String = pretendard_bold,
        fontSize: CGFloat = 15.0
    ) {
        super.init(frame: frame)
        self.layer.cornerRadius = 12.0
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont(name: fontName, size: fontSize)
        updateStatus()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateStatus()
    }
    
    func updateStatus() {
        status.asDriver()
            .drive { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .active:
                    backgroundColor = .pink100
                    titleLabel?.textColor = .white
                case .disabled:
                    backgroundColor = .grey40
                    titleLabel?.textColor = .grey60
                case .cancel:
                    backgroundColor = .grey30
                    titleLabel?.textColor = .grey70
                }
            }
            .disposed(by: disposeBag)
    }
}
