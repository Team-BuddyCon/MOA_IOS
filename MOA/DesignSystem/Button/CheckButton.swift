//
//  CheckButton.swift
//  MOA
//
//  Created by 오원석 on 10/1/24.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

final class CheckButton: UIButton {
    
    // Observer & Observable
    var isChecked = BehaviorRelay(value: false)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    func setUp() {
        backgroundColor = .grey30
        setImage(UIImage(named: CHECK_BUTTON_IMAGE_ASSET), for: .normal)
    }
}

// Observer
extension Reactive where Base: CheckButton {
    var isChecked: Binder<Bool> {
        return Binder<Bool>(self.base) { button, isCheck in
            button.backgroundColor = isCheck ? .pink100 : .grey30
        }
    }
}
