//
//  StoreTypeCell.swift
//  MOA
//
//  Created by 오원석 on 11/29/24.
//

import UIKit

final class StoreTypeCell: UICollectionViewCell {
    static let identifier = "StoreTypeCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_regular, size: 13.0)
        label.textColor = .grey90
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        [imageView, nameLabel].forEach {
            addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(imageView.snp.width).multipliedBy(1.0)
        }
        
        nameLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    func setData(storeType: StoreType) {
        imageView.image = storeType.image
        nameLabel.text = storeType.rawValue
    }
}
