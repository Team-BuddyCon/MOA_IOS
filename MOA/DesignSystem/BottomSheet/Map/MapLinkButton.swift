//
//  MapLinkButton.swift
//  MOA
//
//  Created by 오원석 on 1/26/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

enum LinkType: String {
    case Naver = "네이버 지도"
    case Kakao = "카카오맵"
    case Google = "구글 지도"
    
    var image: UIImage? {
        switch self {
        case .Naver:
            return UIImage(named: NAVER_MAP_ICON)
        case .Kakao:
            return UIImage(named: KAKAO_MAP_ICON)
        case .Google:
            return UIImage(named: GOOGLE_MAP_ICON)
        }
    }
}

final class MapLinkButton: UIView {
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = linkType.image
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = linkType.rawValue
        label.font = UIFont(name: pretendard_bold, size: 14.0)
        label.textColor = .grey90
        return label
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey30
        return view
    }()
    
    let linkType: LinkType
    let tap: UITapGestureRecognizer
    
    init(type: LinkType, hasLine: Bool = false) {
        self.tap = UITapGestureRecognizer()
        self.linkType = type
        super.init(frame: .zero)
        setupLayout()
        bind()
        
        self.lineView.isHidden = !hasLine
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(lineView)
        
        iconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.size.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(16)
            $0.centerY.equalToSuperview()
        }
        
        lineView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func bind() {
        self.addGestureRecognizer(tap)
    }
    
}
