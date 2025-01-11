//
//  UnAvailableGifticonBox.swift
//  MOA
//
//  Created by 오원석 on 1/8/25.
//

import UIKit
import SnapKit

final class UnAvailableGifticonBox: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: UNAVAILABLE_GIFTICON)
        return imageView
    }()
    
    private let infoView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.setTextWithLineHeight(
            text: MYPAGE_UNAVAILABLE_GIFTICON,
            font: pretendard_regular,
            size: 14.0,
            lineSpacing: 19.6
        )
        return label
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 16.0)
        label.textColor = .white
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        backgroundColor = .grey90
        layer.cornerRadius = 16.0
        
        infoView.addSubview(titleLabel)
        infoView.addSubview(countLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview()
        }
        
        addSubview(iconImageView)
        addSubview(infoView)
        
        iconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(19.5)
            $0.size.equalTo(60)
        }
        
        infoView.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView.snp.centerY)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(16.0)
        }
    }
}
