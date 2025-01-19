//
//  MapViewController.swift
//  MOA
//
//  Created by 오원석 on 11/2/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import KakaoMapsSDK

final class MapViewController: BaseViewController {
    
    let storeTypes: [StoreType] = StoreType.allCases
    private lazy var storeTypeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(StoreTypeTextCell.self, forCellWithReuseIdentifier: StoreTypeTextCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let mapBottomSheet: MapBottomSheet = {
        let bottomSheet = MapBottomSheet()
        return bottomSheet
    }()
    
    private var kmAuth: Bool = false
    var mapManager: KakaoMapManager?
    let mapViewModel = MapViewModel(
        gifticonService: GifticonService.shared,
        kakaoService: KakaoService.shared
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupMap()
        setupLayout()
        setupData()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MOALogger.logd()
        mapManager?.addObserver()
        mapViewModel.getGifticonCount()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MOALogger.logd()
        
        if mapManager?.isEngineActive == false {
            mapManager?.activateEngine()
            mapViewModel.searchPlaceByKeyword()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapManager?.kmAuth = false
        mapManager?.removeObserver()
        mapManager?.pauseEngine()
        super.viewWillDisappear(animated)
        MOALogger.logd()
    }
}

private extension MapViewController {
    func setupMap() {
        let width = Int(UIScreen.main.bounds.width)
        let height = Int(UIScreen.main.bounds.height) - (Int(navigationController?.navigationBar.frame.height ?? 0) + 16)
        mapManager = KakaoMapManager(rect: CGRect(x: 0, y: 0, width: width, height: height))
        mapManager?.delegate = mapManager
        mapManager?.prepareEngine()
    }
    
    func setupLayout() {
        guard let kmContrainer = mapManager?.container else { return }
        [
            storeTypeCollectionView,
            kmContrainer,
            mapBottomSheet
        ].forEach {
            view.addSubview($0)
        }
        
        storeTypeCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.left.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        kmContrainer.snp.makeConstraints {
            $0.top.equalTo(storeTypeCollectionView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        mapBottomSheet.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(mapBottomSheet.sheetHeight.value)
        }
    }
    
    func setupData() {
        let firstIndexPath = IndexPath(item: 0, section: 0)
        storeTypeCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .centeredHorizontally)
    }
    
    func bind() {
        mapViewModel.searchPlaceRelay
            .bind(to: self.rx.bindToSearchPlaces)
            .disposed(by: disposeBag)
        
        mapBottomSheet.panGesture.rx.event
            .withUnretained(self)
            .subscribe(onNext: { this, gesture in
                gesture.translation(in: this.view)
                
                let velocity = gesture.velocity(in: self.view)
                let offset = velocity.y / 50
                switch gesture.state {
                case .began, .changed:
                    this.mapBottomSheet.setSheetHeight(offset: offset)
                case .ended:
                    this.mapBottomSheet.endSheetGesture(offset: offset)
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        mapBottomSheet.state
            .bind(to: self.rx.bindToBottomSheetState)
            .disposed(by: disposeBag)
        
        mapBottomSheet.sheetHeight
            .bind(to: self.rx.bindToBottomSheetHeight)
            .disposed(by: disposeBag)
        
        mapViewModel.gifticonCountRelay
            .bind(to: self.rx.bindToGifticonCount)
            .disposed(by: disposeBag)
        
        mapViewModel.imminentCountRelay
            .bind(to: self.rx.bindToImminentCount)
            .disposed(by: disposeBag)
        
        mapViewModel.selectStoreTypeRelay
            .bind(to: self.mapBottomSheet.rx.bindToStoreType)
            .disposed(by: disposeBag)
    }
}

extension MapViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storeTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreTypeTextCell.identifier, for: indexPath) as? StoreTypeTextCell else {
            return UICollectionViewCell()
        }
        
        cell.storeType = storeTypes[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let storeType = storeTypes[indexPath.row].rawValue
        let font = UIFont(name: pretendard_medium, size: 14.0)
        let textSize = storeType.size(withAttributes: [.font: font as Any])
        return CGSize(width: textSize.width + 24.0, height: 32.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storeType = storeTypes[indexPath.row]
        mapViewModel.selectStoreTypeRelay.accept(storeType)
        mapViewModel.searchPlaceByKeyword()
        mapViewModel.getGifticonCount()
    }
}

extension Reactive where Base: MapViewController {
    var bindToSearchPlaces: Binder<[SearchPlace]> {
        return Binder<[SearchPlace]>(self.base) { viewController, searchPlaces in
            let storeType = viewController.mapViewModel.selectStoreTypeRelay.value
            viewController.mapManager?.createPois(
                searchPlaces: searchPlaces,
                storeType: storeType,
                scale: 0.3
            )
        }
    }
    
    var bindToBottomSheetState: Binder<BottomSheetState> {
        return Binder<BottomSheetState>(self.base) { viewController, state in
            UIView.animate(withDuration: 0.5, delay: 0.0,options: .curveEaseInOut) {
                viewController.mapBottomSheet.snp.remakeConstraints {
                    $0.bottom.equalToSuperview()
                    $0.horizontalEdges.equalToSuperview()
                    $0.height.equalTo(state.height)
                }
                viewController.view.layoutIfNeeded()
            }
        }
    }
    
    var bindToBottomSheetHeight: Binder<Double> {
        return Binder<Double>(self.base) { viewController, height in
            if !viewController.mapBottomSheet.isDrag {
                viewController.mapBottomSheet.isDrag = false
                return
            }
            
            viewController.mapBottomSheet.snp.remakeConstraints {
                $0.bottom.equalToSuperview()
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(height)
            }
        }
    }
    
    var bindToGifticonCount: Binder<Int> {
        return Binder<Int>(self.base) { viewController, count in
            viewController.mapBottomSheet.gifticonCount = count
        }
    }
    
    var bindToImminentCount: Binder<Int> {
        return Binder<Int>(self.base) { viewController, count in
            viewController.mapBottomSheet.imminentCount = count
        }
    }
}
