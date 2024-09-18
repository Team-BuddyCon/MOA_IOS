//
//  WalkThroughPageIndicator.swift
//  MOA
//
//  Created by 오원석 on 9/18/24.
//

import UIKit
import SnapKit

final class WalkThroughPageIndicator: UIView {
    
    var size: Int = 0
    var index: Int = 0 {
        didSet {
            updateIndicator()
        }
    }
    
    private lazy var indicator: UIStackView = {
        var subViews: [UIView] = []
        (0..<size).forEach { _ in
            let view = UIView()
            view.snp.remakeConstraints { $0.size.equalTo(8) }
            view.backgroundColor = .grey50
            view.layer.cornerRadius = 4
            subViews.append(view)
        }
        
        let stackView = UIStackView(arrangedSubviews: subViews)
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    init(size: Int) {
        self.size = size
        super.init(frame: .zero)
        setupLayout()
        updateIndicator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        addSubview(indicator)
        indicator.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func updateIndicator() {
        guard size > 0, size > index else { return }
        indicator.subviews[index].snp.remakeConstraints {
            $0.width.equalTo(30)
            $0.height.equalTo(8)
        }
        indicator.subviews[index].backgroundColor = .grey90
        
        (0..<size).forEach { idx in
            if idx != index {
                indicator.subviews[idx].snp.remakeConstraints {
                    $0.size.equalTo(8)
                }
                indicator.subviews[idx].backgroundColor = .grey50
            }
        }
    }
}
