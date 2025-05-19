//
//  GifticonCategoryView.swift
//  MOA
//
//  Created by 오원석 on 4/5/25.
//

import UIKit
import SnapKit
import RxSwift

protocol GifticonCategoryViewDelegate {
    func didSelectCategory(category: StoreCategory)
    func showSortTypePopup()
}

final class GifticonCategoryView: UICollectionReusableView {
    static let identifier = "GifticonCategoryView"
    
    private let disposeBag = DisposeBag()
    
    let categoryStackView: UIStackView = {
        let stackView = UIStackView()
        StoreCategory.allCases.forEach {
            let button = CategoryButton(category: $0, isClick: $0 == StoreCategory.ALL)
            button.titleLabel?.font = UIFont(name: pretendard_medium, size: 14.0)
            button.contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 12.0, bottom: 6.0, right: 12.0)
            button.snp.makeConstraints {
                $0.height.equalTo(32)
            }
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
    
    var delegate: GifticonCategoryViewDelegate?
    var sortTitle: String = SortType.EXPIRE_DATE.rawValue {
        didSet {
            sortButton.setTitle(sortTitle, for: .normal)
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
            view.categoryStackView.arrangedSubviews
                .filter { $0 != button }
                .compactMap { $0 as? CategoryButton }
                .forEach { $0.isClicked.accept(false) }
            
            view.delegate?.didSelectCategory(category: button.category)
        }
    }
    
    var tapSort: Binder<Void> {
        return Binder<Void>(self.base) { view, _ in
            MOALogger.logd()
            view.delegate?.showSortTypePopup()
//            guard let sortType = view.gifticonViewModel?.sortType else { return }
//            let bottomSheetVC = BottomSheetViewController(
//                sheetType: .Sort,
//                sortType: sortType
//            )
//            bottomSheetVC.delegate = view
//            UIApplication.shared.topViewController?.present(bottomSheetVC, animated: true)
        }
    }
}

// MARK: BottomSheetDelegate
extension GifticonCategoryView: BottomSheetDelegate {
    func selectSortType(type: SortType) {
        MOALogger.logd(type.rawValue)
        //gifticonViewModel?.changeSort(type: type)
    }
}
