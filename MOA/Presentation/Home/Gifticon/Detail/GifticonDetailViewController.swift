//
//  GifticonDetailViewController.swift
//  MOA
//
//  Created by 오원석 on 12/12/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class GifticonDetailViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        bind()
    }
}

private extension GifticonDetailViewController {
    func setupLayout() {
        setupTopBarWithBackButton(title: GIFTICON_MENU_TITLE)
    }
    
    func bind() {
        
    }
}
