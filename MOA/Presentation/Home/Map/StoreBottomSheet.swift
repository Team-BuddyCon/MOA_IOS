//
//  StoreBottomSheet.swift
//  MOA
//
//  Created by 오원석 on 1/24/25.
//

import UIKit
import SnapKit

final class StoreBottomSheet: UIView {
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey40
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 16.0)
        label.textColor = .grey90
        return label
    }()
    
    private let distInfoLabel: UILabel = {
        let label = UILabel()
        label.text = MAP_DISTANCE
        label.font = UIFont(name: pretendard_bold, size: 12.0)
        label.textColor = .grey90
        return label
    }()
    
    private let distLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_regular, size: 12.0)
        label.textColor = .grey90
        return label
    }()
    
    private let findPathButton: CommonButton = {
        let button = CommonButton(title: MAP_FIND_PATH)
        return button
    }()
    
    private let addressCopyButton: CommonButton = {
        let button = CommonButton(status: .used, title: MAP_ADDRESS_COPY)
        return button
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 24
        backgroundColor = .white
        
        self.snp.makeConstraints {
            $0.height.equalTo(180)
        }
        
        [
            titleLabel,
            distInfoLabel,
            distLabel,
            findPathButton,
            addressCopyButton
        ].forEach {
            infoView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        distInfoLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
        }
        
        distLabel.snp.makeConstraints {
            $0.centerY.equalTo(distInfoLabel.snp.centerY)
            $0.leading.equalTo(distInfoLabel.snp.trailing).offset(16)
        }
        
        let buttonW = UIScreen.getWidthByDivision(division: 2, exclude: 48)
        findPathButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.height.equalTo(54)
            $0.width.equalTo(buttonW)
        }
        
        addressCopyButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.height.equalTo(54)
            $0.width.equalTo(buttonW)
        }
        
        [
            lineView,
            infoView
        ].forEach {
            addSubview($0)
        }
        
        lineView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(4)
            $0.width.equalTo(32)
        }
        
        infoView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
    
    func setUp(
        store: String,
        distance: String
    ) {
        titleLabel.text = store
        distLabel.text = String(format: MAP_DISTANCE_FORMAT, distance)
        layoutIfNeeded()
    }
}
