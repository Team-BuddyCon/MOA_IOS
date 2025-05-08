//
//  GifticonDetailMapViewController.swift
//  MOA
//
//  Created by 오원석 on 12/29/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import KakaoMapsSDK

protocol GifticonDetailMapViewControllerDelegate: AnyObject {
    func navigateBack()
}

final class GifticonDetailMapViewController: BaseViewController {

    let confirmButton: CommonButton = {
        let button = CommonButton(title: GIFTICON_DETAIL_MAP_CONFIRM_BUTTON_TITLE)
        return button
    }()
    
    var mapManager: KakaoMapManager?
    let searchPlaces: [SearchPlace]
    let storeType: StoreType
    
    weak var delegate: GifticonDetailMapViewControllerDelegate?
    
    init(
        searchPlaces: [SearchPlace],
        storeType: StoreType
    ) {
        self.searchPlaces = searchPlaces
        self.storeType = storeType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupMap()
        setupLayout()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapManager?.addObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MOALogger.logd()
        
        if mapManager?.isEngineActive == false {
            mapManager?.activateEngine()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapManager?.kmAuth = false
        mapManager?.removeObserver()
        mapManager?.pauseEngine()
        mapManager?.resetEngine()
        super.viewWillDisappear(animated)
        MOALogger.logd()
    }
}

private extension GifticonDetailMapViewController {
    func setupLayout() {
        setupTopBarWithBackButton(title: MAP_MENU_TITLE)
        
        guard let kmContainer = mapManager?.container else { return }
        
        view.addSubview(kmContainer)
        view.addSubview(confirmButton)
        
        kmContainer.snp.remakeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        confirmButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
            $0.height.equalTo(54)
        }
    }
    
    func setupMap() {
        let width = Int(UIScreen.main.bounds.width)
        let height = Int(UIScreen.main.bounds.height)
        mapManager = KakaoMapManager(rect: CGRect(x: 0, y: 0, width: width, height: height))
        mapManager?.delegate = self
        mapManager?.prepareEngine()
    }
    
    func bind() {
        confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.delegate?.navigateBack()
            }).disposed(by: disposeBag)
    }
    
}

extension GifticonDetailMapViewController: MapControllerDelegate {
    func addViews() {
        MOALogger.logd()
        let longitude = LocationManager.shared.longitude ?? LocationManager.defaultLongitude
        let latitude = LocationManager.shared.latitude ?? LocationManager.defaultLatitude
        let defaultPosition = MapPoint(longitude: longitude, latitude: latitude)
        let mapViewInfo = MapviewInfo(viewName: KAKAO_MAP_DEFAULT_VIEW, defaultPosition: defaultPosition, defaultLevel: KAKAO_MAP_LEVEL_17)
        mapManager?.addView(mapViewInfo)
    }
    
    func authenticationSucceeded() {
        MOALogger.logd()
        mapManager?.kmAuth = true
    }
    
    func authenticationFailed(_ errorCode: Int, desc: String) {
        MOALogger.loge(desc)
        mapManager?.kmAuth = false
    }
    
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        MOALogger.logd()
        if searchPlaces.count > 0 {
            mapManager?.createPois(
                searchPlaces: searchPlaces,
                storeType: storeType,
                scale: 0.3,
                upScale: 0.3
            )
        }
    }
}
