//
//  GifticonSkeletonCell.swift
//  MOA
//
//  Created by 오원석 on 12/25/24.
//

import UIKit

final class GifticonSkeletonCell: UICollectionViewCell {
    static let identifier = "GifticonSkeletonCell"
    
    private let imageView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey30
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let storeView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey30
        view.layer.cornerRadius = 4
        return view
    }()
    
    private let nameView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey30
        view.layer.cornerRadius = 4
        return view
    }()
    
    private let dateView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey20
        view.layer.cornerRadius = 4
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        [imageView, storeView, nameView, dateView].forEach {
            addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(imageView.snp.width).multipliedBy(1.0)
        }
        
        storeView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
            $0.width.equalTo(58)
            $0.height.equalTo(14)
        }
        
        nameView.snp.makeConstraints {
            $0.top.equalTo(storeView.snp.bottom).offset(5)
            $0.leading.equalToSuperview()
            $0.width.equalTo(108)
            $0.height.equalTo(18)
        }
        
        dateView.snp.makeConstraints {
            $0.top.equalTo(nameView.snp.bottom).offset(11)
            $0.leading.equalToSuperview()
            $0.width.equalTo(81)
            $0.height.equalTo(14)
        }
    }
}
