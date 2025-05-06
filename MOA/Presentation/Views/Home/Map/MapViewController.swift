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
    
    let mapBottomSheet: MapBottomSheet =  MapBottomSheet()
    
    private let guideToastLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_medium, size: 13.0)
        label.textColor = .grey70
        label.setRangeFontColor(text: MAP_GUIDE_TOAST_VIEW_TITLE, startIndex: 9, endIndex: 18, color: .pink100)
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    private lazy var guideToastView: UIView = {
        let view = UIView()
        view.addSubview(guideToastLabel)
        view.layer.cornerRadius = 21
        view.backgroundColor = .white
        view.clipsToBounds = false
        view.applyShadow(
            color: UIColor.black.cgColor,
            opacity: 0.4,
            blur: 10,
            x: 0.0,
            y: 2.0
        )
        
        guideToastLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        return view
    }()
    
    private lazy var permissionGuideLabel: UILabel = {
        let label = UILabel()
        label.text = MAP_PERMISSION_GUIDE_MESSAGE
        label.font = UIFont(name: pretendard_medium, size: 13.0)
        label.textColor = .grey70
        return label
    }()
    
    private lazy var navigateSettingLabel: UILabel = {
        let label = UILabel()
        label.text = MAP_NAVIGATE_SETTING_MESSAGE
        label.font = UIFont(name: pretendard_medium, size: 13.0)
        label.textColor = .pink100
        label.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openSetting))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    lazy var permissionGuideToastView: UIView = {
        let view = UIView()
        view.addSubview(permissionGuideLabel)
        view.addSubview(navigateSettingLabel)
        view.layer.cornerRadius = 21
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.applyShadow(
            color: UIColor.black.withAlphaComponent(0.1).cgColor,
            opacity: 1,
            blur: 10,
            x: 0.0,
            y: 2.0
        )
        
        permissionGuideLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        navigateSettingLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        return view
    }()
    
    private var kmAuth: Bool = false
    var mapManager: KakaoMapManager?
    let mapViewModel = MapViewModel(
        gifticonService: GifticonService.shared,
        kakaoService: KakaoService.shared
    )
    
    var isActive: Bool = true
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MOALogger.logd()
        
        // 최초 권한 팝업: viewWillAppear -> willResignActive -> viewDidAppear
        // 엔진은 앱이 활성화 상태에서만 가능 -> 마커 추가, 지도 표시, 카메라 이동 등
        if isActive {
            if mapManager?.isEngineActive == false {
                mapManager?.activateEngine()
            }
            
            mapViewModel.refresh()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        MOALogger.logd()
        mapManager?.kmAuth = false
        mapManager?.removeObserver()
        mapManager?.pauseEngine()
        super.viewWillDisappear(animated)
    }
}

private extension MapViewController {
    func setupMap() {
        let width = Int(UIScreen.main.bounds.width)
        let height = Int(UIScreen.main.bounds.height) - (Int(navigationController?.navigationBar.frame.height ?? 0) + 16)
        mapManager = KakaoMapManager(rect: CGRect(x: 0, y: 0, width: width, height: height))
        mapManager?.delegate = mapManager
        mapManager?.eventDelegate = self
        mapManager?.prepareEngine()
    }
    
