//
//  GifticonViewController.swift
//  MOA
//
//  Created by 오원석 on 11/2/24.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa

final class GifticonViewController: BaseViewController {
    
    private lazy var categoryStackView: UIStackView = {
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
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.setTitle(gifticonViewModel.sortType.rawValue, for: .normal)
        button.setTitleColor(.grey80, for: .normal)
        button.titleLabel?.font = UIFont(name: pretendard_medium, size: 13.0)
        button.semanticContentAttribute = .forceRightToLeft
        button.setImage(UIImage(named: DOWN_ARROW)?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    private lazy var gifticonCollectionView: UICollectionView = {
        let width = getWidthByDivision(division: 2, exclude: 20 + 16 + 20) // left + middle + right
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: Double(width), height: Double(width) * 234 / 159.5)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 24
        layout.sectionInset = UIEdgeInsets(top: 24.0, left: 20.0, bottom: 0.0, right: 20.0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GifticonCell.self, forCellWithReuseIdentifier: GifticonCell.identifier)
        return collectionView
    }()

    let gifticonViewModel = GifticonViewModel(gifticonService: GifticonService.shared)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        setupData()
        bind()
    }
}

// MARK: setup
private extension GifticonViewController {
    func setupLayout() {
        let label = UILabel()
        label.text = GIFTICON_MENU_TITLE
        label.font = UIFont(name: pretendard_bold, size: 22)
        label.textColor = .grey90
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
        
        [categoryStackView, sortButton, gifticonCollectionView].forEach {
            view.addSubview($0)
        }
        
        categoryStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.left.equalToSuperview().inset(20)
        }
        
        sortButton.snp.makeConstraints {
            $0.centerY.equalTo(categoryStackView)
            $0.right.equalToSuperview().inset(20)
        }
        
        gifticonCollectionView.snp.makeConstraints {
            $0.top.equalTo(categoryStackView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func setupData() {
        if let button = categoryStackView.arrangedSubviews.first as? CategoryButton {
            button.isClicked.accept(true)
        }
        gifticonViewModel.fetch()
    }
    
    func bind() {
        categoryStackView.arrangedSubviews.forEach {
            if let button = $0 as? CategoryButton {
                button.rx.tap
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else {
                            MOALogger.loge()
                            return
                        }
                        
                        button.isClicked.accept(true)
                        categoryStackView.arrangedSubviews
                            .filter { $0 != button }
                            .map { $0 as? CategoryButton }
                            .forEach { $0?.isClicked.accept(false) }
                    }).disposed(by: disposeBag)
            }
        }
        
        sortButton.rx.tap
            .bind(to: self.rx.tapSort)
            .disposed(by: disposeBag)
        
        gifticonViewModel.gifticons
            .bind(to: gifticonCollectionView.rx.items(cellIdentifier: GifticonCell.identifier, cellType: GifticonCell.self)) { row, gifticon, cell in
                cell.setData(
                    dday: gifticon.expireDate.toDday(),
                    imageURL: gifticon.imageUrl,
                    storeType: gifticon.gifticonStore,
                    title: gifticon.name,
                    date: gifticon.expireDate
                )
            }.disposed(by: disposeBag)
        
        gifticonCollectionView.rx.contentOffset
            .map { _ in self.gifticonCollectionView }
            .bind(to: self.rx.scrollOffset)
            .disposed(by: disposeBag)
    }
}

// MARK: BottomSheetDelegate
extension GifticonViewController: BottomSheetDelegate {
    func selectSortType(type: SortType) {
        MOALogger.logd(type.rawValue)
        gifticonViewModel.changeSort(type: type)
        sortButton.setTitle(type.rawValue, for: .normal)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension GifticonViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = gifticonCollectionView.contentOffset.y
        let scrollViewHeight = gifticonCollectionView.bounds.size.height
        let contentHeight = gifticonCollectionView.contentSize.height
        let height = CGFloat(getWidthByDivision(division: 2, exclude: 20 + 16 + 20))
        
        // 스크롤 할 필요 없는 데이터의 양일 때는 페이징 처리하지 않음
        if contentHeight <= scrollViewHeight {
            return
        }
        
        if contentOffsetY + scrollViewHeight + height >= contentHeight, !gifticonViewModel.isScrollEnded, !gifticonViewModel.isLoading {
            gifticonViewModel.isLoading = true
            gifticonViewModel.fetchMore()
        }
    }
}

// MARK: extension
extension Reactive where Base: GifticonViewController {
    var scrollOffset: Binder<UICollectionView> {
        return Binder<UICollectionView>(self.base) { viewController, collectionView in
            let contentOffsetY = collectionView.contentOffset.y
            let scrollViewHeight = collectionView.bounds.size.height
            let contentHeight = collectionView.contentSize.height
            let height = CGFloat(getWidthByDivision(division: 2, exclude: 20 + 16 + 20))
            
            // 스크롤 할 필요 없는 데이터의 양일 때는 페이징 처리하지 않음
            if contentHeight <= scrollViewHeight {
                return
            }
            
            // 카테고리 및 정렬만 바꾸는 경우 호출되지 않도록 처리
            if viewController.gifticonViewModel.isChangedOptions {
                viewController.gifticonViewModel.isChangedOptions = false
                return
            }
            
            if contentOffsetY + scrollViewHeight + height >= contentHeight,
               !viewController.gifticonViewModel.isScrollEnded,
               !viewController.gifticonViewModel.isLoading {
                MOALogger.logd()
                viewController.gifticonViewModel.isLoading = true
                viewController.gifticonViewModel.fetchMore()
            }
        }
    }
    
    var tapSort: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            let bottomSheetVC = BottomSheetViewController(sheetType: .Sort, sortType: viewController.gifticonViewModel.sortType)
            bottomSheetVC.delegate = viewController
            viewController.present(bottomSheetVC, animated: true)
        }
    }
}
