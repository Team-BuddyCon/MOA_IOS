//
//  SignUpViewController.swift
//  MOA
//
//  Created by 오원석 on 10/1/24.
//

import UIKit

final class SignUpViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }
}

private extension SignUpViewController {
    func setupAppearance() {
        navigationItem.hidesBackButton = true
        
        let backButtonItem = UIBarButtonItem(
            image: UIImage(named: BACK_BUTTON_IMAGE_ASSET),
            style: .plain,
            target: self,
            action: #selector(tapBackButton)
        )
        backButtonItem.tintColor = .grey90
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.title = SIGNUP_TITLE
    }
}

private extension SignUpViewController {
    @objc func tapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}
