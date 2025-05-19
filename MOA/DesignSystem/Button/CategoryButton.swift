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

final class CategoryButton: UIButton {
    private let disposeBag = DisposeBag()
    let category: StoreCategory
    let isClicked = BehaviorRelay(value: false)
    
    init(category: StoreCategory, isClick: Bool = false) {
        self.category = category
        super.init(frame: .zero)
        setup()
        bind()
        
        isClicked.accept(isClick)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    private func setup() {
        setTitle(category.rawValue, for: .normal)
        setTitleColor(.grey60, for: .normal)
        setTitleColor(.white, for: .selected)
    }
    
    private func bind() {
        isClicked
            .bind(to: self.rx.isClicked)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: CategoryButton {
    var isClicked: Binder<Bool> {
        return Binder(self.base) { button, isClicked in
            button.backgroundColor = isClicked ? .pink100 : .white
            button.isSelected = isClicked
        }
    }
}
