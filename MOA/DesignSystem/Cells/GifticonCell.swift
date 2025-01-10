//
//  GifticonCell.swift
//  MOA
//
//  Created by 오원석 on 11/10/24.
//

import UIKit
import RxSwift

final class GifticonCell: UICollectionViewCell {
    static let identifier = "GifticonCell"
    
    private let disposeBag = DisposeBag()
    private lazy var ddayButton: DDayButton = {
        let button = DDayButton()
        return button
    }()
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .grey30
        return imageView
    }()
    
    private lazy var storeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_regular, size: 12.0)
        label.textColor = .pink100
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 14.0)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .grey90
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_regular, size: 12.0)
        label.textColor = .grey60
        return label
    }()
    
    private let dimView: UIView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .black.withAlphaComponent(0.2)
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(
        dday: Int,
        imageURL: String,
        storeType: StoreType,
        title: String,
        date: String,
        used: Bool = false
    ) {
        ddayButton.dday = dday
        storeLabel.text = storeType.rawValue
        titleLabel.text = title
        dateLabel.text = date
        
        ImageLoadManager.shared.load(url: imageURL)
            .observe(on: MainScheduler())
            .subscribe(onNext: { [weak self] image in
                guard let self = self else {
                    MOALogger.loge()
                    return
                }
                
                if let image = image {
                    dimView.isHidden = !used
                    imageView.image = image
                    
                }
            }).disposed(by: disposeBag)
        
        if used {
            ddayButton.isHidden = true
            storeLabel.textColor = .grey70
            dateLabel.textColor = .grey70
        }
    }
    
    private func setupLayout() {
        shadowView.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        [
            shadowView,
            ddayButton,
            storeLabel,
            titleLabel,
            dateLabel,
            dimView
        ].forEach {
            addSubview($0)
        }
        
        shadowView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(shadowView.snp.width).multipliedBy(1.0)
        }
        
        dimView.snp.makeConstraints {
            $0.edges.equalTo(shadowView.snp.edges)
        }
        
        ddayButton.snp.makeConstraints {
            $0.top.equalTo(shadowView.snp.top).offset(8)
            $0.left.equalTo(shadowView.snp.left).offset(8)
            $0.height.equalTo(22)
        }
        
        storeLabel.snp.makeConstraints {
            $0.top.equalTo(shadowView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(storeLabel.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
        }
    }
}
