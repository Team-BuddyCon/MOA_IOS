//
//  CategoryButton.swift
//  MOA
//
//  Created by 오원석 on 11/5/24.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

enum StoreCategory: String, CaseIterable {
    case All = "전체"
    case Cafe = "카페"
    case ConvenienceStore = "편의점"
    case Etc = "기타"
}

final class CategoryButton: UIButton {
    
    private let disposeBag = DisposeBag()
    let category: StoreCategory
    var isClicked = BehaviorRelay(value: false)
    
    init(
        frame: CGRect,
        category: StoreCategory
    ) {
        self.category = category
        super.init(frame: frame)
        setUp()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    private func setUp() {
        setTitle(category.rawValue, for: .normal)
        setTitleColor(.grey60, for: .normal)
        setTitleColor(.white, for: .selected)
    }
    
    private func update() {
        isClicked.asDriver()
            .drive { [weak self] isClicked in
                guard let `self` = self else { return }
                MOALogger.logd("\(String(describing: category.rawValue)) \(isClicked)")
                backgroundColor = isClicked ? .pink100 : .white
                isSelected = isClicked
            }.disposed(by: disposeBag)
    }
}
