//
//  SignUpCompleteViewController.swift
//  MOA
//
//  Created by 오원석 on 10/23/24.
//

import UIKit
import SnapKit

final class SignUpCompleteViewController: BaseViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: SIGNUP_COMPLETE_ICON_ASSET))
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 30.0)
        label.setRangeFontColor(text: SIGNUP_COMPLETE_TITLE, startIndex: 0, endIndex: 4, color: .pink100)
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.setTextWithLineHeight(
            text: String(format: SIGNUP_COMPLETE_SUBTITLE_FORMAT, name),
            font: pretendard_medium,
            size: 16.0,
            lineSpacing: 22.4,
            alignment: .left
        )
        label.numberOfLines = 2
        label.textColor = .grey90
        return label
    }()
    
    private lazy var startButton: CommonButton = {
        let button = CommonButton(title: LETS_START, fontSize: 16.0)
        button.addTarget(self, action: #selector(tapStartButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var name: String
    
    init(name: String) {
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupAppearance()
    }
    
    private func setupAppearance() {
        [imageView, titleLabel, subTitleLabel].forEach { infoView.addSubview($0) }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.size.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        [infoView, startButton].forEach { view.addSubview($0) }
        
        infoView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(280)
            $0.bottom.equalToSuperview().inset(360)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        startButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
            $0.height.equalTo(54)
        }
    }
    
    @objc func tapStartButton() {
        MOALogger.logd()
    }
}
