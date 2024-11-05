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

enum StoreCategory: String {
    case All = "전체"
    case Cafe = "카페"
    case ConvenienceStore = "편의점"
    case Etc = "기타"
}

final class CategoryButton: UIButton {
    
    let category: StoreCategory
    var isClicked = BehaviorRelay(value: false)
    
    init(
        frame: CGRect,
        category: StoreCategory
    ) {
        self.category = category
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    func setUp() {
        setTitle(category.rawValue, for: .normal)
        setTitleColor(.white, for: .normal)
        setTitleColor(.grey60, for: .selected)
    }
}

extension Reactive where Base: CategoryButton {
    var isClicked: Binder<Bool> {
        return Binder<Bool>(self.base) { button, isClick in
            button.backgroundColor = isClick ? .pink100 : .white
            button.isSelected = isClick
        }
    }
}
