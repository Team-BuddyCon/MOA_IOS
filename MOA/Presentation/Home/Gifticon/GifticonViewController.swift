//
//  GifticonViewController.swift
//  MOA
//
//  Created by 오원석 on 11/2/24.
//

import UIKit
import SnapKit

final class GifticonViewController: BaseViewController {    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupNavigationBar()
    }
}

private extension GifticonViewController {
    func setupNavigationBar() {
        let label = UILabel()
        label.text = GIFTICON_MENU_TITLE
        label.font = UIFont(name: pretendard_bold, size: 22)
        label.textColor = .grey90
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    }
}
