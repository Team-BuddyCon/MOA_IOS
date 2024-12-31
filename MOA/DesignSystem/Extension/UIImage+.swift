//
//  UIImage+.swift
//  MOA
//
//  Created by 오원석 on 12/31/24.
//

import UIKit

extension UIImage {
    func resize(scale: CGFloat) -> UIImage {
        let width = self.size.width * scale
        let height = self.size.height * scale
        let newSize = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let renderedImage = renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return renderedImage
    }
}
