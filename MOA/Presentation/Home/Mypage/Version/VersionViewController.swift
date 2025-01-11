//
//  VersionViewController.swift
//  MOA
//
//  Created by 오원석 on 1/11/25.
//

import UIKit
import SnapKit

final class VersionViewController: BaseViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 18.0)
        label.textColor = .grey90
        label.text = MOA_VERSION_TITLE
        return label
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_regular, size: 14.0)
        label.textColor = .grey90
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            label.text = "v\(version) (2025.01.01)"
        }
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
    }
    
    private func setupLayout() {
        setupTopBarWithBackButton(title: MOA_VERSION_TITLE)
        
        [titleLabel, contentLabel].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
}
