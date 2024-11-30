//
//  File.swift
//  MOA
//
//  Created by 오원석 on 12/1/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class OtherStoreSheetView: UIView {
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 16.0)
        label.text = OTHER_STORE
        label.textColor = .grey90
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: CLOSE_BUTTON), for: .normal)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        let width = Int(UIScreen.main.bounds.width)
        let height = BottomSheetType.Other_Store.rawValue
        frame = CGRect(x: 0, y: 0, width: width, height: height)
        layer.cornerRadius = 16
        backgroundColor = .white
        
        [titleLabel, closeButton].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(19)
            $0.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(24)
        }
    }
    
}
