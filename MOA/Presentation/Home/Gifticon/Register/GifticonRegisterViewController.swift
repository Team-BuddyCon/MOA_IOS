//
//  GifticonRegisterViewController.swift
//  MOA
//
//  Created by 오원석 on 11/23/24.
//

import UIKit
import SnapKit

final class GifticonRegisterViewController: BaseViewController {
    
    init(image: UIImage? = nil) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
    }

}

private extension GifticonRegisterViewController {
    func setupLayout() {
        setupTopBarWithBackButton(title: "기프티콘 등록하기")
    }
}
