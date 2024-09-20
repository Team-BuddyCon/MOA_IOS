//
//  UIApplication+.swift
//  MOA
//
//  Created by 오원석 on 9/21/24.
//

import UIKit

extension UIApplication {
    func setRootViewController(vc: UIViewController) {
        if let windowScene = connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            window.rootViewController = vc
        }
    }
}
