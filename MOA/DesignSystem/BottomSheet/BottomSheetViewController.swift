//
//  BottomSheetViewController.swift
//  MOA
//
//  Created by 오원석 on 11/9/24.
//

import UIKit
import SnapKit

final class BottomSheetViewController: UIViewController {
    
    private let type: BottomSheetType
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    init(type: BottomSheetType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimation()
    }
}

private extension BottomSheetViewController {
    func setupLayout() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        
        switch type {
        case .Sort:
            contentView.addSubview(SortBottomSheetView(frame: .zero))
        case .Date:
            return
        }
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(type.rawValue)
            $0.bottom.equalToSuperview().offset(type.rawValue)
        }
        
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDismiss))
        view.addGestureRecognizer(dismissTapGesture)
    }
    
    func startAnimation() {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseOut]
        ) { [weak self] in
            guard let `self` = self else {
                MOALogger.loge()
                return
            }
            contentView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.height.equalTo(self.type.rawValue)
                $0.bottom.equalToSuperview()
            }
            contentView.layoutIfNeeded()
        }
    }
}

extension BottomSheetViewController {
    @objc func tapDismiss() {
        dismiss(animated: true)
    }
}
