//
//  UIViewController+.swift
//  MOA
//
//  Created by 오원석 on 11/23/24.
//

import UIKit

extension UIViewController {
    
    func navigatePopUpTo<T: UIViewController>(type: T.Type, animated: Bool = true) {
        if let destinationVC = navigationController?.viewControllers.first(where: { $0 is T}) {
            navigationController?.popToViewController(destinationVC, animated: animated)
        }
    }
    
    func setupTopBarWithLargeTitle(title: String) {
        navigationItem.leftBarButtonItem = makeLeftLargeTitle(title: title)
        navigationItem.rightBarButtonItem = nil
    }
    
    func setupTopBarWithBackButton(title: String){
        navigationItem.leftBarButtonItem = makeBackButton()
        navigationItem.titleView = makeTitle(title: title)
    }
    
    @objc func makeLeftLargeTitle(title: String) -> UIBarButtonItem {
        let label = UILabel()
        label.text = title
        label.font = UIFont(name: pretendard_bold, size: 22)
        label.textColor = .grey90
        return UIBarButtonItem(customView: label)
    }

    @objc private func makeBackButton() -> UIBarButtonItem {
        navigationItem.hidesBackButton = true
        let backButtonItem = UIBarButtonItem(
            image: UIImage(named: BACK_BUTTON_IMAGE_ASSET),
            style: .plain,
            target: self,
            action: #selector(tapBackButton)
        )
        backButtonItem.tintColor = .grey90
        return backButtonItem
    }
    
    @objc func tapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func makeTitle(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = UIFont(name: pretendard_bold, size: 15.0)
        label.textColor = .grey90
        return label
    }
}
