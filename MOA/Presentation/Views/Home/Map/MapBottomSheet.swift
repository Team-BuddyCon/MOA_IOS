//
//  MapBottomView.swift
//  MOA
//
//  Created by 오원석 on 1/17/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

enum BottomSheetState {
    case Collapsed
    case PartiallyExpanded
    case Expanded
    
    var height: Double {
        switch self {
        case .Collapsed:
            return Double(UIScreen.main.bounds.height) / 852.0 * 36.0
        case .PartiallyExpanded:
            return Double(UIScreen.main.bounds.height) / 852.0 * 120.0
        case .Expanded:
            return Double(UIScreen.main.bounds.height) / 852.0 * 623.0 - 16.0
        }
    }
}

final class MapBottomSheet: UIView {
    let disposeBag = DisposeBag()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey40
        view.layer.cornerRadius = 2.0
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 16.0)
        label.textColor = .grey90
        label.text = MAP_BOTTOM_SHEET_TITLE
        return label
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 24.0)
        label.textColor = .grey90
        return label
    }()
    
    let imminentCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 12.0)
        label.textColor = .pink100
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: ALL_STORE))
        return imageView
    }()
    
    lazy var gifticonCollectionView: UICollectionView = {
        let width = UIScreen.getWidthByDivision(division: 2, exclude: 20 + 16 + 20) // left + middle + right
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: Double(width), height: Double(width) * 234 / 159.5)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 24
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GifticonCell.self, forCellWithReuseIdentifier: GifticonCell.identifier)
        collectionView.register(GifticonSkeletonCell.self, forCellWithReuseIdentifier: GifticonSkeletonCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    var state: BehaviorRelay<BottomSheetState> = BehaviorRelay(value: BottomSheetState.PartiallyExpanded)
    var sheetHeight: BehaviorRelay<Double> = BehaviorRelay(value: BottomSheetState.PartiallyExpanded.height)
    var isDrag: Bool = false
    
    let storeType = BehaviorRelay<StoreType>(value: .ALL)
    let gifticons = BehaviorRelay<[GifticonModel]>(value: [])
    let tapGifticon = PublishRelay<String>()
    let panGesture: UIPanGestureRecognizer

    init(state: BottomSheetState = .PartiallyExpanded) {
        self.panGesture = UIPanGestureRecognizer()
        self.state.accept(state)
        self.sheetHeight.accept(state.height)
        super.init(frame: .zero)
        setupLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 24
        backgroundColor = .white
        
        [
            lineView,
            titleLabel,
            countLabel,
            imminentCountLabel,
            iconImageView,
            gifticonCollectionView
        ].forEach {
            addSubview($0)
        }
        
        lineView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(16)
            $0.height.equalTo(4)
            $0.width.equalTo(32)
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().inset(15)
            $0.size.equalTo(64)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.top).inset(4)
            $0.leading.equalToSuperview().inset(15)
            $0.bottom.equalTo(countLabel.snp.top)
        }
        
        countLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalToSuperview().inset(15)
            $0.bottom.equalTo(iconImageView.snp.bottom).inset(4)
        }
        
        imminentCountLabel.snp.makeConstraints {
            $0.bottom.equalTo(countLabel.snp.bottom).inset(4)
            $0.leading.equalTo(countLabel.snp.trailing).offset(8)
        }
        
        gifticonCollectionView.snp.remakeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        addGestureRecognizer(panGesture)
        
        sheetHeight.asDriver()
            .drive(self.rx.visiblityGifticons)
            .disposed(by: disposeBag)
        
        gifticons.asDriver()
            .drive(self.rx.bindToGifticons)
            .disposed(by: disposeBag)
        
        storeType.asDriver()
            .drive(self.rx.bindToStoreType)
            .disposed(by: disposeBag)
        
        gifticons.asDriver()
            .drive(gifticonCollectionView.rx.items) { collectionView, row, gifticon in
                if gifticon.gifticonId.isEmpty {
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
                
                cell.gifticon = gifticon
                return cell
            }.disposed(by: disposeBag)
        
        gifticonCollectionView.rx.modelSelected(GifticonModel.self)
            .withUnretained(self)
            .subscribe(onNext: { owner, gifticon in
                owner.tapGifticon.accept(gifticon.gifticonId)
            }).disposed(by: disposeBag)
    }
    
    func setSheetHeight(offset: Double) {
        isDrag = true
        let height = sheetHeight.value
        if height < BottomSheetState.Expanded.height + 16.0 && height > 0 {
            sheetHeight.accept(height - offset)
        }
    }
    
    func endSheetGesture(offset: Double) {
        let height = sheetHeight.value
        var currentState = BottomSheetState.Collapsed
        if height > BottomSheetState.Expanded.height {
            currentState = BottomSheetState.Expanded
        } else if height > BottomSheetState.PartiallyExpanded.height {
            currentState = BottomSheetState.PartiallyExpanded
        } else {
            currentState = BottomSheetState.Collapsed
        }
        
        switch currentState {
        case .Collapsed:
            if height < BottomSheetState.Collapsed.height {
                currentState = .Collapsed
            } else {
                if offset < 0 {
                    currentState = .PartiallyExpanded
                }
            }
        case .PartiallyExpanded:
            if offset > 0 {
                currentState = .PartiallyExpanded
            } else {
                currentState = .Expanded
            }
        default:
            break
        }
        
        sheetHeight.accept(currentState.height)
        state.accept(currentState)
    }
}

extension Reactive where Base: MapBottomSheet {
    var visiblityGifticons: Binder<Double> {
        return Binder<Double>(self.base) { sheet, height in
            if height <= BottomSheetState.PartiallyExpanded.height {
                sheet.gifticonCollectionView.snp.remakeConstraints {
                    $0.top.equalTo(sheet.iconImageView.snp.bottom).offset(20)
                    $0.horizontalEdges.equalToSuperview()
                }
            } else {
                sheet.gifticonCollectionView.snp.remakeConstraints {
                    $0.top.equalTo(sheet.iconImageView.snp.bottom).offset(20)
                    $0.horizontalEdges.equalToSuperview()
                    $0.bottom.equalToSuperview()
                }
            }
        }
    }
    
    var bindToStoreType: Binder<StoreType> {
        return Binder<StoreType>(self.base) { sheet, storeType in
            if storeType == .ALL || storeType == .OTHERS {
                sheet.iconImageView.image = UIImage(named: ALL_STORE)
            } else {
                sheet.iconImageView.image = storeType.image
            }
        }
    }
    
    var bindToGifticons: Binder<[GifticonModel]> {
        return Binder<[GifticonModel]>(self.base) { sheetView, gifticons in
            let imminentCount = gifticons.map {
                $0.expireDate
            }.filter {
                $0.toDday() >= 0 && $0.toDday() <= 14
            }.count
            
            sheetView.countLabel.text = String(format: MAP_BOTTOM_SHEET_GIFTICON_COUNT_FORMAT, gifticons.count)
            sheetView.imminentCountLabel.text = String(format: MAP_BOTTOM_SHEET_GIFTICON_COUNT_FORMAT, imminentCount)
            
            sheetView.gifticonCollectionView.reloadData()
            sheetView.gifticonCollectionView.layoutIfNeeded()
        }
    }
}
