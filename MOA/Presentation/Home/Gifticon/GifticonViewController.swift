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
import PhotosUI
import MLKitBarcodeScanning
import MLKitVision

final class GifticonViewController: BaseViewController {
    
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
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.setTitle(gifticonViewModel.sortType.rawValue, for: .normal)
        button.setTitleColor(.grey80, for: .normal)
        button.titleLabel?.font = UIFont(name: pretendard_medium, size: 13.0)
        button.semanticContentAttribute = .forceRightToLeft
        button.setImage(UIImage(named: DOWN_ARROW)?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
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

    private var isFirstEntry = true
    let gifticonViewModel = GifticonViewModel(gifticonService: GifticonService.shared)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        setupData()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MOALogger.logd()
        gifticonViewModel.fetchAllGifticons()
    }
}

// MARK: setup
private extension GifticonViewController {
    func setupLayout() {
        [
            categoryStackView,
            sortButton,
            gifticonCollectionView,
            floatingButton,
            emptyView
        ].forEach {
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
        
        floatingButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(56)
        }
        
        emptyView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
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
    
    func setupData() {
        if let button = categoryStackView.arrangedSubviews.first as? CategoryButton {
            button.isClicked.accept(true)
        }
        
        gifticonViewModel.fetchAllGifticons()
    }
    
    func bind() {
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
        
        gifticonViewModel.gifticons
            .bind(to: gifticonCollectionView.rx.items) { collectionView, row, gifticon in
                if gifticon.gifticonId == "" {
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: GifticonSkeletonCell.identifier,
                        for: IndexPath(row: row, section: 0)
                    ) as? GifticonSkeletonCell else {
                        return UICollectionViewCell()
                    }
                    return cell
                }

                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: GifticonCell.identifier,
                    for: IndexPath(row: row, section: 0)
                ) as? GifticonCell else {
                    return UICollectionViewCell()
                }
                
                cell.setData(
                    dday: gifticon.expireDate.toDday(),
                    imageURL: gifticon.imageUrl,
                    storeType: gifticon.gifticonStore,
                    title: gifticon.name,
                    date: gifticon.expireDate
                )
                return cell
            }.disposed(by: disposeBag)
        
        gifticonViewModel.gifticons
            .observe(on: MainScheduler())
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                gifticonCollectionView.reloadData()
                gifticonCollectionView.layoutIfNeeded()
            }).disposed(by: disposeBag)
        
        gifticonViewModel.gifticons
            .map { $0.isEmpty }
            .bind(to: self.rx.isEmptyUI)
            .disposed(by: disposeBag)
        
//        gifticonCollectionView.rx.contentOffset
//            .map { _ in self.gifticonCollectionView }
//            .bind(to: self.rx.scrollOffset)
//            .disposed(by: disposeBag)
        
        gifticonCollectionView.rx.modelSelected(AvailableGifticon.self)
            .subscribe(onNext: { [weak self] gifticon in
                guard let self = self else { return }
                MOALogger.logd("\(gifticon.gifticonId)")
                let detailVC = GifticonDetailViewController(gifticonId: Int(gifticon.gifticonId) ?? 0)
                navigationController?.pushViewController(detailVC, animated: true)
            }).disposed(by: disposeBag)
        
        gifticonViewModel.sortTitle
            .asObservable()
            .bind(to: sortButton.rx.title())
            .disposed(by: disposeBag)
        
        floatingButton.rx.tap
            .bind(to: self.rx.tapFloating)
            .disposed(by: disposeBag)
        
    }
}

// MARK: BottomSheetDelegate
extension GifticonViewController: BottomSheetDelegate {
    func selectSortType(type: SortType) {
        MOALogger.logd(type.rawValue)
        gifticonViewModel.changeSort(type: type)
    }
}

// MARK: extension
extension Reactive where Base: GifticonViewController {
    var tapSort: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            let bottomSheetVC = BottomSheetViewController(sheetType: .Sort, sortType: viewController.gifticonViewModel.sortType)
            bottomSheetVC.delegate = viewController
            viewController.present(bottomSheetVC, animated: true)
        }
    }
    
    var tapFloating: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            configuration.selectionLimit = 1
            configuration.filter = .images
            
            let pickerVC = PHPickerViewController(configuration: configuration)
            pickerVC.delegate = viewController
            viewController.present(pickerVC, animated: true)
        }
    }
    
    var tapCategory: Binder<CategoryButton> {
        return Binder<CategoryButton>(self.base) { viewController, button in
            button.isClicked.accept(true)
            viewController.gifticonViewModel.changeCategory(category: button.category)
            viewController.categoryStackView.arrangedSubviews
                .filter { $0 != button }
                .map { $0 as? CategoryButton }
                .forEach { $0?.isClicked.accept(false) }
        }
    }
    
    var isEmptyUI: Binder<Bool> {
        return Binder<Bool>(self.base) { viewController, isEmpty in
            MOALogger.logd("\(isEmpty)")
            viewController.emptyView.isHidden = !isEmpty
            viewController.gifticonCollectionView.isHidden = isEmpty
        }
    }
}

extension GifticonViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        MOALogger.logd()
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                guard let self = self else {
                    MOALogger.loge()
                    return
                }
                
                if error != nil {
                    // TODO 에러 팝업 노출
                    MOALogger.loge("PHPicker load Image error: \(error?.localizedDescription)")
                    let modalVC = ModalViewController(
                        modalType: .alertDetail,
                        title: GIFTICON_REGISTER_NOT_BARCODE_IMAGE_ERROR_TITLE,
                        subTitle: GIFTICON_REGISTER_NOT_BARCODE_IMAGE_ERROR_SUBTITLE,
                        confirmText: CONFIRM
                    )
                    present(modalVC, animated: true)
                    return
                }
                
                checkBarcodeImage(image: image as? UIImage)
            }
        }
    }
    
    private func checkBarcodeImage(image: UIImage?) {
        guard let image = image else {
            // TODO 에러 팝업 노출
            MOALogger.loge("PHPicker load Image is nil")
            return
        }
        
        let barcodeOptions = BarcodeScannerOptions()
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        
        let barcodeScanner = BarcodeScanner.barcodeScanner(options: barcodeOptions)
        barcodeScanner.process(visionImage) { [weak self] features, error in
            guard let self = self else {
                MOALogger.loge()
                return
            }
            
            guard error == nil, let features = features, !features.isEmpty else {
                MOALogger.loge("PHPicker image is not contained barcode")
                let modalVC = ModalViewController(
                    modalType: .alertDetail,
                    title: GIFTICON_REGISTER_NOT_BARCODE_IMAGE_ERROR_TITLE,
                    subTitle: GIFTICON_REGISTER_NOT_BARCODE_IMAGE_ERROR_SUBTITLE,
                    confirmText: CONFIRM
                )
                present(modalVC, animated: true)
                return
            }
            
            MOALogger.logd()
            let registerVC = GifticonRegisterViewController(image: image)
            navigationController?.pushViewController(registerVC, animated: true)
        }
    }
}
