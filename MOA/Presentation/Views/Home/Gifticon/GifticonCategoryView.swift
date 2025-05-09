//
//  GifticonCategoryView.swift
//  MOA
//
//  Created by 오원석 on 4/5/25.
//

import UIKit
import SnapKit
import RxSwift

final class GifticonCategoryView: UICollectionReusableView {
    static let identifier = "GifticonCategoryView"
    
    private let disposeBag = DisposeBag()
    
    let categoryStackView: UIStackView = {
        let stackView = UIStackView()
        StoreCategory.allCases.forEach {
            let button = CategoryButton(frame: .zero, category: $0)
            button.titleLabel?.font = UIFont(name: pretendard_medium, size: 14.0)
            button.contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 12.0, bottom: 6.0, right: 12.0)
            button.snp.makeConstraints { $0.height.equalTo(32) }
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }()
    
    let sortButton: UIButton = {
        let button = UIButton()
        button.setTitle(SortType.EXPIRE_DATE.rawValue, for: .normal)
        button.setTitleColor(.grey80, for: .normal)
        button.titleLabel?.font = UIFont(name: pretendard_medium, size: 13.0)
        button.semanticContentAttribute = .forceRightToLeft
        button.setImage(UIImage(named: DOWN_ARROW)?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    weak var gifticonViewModel: GifticonViewModel? {
        didSet {
            gifticonViewModel?.sortTitle
                .asObservable()
                .bind(to: sortButton.rx.title())
                .disposed(by: disposeBag)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(categoryStackView)
        addSubview(sortButton)
        
        categoryStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        sortButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        if let button = categoryStackView.arrangedSubviews.first as? CategoryButton {
            button.isClicked.accept(true)
        }
    }
    
    private func bind() {
        categoryStackView.arrangedSubviews.forEach {
            if let button = $0 as? CategoryButton {
                button.rx.tap
                    .map { button }
                    .bind(to: self.rx.tapCategory)
                    .disposed(by: disposeBag)
            }
        }
        
        sortButton.rx.tap
            .bind(to: self.rx.tapSort)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: GifticonCategoryView {
    var tapCategory: Binder<CategoryButton> {
        return Binder<CategoryButton>(self.base) { view, button in
            button.isClicked.accept(true)
            view.gifticonViewModel?.changeCategory(category: button.category)
            view.categoryStackView.arrangedSubviews
                .filter { $0 != button }
                .map { $0 as? CategoryButton }
                .forEach { $0?.isClicked.accept(false) }
        }
    }
    
    var tapSort: Binder<Void> {
        return Binder<Void>(self.base) { view, _ in
            MOALogger.logd()
            guard let sortType = view.gifticonViewModel?.sortType else { return }
            let bottomSheetVC = BottomSheetViewController(
                sheetType: .Sort,
                sortType: sortType
            )
            bottomSheetVC.delegate = view
            UIApplication.shared.topViewController?.present(bottomSheetVC, animated: true)
        }
    }
}

// MARK: BottomSheetDelegate
extension GifticonCategoryView: BottomSheetDelegate {
    func selectSortType(type: SortType) {
        MOALogger.logd(type.rawValue)
        gifticonViewModel?.changeSort(type: type)
    }
}
