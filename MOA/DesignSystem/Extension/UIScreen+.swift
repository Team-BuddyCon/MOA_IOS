//
//  UIScreen+.swift
//  MOA
//
//  Created by 오원석 on 11/10/24.
//

import UIKit

extension UIScreen {
    static func getWidthByDivision(
        division: Int,
        exclude: Int = 0
    ) -> Int {
        let width = Int(UIScreen.main.bounds.width)
        return (width - exclude) / division
    }
}
