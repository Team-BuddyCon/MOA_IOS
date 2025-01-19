//
//  UIView+.swift
//  MOA
//
//  Created by 오원석 on 1/19/25.
//

import UIKit

extension UIView {
    /**
     UIView에 그림자 속성 추가
     - Parameters:
     - color: 색상
     - opacity: 투명도
     - blur: 블러처리 (그림자가 넓게 뿌려진 정도)
     - x: 그림자 위치 x ( x > 0 : Right , x < 0 : Left)
     - y: 그림자 위치 y ( y > 0 : Down, y < 0 : Up)
     */
    func applyShadow(
        color: CGColor,
        opacity: Float,
        blur: CGFloat,
        x: Double,
        y: Double
    ) {
        layer.shadowColor = color
        layer.shadowOpacity = opacity
        layer.shadowRadius = blur
        layer.shadowOffset = CGSize(width: x, height: y)
    }
}
