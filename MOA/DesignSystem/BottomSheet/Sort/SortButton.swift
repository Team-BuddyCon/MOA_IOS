//
//  SortButton.swift
//  MOA
//
//  Created by 오원석 on 11/9/24.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa

final class SortButton: UIView {
    private let disposeBag = DisposeBag()
    let type: SortType
    let isSelected = BehaviorRelay(value: false)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = type.rawValue
        return label
    }()
    
    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .pink100
        imageView.image = UIImage(named: CHECK_BUTTON_IMAGE_ASSET)?.withRenderingMode(.alwaysTemplate)
        return imageView
    }()
    
    init(type: SortType) {
        self.type = type
        super.init(frame: .zero)
        setupLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        [titleLabel, checkImageView].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(20)
        }
        
        checkImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(20)
            $0.size.equalTo(18)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapSortButton))
        addGestureRecognizer(tapGesture)
    }
    
    func bind() {
        isSelected.asDriver()
            .drive(onNext: { [weak self] isSelect in
                guard let self = self else {
                    MOALogger.loge()
                    return
                }
                titleLabel.font = UIFont(name: isSelect ? pretendard_bold : pretendard_medium, size: 14.0)
                titleLabel.textColor = isSelect ? .pink100 : .grey60
                checkImageView.isHidden = !isSelect
            }).disposed(by: disposeBag)
    }
    
    @objc private func tapSortButton() {
        isSelected.accept(!isSelected.value)
    }
}
