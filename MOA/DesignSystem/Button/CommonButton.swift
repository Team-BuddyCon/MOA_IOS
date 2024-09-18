//
//  MOAUIButton.swift
//  MOA
//
//  Created by 오원석 on 8/18/24.
//

import UIKit
import SnapKit

enum ButtonStatus {
    case active
    case disabled
    case cancel
}

final class CommonButton: UIButton {
    var status: ButtonStatus = .active {
        didSet {
            updateStatus()
        }
    }
    
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
    }
    
    func updateStatus() {
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
}
