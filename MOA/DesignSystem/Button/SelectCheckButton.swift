//
//  NotificationSelectView.swift
//  MOA
//
//  Created by 오원석 on 1/11/25.
//

import UIKit

final class SelectCheckButton: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_regular, size: 15.0)
        return label
    }()
    
    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: CHECK_RED_BUTTON_IMAGE_ASSET)
        imageView.isHidden = true
        return imageView
    }()
    
    var isSelect: Bool = false {
        didSet {
            updateBySelect()
        }
    }
    
    let tapGesture: UITapGestureRecognizer
    
    init(
        title: String,
        isOn: Bool = false
    ) {
        tapGesture = UITapGestureRecognizer()
        super.init(frame: .zero)
        self.isSelect = isOn
        titleLabel.text = title
        setupLayout()
        updateBySelect()
        
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
    
    private func updateBySelect() {
        if isSelect {
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