    func setupLayout() {
        guard let kmContrainer = mapManager?.container else { return }
        [
            storeTypeCollectionView,
            kmContrainer,
            guideToastView,
            mapBottomSheet,
            dimView,
            permissionGuideToastView
        ].forEach {
            view.addSubview($0)
        }
        
        storeTypeCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.left.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        kmContrainer.snp.makeConstraints {
            $0.top.equalTo(storeTypeCollectionView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        guideToastView.snp.makeConstraints {
            $0.top.equalTo(kmContrainer.snp.top).inset(16)
            $0.centerX.equalTo(kmContrainer.snp.centerX)
            $0.height.equalTo(42)
            $0.width.equalTo(262)
        }
        
        mapBottomSheet.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(mapBottomSheet.sheetHeight.value)
        }
        
        dimView.snp.makeConstraints {
            $0.top.equalTo(storeTypeCollectionView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        permissionGuideToastView.snp.makeConstraints {
            $0.top.equalTo(dimView.snp.top).inset(16)
            $0.centerX.equalTo(dimView.snp.centerX)
            $0.width.equalTo(337)
            $0.height.equalTo(42)
        }
    }
    
    func setupData() {
        // mapBottomSheet 초기화
        mapBottomSheet.mapViewModel = mapViewModel
        mapBottomSheet.onTapGifticon = { gifticonId in
            let detailVC = GifticonDetailViewController(gifticonId: gifticonId)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        
        // storeTypeCollectionView 초기화
        let firstIndexPath = IndexPath(item: 0, section: 0)
        storeTypeCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .centeredHorizontally)
        
        // 초기 데이터 호출
        mapViewModel.fetchAllGifticons()
    }
    
    func bind() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
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
        
        LocationManager.shared.isGranted
            .bind(to: self.rx.bindToLocationPermission)
            .disposed(by: disposeBag)
    }
}

extension MapViewController: KakaoMapEventDelegate {
    func poiDidTapped(kakaoMap: KakaoMap, layerID: String, poiID: String, position: MapPoint) {
        MOALogger.logd("\(poiID) \(layerID) \(position.wgsCoord.longitude) \(position.wgsCoord.latitude)")
        if layerID != LayerID.Cafe.rawValue &&
            layerID != LayerID.FastFood.rawValue &&
            layerID != LayerID.Store.rawValue {
            return
        }
        
        let x = String(String(position.wgsCoord.longitude).prefix(10))
        let y = String(String(position.wgsCoord.latitude).prefix(10))
        let searchPlace = mapViewModel.searchPlaceRelay.value.first {
            String($0.x.prefix(10)) == x && String($0.y.prefix(10)) == y
        }
        
        if let searchPlace = searchPlace {
            let storeBottomSheetVC = MapStoreBottomSheetViewController()
            storeBottomSheetVC.searchPlace = searchPlace
            storeBottomSheetVC.delegate = self
            self.present(storeBottomSheetVC, animated: true)
        }
        
        let manager = kakaoMap.getLabelManager()
        let layer = manager.getLabelLayer(layerID: layerID)
        let poi = layer?.getPoi(poiID: poiID)
        let styleID = StyleID.styleID(rank: poi?.rank)
        poi?.changeStyle(styleID: styleID.selectStyleID.rawValue, enableTransition: true)
        poi?.rank = styleID.selectStyleID.rank
        poi?.show()
        
        mapViewModel.selectedLayerID = layerID
        mapViewModel.selectedPoiID = poiID
        mapBottomSheet.isHidden = true
    }
}

extension MapViewController: MapStoreBottomSheetDelegate {
    func dismiss() {
        MOALogger.logd()
        guard let layerID = mapViewModel.selectedLayerID else { return }
        guard let poiID = mapViewModel.selectedPoiID else { return }
        let manager = mapManager?.kakaoMap?.getLabelManager()
        let layer = manager?.getLabelLayer(layerID: layerID)
        let poi = layer?.getPoi(poiID: poiID)
        let styleID = StyleID.styleID(rank: poi?.rank)
        poi?.changeStyle(styleID: styleID.selectStyleID.rawValue)
        poi?.rank = styleID.selectStyleID.rank
        poi?.show()
        
        mapViewModel.selectedLayerID = nil
        mapViewModel.selectedPoiID = nil
        mapBottomSheet.isHidden = false
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
        mapViewModel.changeStoreType(storeType: storeType)

        // 기타는 마커 표시하지 않음
        if storeType == .OTHERS {
            mapManager?.removePois()
        }
    }
}

extension Reactive where Base: MapViewController {
    var bindToSearchPlaces: Binder<[SearchPlace]> {
        return Binder<[SearchPlace]>(self.base) { viewController, searchPlaces in
            guard viewController.mapManager?.isEngineActive == true else { return }
            let storeType = viewController.mapViewModel.selectStoreTypeRelay.value
            viewController.mapManager?.createPois(
                searchPlaces: searchPlaces,
                storeType: storeType,
                scale: 0.3,
                upScale: 0.5
            )
        }
    }
    
    var bindToBottomSheetState: Binder<BottomSheetState> {
        return Binder<BottomSheetState>(self.base) { viewController, state in
            UIView.animate(withDuration: 0.3, delay: 0.0,options: .curveEaseInOut) {
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
    
    var bindToLocationPermission: Binder<Bool> {
        return Binder<Bool>(self.base) { viewController, isGranted in
            MOALogger.logd()
            viewController.dimView.isHidden = isGranted
            viewController.permissionGuideToastView.isHidden = isGranted
            
            // 설정을 들어가지 않고 위치 권한 팝업에서 허용 시에 refresh
            if isGranted && viewController.mapManager?.isEngineActive == true {
                viewController.mapViewModel.refresh()
            }
            viewController.mapManager?.updateLocation()
        }
    }
}

extension MapViewController {
    @objc func openSetting() {
        MOALogger.logd()
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
        
    @objc func didBecomeActive() {
        MOALogger.logd()
        isActive = true
        
        // 엔진이 활성화 되지 않는 상태: 최초 팝업, 딥링크로 이동, 권한 설정으로 이동
        // 포그라운드 올라올 때 엔진 활성화 시키기
        if mapManager?.isEngineActive == false {
            mapManager?.activateEngine()
            
            // 선택된 마커가 있는 경우에는 마커 갱신을 하지 않기 위해 refresh 막기, refresh는 권한이 설정에서 부여되면 현재 위치 기반 마커를 표시해주기 위해
            if mapViewModel.selectedPoiID == nil && mapViewModel.selectedLayerID == nil {
                mapViewModel.refresh()
            }
        }
    }
    
    @objc func willResignActive() {
        MOALogger.logd()
        isActive = false
    }
}
