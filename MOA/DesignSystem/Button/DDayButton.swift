//
//  MOATagButton.swift
//  MOA
//
//  Created by 오원석 on 8/18/24.
//

import UIKit


final class DDayButton: UIButton {
    
    var dday: Int = 0 {
        didSet {
            if dday < 0 {
                setTitle(dday_end, for: .normal)
                backgroundColor = .grey90
            } else if dday >= 365 {
                setTitle(dday_over365, for: .normal)
                backgroundColor = .grey60
            } else if dday < 14 {
                setTitle(String(format: dday_format, dday), for: .normal)
                backgroundColor = .pink100
            } else{
                setTitle(String(format: dday_format, dday), for: .normal)
                backgroundColor = .grey60
            }
            sizeToFit()
        }
    }
    
    init(
        dday: Int = 0,
        fontName: String = pretendard_bold,
        fontSize: CGFloat = 10.0
    ) {
        self.dday = dday
        super.init(frame: .zero)
        titleLabel?.font = UIFont(name: fontName, size: fontSize)
        contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

