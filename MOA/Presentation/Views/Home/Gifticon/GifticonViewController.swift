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
import RxDataSources
import PhotosUI
import MLKitBarcodeScanning
import MLKitVision

protocol GifticonViewControllerDelegate: AnyObject {
    func navigateToGifticonDetail(gifticonId: String)
    func navigateToGifticonRegister()
}

final class GifticonViewController: BaseViewController {
    lazy var gifticonCollectionView: UICollectionView = {
        let width = UIScreen.getWidthByDivision(division: 2, exclude: 20 + 16 + 20) // left + middle + right
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: Double(width), height: Double(width) * 234 / 159.5)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 24
        layout.sectionInset = UIEdgeInsets(top: 24.0, left: 20.0, bottom: 0.0, right: 20.0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GifticonCell.self, forCellWithReuseIdentifier: GifticonCell.identifier)
        collectionView.register(GifticonSkeletonCell.self, forCellWithReuseIdentifier: GifticonSkeletonCell.identifier)
        collectionView.register(GifticonCategoryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GifticonCategoryView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private let floatingButton: FloatingButton = {
        let button = FloatingButton()
        return button
    }()
    
    private lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: EMPTY_GIFTICON)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.setTextWithLineHeight(
            text: GIFTICON_EMPTY_TITLE,
            font: pretendard_medium,
            size: 14.0,
            lineSpacing: 19.6,
            alignment: .center
        )
    
        label.textColor = .grey60
        label.numberOfLines = 2
        return label
    }()
    
    lazy var emptyView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private let categoryRelay: BehaviorRelay<StoreCategory> = BehaviorRelay(value: .ALL)
    private let sortTypeRelay: BehaviorRelay<SortType> = BehaviorRelay(value: .EXPIRE_DATE)
    
    let gifticonViewModel = GifticonViewModel(gifticonService: GifticonService.shared)
    
    weak var delegate: GifticonViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        bind()
    }
}

// MARK: setup
private extension GifticonViewController {
    func setupLayout() {
        [
            gifticonCollectionView,
            floatingButton,
            emptyView
        ].forEach {
            view.addSubview($0)
        }
        
        gifticonCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        floatingButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(56)
        }
        
        emptyView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(48)
            $0.horizontalEdges.equalToSuperview()
        }
        
        [emptyImageView, emptyTitleLabel].forEach {
            emptyView.addSubview($0)
        }
        
        emptyImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(200)
        }
        
        emptyTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(emptyImageView.snp.bottom).offset(12)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind() {
        let input = GifticonViewModel.Input(
            changeCategory: categoryRelay,
            changeSort: sortTypeRelay
        )
        
        let output = gifticonViewModel.transform(input: input)
        
        output.updateGifticons
            .debounce(.milliseconds(50))
            .drive(self.rx.bindGifticons)
            .disposed(by: disposeBag)
                
        floatingButton.rx.tap
            .bind(to: self.rx.tapFloating)
            .disposed(by: disposeBag)
    }
}

// MARK: UICollectionViewDataSource
extension GifticonViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifticonViewModel.gifticonCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let gifticon = gifticonViewModel.gifticons[indexPath.row]
        if gifticon.gifticonId.isEmpty {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GifticonSkeletonCell.identifier,
                for: indexPath
            ) as? GifticonSkeletonCell else {
                return UICollectionViewCell()
            }
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GifticonCell.identifier,
            for: indexPath
        ) as? GifticonCell else {
            return UICollectionViewCell()
        }
        
        cell.gifticon = gifticon
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: GifticonCategoryView.identifier,
                for: indexPath
            ) as? GifticonCategoryView else {
                return UICollectionReusableView()
            }
            
            headerView.sortTitle = sortTypeRelay.value.rawValue
            headerView.delegate = self
            return headerView
        }
        
        return UICollectionReusableView()
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension GifticonViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = Int(UIScreen.main.bounds.width)
        return CGSize(width: width, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let gifticon = gifticonViewModel.gifticons[indexPath.row]
        MOALogger.logd("\(gifticon.gifticonId)")
        self.delegate?.navigateToGifticonDetail(gifticonId: gifticon.gifticonId)
    }
}

// MARK: GifticonCategoryViewDelegate
extension GifticonViewController: GifticonCategoryViewDelegate {
    func didSelectCategory(category: StoreCategory) {
        self.categoryRelay.accept(category)
    }
    
    func showSortTypePopup() {
        let sortType = self.sortTypeRelay.value
        let bottomSheetVC = BottomSheetViewController(sheetType: .Sort, sortType: sortType)
        bottomSheetVC.delegate = self
        UIApplication.shared.topViewController?.present(bottomSheetVC, animated: true)
    }
}

// MARK: BottomSheetDelegate
extension GifticonViewController: BottomSheetDelegate {
    func selectSortType(type: SortType) {
        MOALogger.logd(type.rawValue)
        self.sortTypeRelay.accept(type)
    }
}

// MARK: Reactive
extension Reactive where Base: GifticonViewController {
    var bindGifticons: Binder<[GifticonModel]> {
        return Binder<[GifticonModel]>(self.base) { viewController, gifticons in
            MOALogger.logd("\(gifticons.count)")
            viewController.emptyView.isHidden = !gifticons.isEmpty
            viewController.gifticonCollectionView.reloadData()
            viewController.gifticonCollectionView.layoutIfNeeded()
        }
    }
    
    var tapFloating: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            viewController.delegate?.navigateToGifticonRegister()
        }
    }
}
