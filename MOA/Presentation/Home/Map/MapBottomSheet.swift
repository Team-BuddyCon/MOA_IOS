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
            return Double(UIScreen.main.bounds.height) / 852.0 * 120.0
        case .PartiallyExpanded:
            return Double(UIScreen.main.bounds.height) / 852.0 * 201.0
        case .Expanded:
            return Double(UIScreen.main.bounds.height) - UIApplication.shared.topBarHeight - UIApplication.shared.safeAreaTopHeight - 64.0
        }
    }
}

final class MapBottomSheet: UIView {
    let disposeBag = DisposeBag()
    
    var state: BehaviorRelay<BottomSheetState> = BehaviorRelay(value: BottomSheetState.PartiallyExpanded)
    var sheetHeight: BehaviorRelay<Double> = BehaviorRelay(value: BottomSheetState.PartiallyExpanded.height)
    var isDrag: Bool = false
    
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
    
    let panGesture: UIPanGestureRecognizer
    var onTapGifticon: ((Int) -> Void)? = nil
    
    // 생성자를 사용하지 않고 프로퍼티로 초기화 -> SnapKit Warning으로 인해 변경
    var mapViewModel: MapViewModel? = nil {
        didSet {
            bind()
        }
    }

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
        
        gifticonCollectionView.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        addGestureRecognizer(panGesture)
        
        guard let mapViewModel = mapViewModel else { return }
        mapViewModel.selectStoreTypeRelay
            .bind(to: self.rx.bindToStoreType)
            .disposed(by: disposeBag)
        
        mapViewModel.gifticonCountRelay
            .bind(to: self.rx.bindToGifticonCount)
            .disposed(by: disposeBag)
        
        mapViewModel.imminentCountRelay
            .bind(to: self.rx.bindToImminentCount)
            .disposed(by: disposeBag)
        
        mapViewModel.gifticons
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
        
        mapViewModel.gifticons
            .observe(on: MainScheduler())
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                gifticonCollectionView.reloadData()
                gifticonCollectionView.layoutIfNeeded()
            }).disposed(by: disposeBag)
        
        gifticonCollectionView.rx.contentOffset
            .map { _ in self.gifticonCollectionView }
            .bind(to: self.rx.scrollOffset)
            .disposed(by: disposeBag)
        
        gifticonCollectionView.rx.modelSelected(AvailableGifticon.self)
            .withUnretained(self)
            .subscribe(onNext: { owner, gifticon in
                guard let onTapGifticon = owner.onTapGifticon else { return }
                onTapGifticon(Int(gifticon.gifticonId) ?? 0)
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
    var bindToStoreType: Binder<StoreType> {
        return Binder<StoreType>(self.base) { sheet, storeType in
            if storeType == .ALL || storeType == .OTHERS {
                sheet.iconImageView.image = UIImage(named: ALL_STORE)
            } else {
                sheet.iconImageView.image = storeType.image
            }
        }
    }
    
    var bindToGifticonCount: Binder<Int> {
        return Binder<Int>(self.base) { sheetView, count in
            sheetView.countLabel.text = String(format: MAP_BOTTOM_SHEET_GIFTICON_COUNT_FORMAT, count)
        }
    }
    
    var bindToImminentCount: Binder<Int> {
        return Binder<Int>(self.base) { sheetView, count in
            sheetView.imminentCountLabel.text = String(format: MAP_BOTTOM_SHEET_IMMINENT_GIFTICON_COUNT_FORMAT, count)
        }
    }
    
    var scrollOffset: Binder<UICollectionView> {
        return Binder<UICollectionView>(self.base) { sheetView, collectionView in
            let contentOffsetY = collectionView.contentOffset.y
            let scrollViewHeight = collectionView.bounds.size.height
            let contentHeight = collectionView.contentSize.height
            let height = CGFloat(UIScreen.getWidthByDivision(division: 2, exclude: 20 + 16 + 20))
            
            // 스크롤 할 필요 없는 데이터의 양일 때는 페이징 처리하지 않음
            if contentHeight <= scrollViewHeight {
                return
            }
            
            guard let mapViewModel = sheetView.mapViewModel else { return }
            if contentOffsetY + scrollViewHeight + height >= contentHeight,
               !mapViewModel.isScrollEnded,
               !mapViewModel.isLoading {
                MOALogger.logd()
                mapViewModel.isLoading = true
                mapViewModel.fetchMore()
            }
        }
    }
}
