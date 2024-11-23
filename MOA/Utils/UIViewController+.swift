//
//  UIViewController+.swift
//  MOA
//
//  Created by 오원석 on 11/23/24.
//

import UIKit

extension UIViewController {
    func setupTopBarWithLargeTitle(title: String) {
        let label = UILabel()
        label.text = title
        label.font = UIFont(name: pretendard_bold, size: 22)
        label.textColor = .grey90
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    }
    
    @objc func setupTopBarWithBackButton(title: String){
        navigationItem.hidesBackButton = true
        let backButtonItem = UIBarButtonItem(
            image: UIImage(named: BACK_BUTTON_IMAGE_ASSET),
            style: .plain,
            target: self,
            action: #selector(tapBackButton)
        )
        backButtonItem.tintColor = .grey90
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.title = title
    
    }
    
    @objc func tapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}
