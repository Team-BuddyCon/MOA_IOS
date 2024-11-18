//
//  FloatingButton.swift
//  MOA
//
//  Created by 오원석 on 11/17/24.
//

import UIKit

final class FloatingButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    func setup() {
        backgroundColor = .pink100
        setImage(UIImage(named: FLOATING_ICON), for: .normal)
    }
}
