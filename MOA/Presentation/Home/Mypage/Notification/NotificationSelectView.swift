//
//  NotificationSelectView.swift
//  MOA
//
//  Created by 오원석 on 1/11/25.
//

import UIKit

final class NotificationSelectView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_regular, size: 15.0)
        return label
    }()
    
    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: CHECK_BUTTON_IMAGE_ASSET)?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .pink100
        imageView.isHidden = true
        return imageView
    }()
    
    var isOn: Bool = false {
        didSet {
            setIsOnState()
        }
    }
    
    let tapGesture: UITapGestureRecognizer
    
    init(
        title: String,
        isOn: Bool = false
    ) {
        tapGesture = UITapGestureRecognizer()
        super.init(frame: .zero)
        self.isOn = isOn
        titleLabel.text = title
        setupLayout()
        setIsOnState()
        
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        [titleLabel, checkImageView].forEach{ addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        checkImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(18)
        }
    }
    
    private func setIsOnState() {
        if isOn {
            titleLabel.font = UIFont(name: pretendard_bold, size: 15.0)
            titleLabel.textColor = .pink100
            checkImageView.isHidden = false
        } else {
            titleLabel.font = UIFont(name: pretendard_regular, size: 15.0)
            titleLabel.textColor = .grey60
            checkImageView.isHidden = true
        }
    }
}
