//
//  WalkThroughPageViewCell.swift
//  MOA
//
//  Created by 오원석 on 9/17/24.
//

import UIKit
import SnapKit

final class WalkThroughPageViewCell: UICollectionViewCell {
    
    static let idendifier = "WalkThroughPageViewCell"
    
    public lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 22.0)
        label.textColor = .grey90
        label.textAlignment = .center
        return label
    }()
    
    public lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_medium, size: 14.0)
        label.textColor = .grey60
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}

private extension WalkThroughPageViewCell {
    func commonInit() {
        [imageView, titleLabel, descLabel].forEach {
            addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(42.5)
            $0.height.equalTo(imageView.snp.width).multipliedBy(300.0/290.0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(48.0)
            $0.horizontalEdges.equalToSuperview().inset(20.0)
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12.0)
            $0.horizontalEdges.equalTo(titleLabel.snp.horizontalEdges)
        }
    }
}
