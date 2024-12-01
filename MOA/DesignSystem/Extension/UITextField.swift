//
//  UITextField.swift
//  MOA
//
//  Created by 오원석 on 12/1/24.
//

import UIKit

extension UITextField {
    func underLine(width: CGFloat, color: UIColor) {
        let borderLayer = CALayer()
        borderLayer.frame = CGRect(
            x: 0,
            y: Int(self.frame.height) + 7,
            width: Int(self.frame.width),
            height: 1
        )
        borderLayer.backgroundColor = color.cgColor
        layer.addSublayer(borderLayer)
    }
}
