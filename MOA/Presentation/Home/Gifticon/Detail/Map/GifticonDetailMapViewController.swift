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

final class GifticonDetailMapViewController: BaseViewController, MapControllerDelegate {
    
    let kmContainer: KMViewContainer = {
        let width = Int(UIScreen.main.bounds.width)
        let height = Int(UIScreen.main.bounds.height)
        let container = KMViewContainer(frame: CGRect(x: 0, y: 0, width: width, height: height))
        return container
    }()
    
    let confirmButton: CommonButton = {
        let button = CommonButton(title: GIFTICON_DETAIL_MAP_CONFIRM_BUTTON_TITLE)
        return button
    }()
    
    var kmController: KMController? = nil
    private var kmAuth: Bool = false
    private let searchPlaces: [SearchPlace]
    
    init(searchPlaces: [SearchPlace]) {
        self.searchPlaces = searchPlaces
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        setupMap()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MOALogger.logd()
        
        if kmController?.isEngineActive == false {
            kmController?.activateEngine()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        kmAuth = false
        kmController?.pauseEngine()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        kmController?.resetEngine()
        super.viewDidDisappear(animated)
    }
    
    private func setupLayout() {
        setupTopBarWithBackButton(title: MAP_MENU_TITLE)
        
        view.addSubview(kmContainer)
        view.addSubview(confirmButton)
        
        kmContainer.snp.makeConstraints {
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
    
    private func setupMap() {
        kmController = KMController(viewContainer: kmContainer)
        kmController?.delegate = self
        kmController?.prepareEngine()
    }
    
    func bind() {
        confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                navigationController?.popViewController(animated: false)
            }).disposed(by: disposeBag)
    }
    
    func addViews() {
        MOALogger.logd()
        let longitude = LocationManager.shared.longitude ?? LocationManager.defaultLongitude
        let latitude = LocationManager.shared.latitude ?? LocationManager.defaultLatitude
        let defaultPosition = MapPoint(longitude: longitude, latitude: latitude)
        let mapViewInfo = MapviewInfo(viewName: "mapview", defaultPosition: defaultPosition, defaultLevel: 15)
        kmController?.addView(mapViewInfo)
    }
    
    func authenticationSucceeded() {
        MOALogger.logd()
        kmAuth = true
    }
    
    func authenticationFailed(_ errorCode: Int, desc: String) {
        MOALogger.loge(desc)
        kmAuth = false
    }
    
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        MOALogger.logd()
        createLabelLayer()
        createPoiStyle()
        createPois(searchPlaces: searchPlaces)
    }

    func createLabelLayer() {
        MOALogger.logd()
        if let view = kmController?.getView("mapview") as? KakaoMap {
            let manager = view.getLabelManager()
            let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 0)
            let _ = manager.addLabelLayer(option: layerOption)
        }
    }
    
    func createPoiStyle() {
        MOALogger.logd()
        if let view = kmController?.getView("mapview") as? KakaoMap {
            let manager = view.getLabelManager()
            let poiImage = UIImage(named: "CafePoiIcon")?.resize(scale: 0.3)
            let iconStyle = PoiIconStyle(symbol: poiImage, anchorPoint: CGPoint(x: 0.5, y: 1.0), badges: nil)
            let poiStyle = PoiStyle(styleID: "PerLevelStyle", styles: [
                PerLevelPoiStyle(iconStyle: iconStyle, level: 5)
            ])
            manager.addPoiStyle(poiStyle)
        }
    }
    
    func createPois(searchPlaces: [SearchPlace]) {
        MOALogger.logd("\(searchPlaces.count)")
        if let view = kmController?.getView("mapview") as? KakaoMap {
            let manager = view.getLabelManager()
            let layer = manager.getLabelLayer(layerID: "PoiLayer")
            let poiOption = PoiOptions(styleID: "PerLevelStyle")
            poiOption.rank = 0
            
            for searchPlace in searchPlaces {
                guard let longitude = Double(searchPlace.x) else { return }
                guard let latitude = Double(searchPlace.y) else { return }
                let mapPosition = MapPoint(longitude: longitude, latitude: latitude)
                let poi = layer?.addPoi(option: poiOption, at: mapPosition)
                poi?.show()
            }
        }
    }
}

