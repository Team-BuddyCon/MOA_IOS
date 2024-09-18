//
//  UILabel+.swift
//  MOA
//
//  Created by 오원석 on 9/17/24.
//

import UIKit

extension UILabel {
    /**
        폰트, 텍스트 사이즈, 텍스트 Line Height 설정
     */
    func setTextWithLineHeight(
        text: String,
        font: String,
        size: CGFloat,
        lineSpacing: CGFloat,
        alignment: NSTextAlignment = .center
    ) {
        self.font = UIFont(name: font, size: size)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing - size
        paragraphStyle.alignment = alignment
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )
        
        attributedText = attributedString
    }
}
