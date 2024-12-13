//
//  DetailInfoView.swift
//  MOA
//
//  Created by 오원석 on 12/12/24.
//

import UIKit
import SnapKit

final class DetailInfoView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_medium, size: 14.0)
        label.textColor = .grey70
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 15.0)
        label.textColor = .grey90
        return label
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey30
        return view
    }()
    
    init(title: String, info: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        infoLabel.text = info
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        [titleLabel, infoLabel, lineView].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.top)
            $0.leading.equalToSuperview().inset(68)
            $0.trailing.equalToSuperview()
        }
        
        lineView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}
