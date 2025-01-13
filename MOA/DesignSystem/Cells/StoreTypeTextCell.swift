//
//  StoreTypeTextCell.swift
//  MOA
//
//  Created by 오원석 on 1/12/25.
//

import UIKit

final class StoreTypeTextCell: UICollectionViewCell {
    
    static let identifier = "StoreTypeTextCell"
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_medium, size: 14.0)
        label.text = storeType.rawValue
        label.frame.size = label.intrinsicContentSize
        label.textColor = .grey60
        return label
    }()
    
    var storeType: StoreType = .ALL {
        didSet {
            titleLabel.text = storeType.rawValue
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .pink100 : .white
            titleLabel.textColor = isSelected ? .white : .grey60
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    private func setUp() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
