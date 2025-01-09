//
//  MypageMenuCell.swift
//  MOA
//
//  Created by 오원석 on 1/10/25.
//

import UIKit
import SnapKit

enum MenuType: String, CaseIterable {
    case Notification = "알림"
    case Inquery = "문의하기"
    case Version = "버전 정보"
    case Policy = "약관 및 정책"
    case OpenSourceLicense = "오픈소스 라이센스"
    case Logout = "로그아웃"
    case SignOut = "탈퇴하기"
}

final class MypageMenuCell: UITableViewCell {
    static let identifier = "MypageMenuCell"
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grey90
        label.font = UIFont(name: pretendard_bold, size: 15.0)
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grey60
        label.font = UIFont(name: pretendard_regular, size: 13.0)
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: FORWARD_BUTTON_IMAGE_ASSET), for: .normal)
        button.tintColor = .grey60
        return button
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey30
        return view
    }()
    
    var menuType: MenuType = MenuType.Notification {
        didSet {
            nameLabel.text = menuType.rawValue
            infoLabel.isHidden = menuType != .Notification && menuType != .Version
            lineView.isHidden = menuType != .Notification && menuType != .OpenSourceLicense
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(menuType: MenuType) {
        self.menuType = menuType
    }
    
    private func setupLayout() {
        [nameLabel, infoLabel, nextButton, lineView].forEach {
            addSubview($0)
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints {
            $0.trailing.equalTo(nextButton.snp.leading)
            $0.centerY.equalToSuperview()
        }
        
        lineView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}
