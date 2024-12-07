//
//  Untitled.swift
//  MOA
//
//  Created by 오원석 on 12/6/24.
//

import UIKit
import SnapKit
import RxSwift

final class ToastView: UIView {
    private let msgLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_medium, size: 13.0)
        label.textColor = .white
        label.numberOfLines = 1
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let disposeBag = DisposeBag()
    
    var message: String? {
        didSet {
            msgLabel.text = message
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        msgLabel.text = message
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .black.withAlphaComponent(0.5)
        layer.cornerRadius = frame.height / 2
    }
    
    private func setupLayout() {
        [msgLabel].forEach {
            addSubview($0)
        }
        
        msgLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }
}
