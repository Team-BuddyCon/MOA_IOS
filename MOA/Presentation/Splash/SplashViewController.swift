//
//  SplashViewController.swift
//  MOA
//
//  Created by 오원석 on 8/13/24.
//

import UIKit
import SnapKit

class SplashViewController: BaseViewController {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "SplashIcon"))
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd("viewDidLoad")
        view.backgroundColor = .pink100
        view.addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(97)
        }

    }
}

