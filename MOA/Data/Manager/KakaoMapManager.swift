//
//  KakaoMapManager.swift
//  MOA
//
//  Created by 오원석 on 1/1/25.
//

import UIKit
import KakaoMapsSDK

let KAKAO_MAP_DEFAULT_VIEW = "mapview"
let KAKAO_MAP_LEVEL_15 = 15
let KAKAO_MAP_LEVEL_17 = 17

enum LayerID: String {
    case Cafe = "Cafe_LayerID"
    case FastFood = "FastFood_LayerID"
    case Store = "Store_LayerID"
}

enum StyleID: String {
    case Cafe = "Cafe_StyleID"
    case FastFood = "FastFood_StyleID"
    case Store = "Store_StyleID"
    case CafeUp = "CafeUp_StyleID"
    case FastFoodUp = "FastFoodUp_StyleID"
    case StoreUp = "StoreUp_StyleID"
    
    var rank: Int {
        switch self {
        case .Cafe: return 0
        case .FastFood: return 1
        case .Store: return 2
        case .CafeUp: return 3
        case .FastFoodUp: return 4
        case .StoreUp: return 5
        }
    }
    
    var selectStyleID: StyleID {
        switch self {
        case .Cafe: return .CafeUp
        case .FastFood: return .FastFoodUp
        case .Store: return .StoreUp
        case .CafeUp: return .Cafe
        case .FastFoodUp: return .FastFood
        case .StoreUp: return .Store
        }
    }
    
    static func styleID(rank: Int?) -> StyleID {
        switch rank {
        case StyleID.Cafe.rank: return .Cafe
        case StyleID.FastFood.rank: return .FastFood
        case StyleID.Store.rank: return .Store
        case StyleID.CafeUp.rank: return .CafeUp
        case StyleID.FastFoodUp.rank: return .FastFoodUp
        case StyleID.StoreUp.rank: return .StoreUp
        default: return .Store
        }
    }
    
    func isUp() -> Bool {
        switch self {
        case .CafeUp, .FastFoodUp, .StoreUp: return true
        default: return false
        }
    }
}

public class KakaoMapManager: NSObject {
    
    var kmAuth: Bool = false
    var controller: KMController?
    var container: KMViewContainer?
    var kakaoMap: KakaoMap?

    var isEngineActive: Bool { controller?.isEngineActive ?? false }
    var eventDelegate: KakaoMapEventDelegate?
    var delegate: MapControllerDelegate? {
        didSet {
            controller?.delegate = delegate
        }
    }
    
    public init(rect: CGRect) {
        MOALogger.logd()
        super.init()
        self.container = KMViewContainer(frame: rect)
        self.controller = KMController(viewContainer: container!)
        LocationManager.shared.startUpdatingLocation()
    }
    
    deinit {
        MOALogger.logd()
        controller?.pauseEngine()
        controller?.resetEngine()
    }
    
    public func prepareEngine() {
        MOALogger.logd()
        controller?.prepareEngine()
    }
    
    public func activateEngine() {
        MOALogger.logd()
        controller?.activateEngine()
    }
    
    public func pauseEngine() {
        MOALogger.logd()
        controller?.pauseEngine()
    }
    
    public func resetEngine() {
        MOALogger.logd()
        controller?.resetEngine()
    }
    
    // KakaoMapManager에서 정의한 mapViewInfo가 아닌 커스텀 mapViewInfo 추가 시 사용
    public func addView(_ mapViewInfo: MapviewInfo) {
        MOALogger.logd()
        controller?.addView(mapViewInfo)
    }
    
    public func updateLocation() {
        let longitude = LocationManager.shared.longitude ?? LocationManager.defaultLongitude
        let latitude = LocationManager.shared.latitude ?? LocationManager.defaultLatitude
        
        MOALogger.logd("\(longitude), \(latitude)")
        if let view = controller?.getView(KAKAO_MAP_DEFAULT_VIEW) as? KakaoMap {
            view.moveCamera(
                CameraUpdate.make(
                    target: MapPoint(longitude: longitude, latitude: latitude),
                    zoomLevel: KAKAO_MAP_LEVEL_15,
                    rotation: 0,
                    tilt: 0.0,
                    mapView: view
                )
            )
        }
    }
}

extension KakaoMapManager {
    // Poi 생성을 위한 LabelLayer (Poi, WaveText를 담을 수 있는 Layer) 생성
    public func createLabelLayer() {
        MOALogger.logd()
        if let view = controller?.getView(KAKAO_MAP_DEFAULT_VIEW) as? KakaoMap {
            let manager = view.getLabelManager()
            let cafeLayerOption = LabelLayerOptions(
                layerID: LayerID.Cafe.rawValue,
                competitionType: .none,
                competitionUnit: .symbolFirst,
                orderType: .rank,
                zOrder: 5000
            )
            
            let fastFoodLayerOption = LabelLayerOptions(
                layerID: LayerID.FastFood.rawValue,
                competitionType: .none,
                competitionUnit: .symbolFirst,
                orderType: .rank,
                zOrder: 5000
            )
            
            let storeLayerOption = LabelLayerOptions(
                layerID: LayerID.Store.rawValue,
                competitionType: .none,
                competitionUnit: .symbolFirst,
                orderType: .rank,
                zOrder: 5000
            )
            
            let _ = manager.addLabelLayer(option: cafeLayerOption)
            let _ = manager.addLabelLayer(option: fastFoodLayerOption)
            let _ = manager.addLabelLayer(option: storeLayerOption)
        }
    }
    
    // 카페 Poi Style
    private func getCafePoiIconStyle(
        scale: CGFloat,
        styleID: String
    ) -> PoiStyle {
        let poiImage = UIImage(named: CAFE_POI_ICON)?.resize(scale: scale)
        let iconStyle = PoiIconStyle(
            symbol: poiImage,
            anchorPoint: CGPoint(x: 0.5, y: 1.0),
            badges: nil
        )
        
        return PoiStyle(
            styleID: styleID,
            styles: [
                PerLevelPoiStyle(iconStyle: iconStyle, level: 10)
            ]
        )
    }
    
    // 햄버거 Poi Style
    private func getFastFoodPoiIconStyle(
        scale: CGFloat,
        styleID: String
    ) -> PoiStyle {
        let poiImage = UIImage(named: FAST_FOOD_POI_ICON)?.resize(scale: scale)
        let iconStyle = PoiIconStyle(
            symbol: poiImage,
            anchorPoint: CGPoint(x: 0.5, y: 1.0),
            badges: nil
        )
        return PoiStyle(
            styleID: styleID,
            styles: [
                PerLevelPoiStyle(iconStyle: iconStyle, level: 10)
            ]
        )
    }
    
    // 편의점 Poi Style
    private func getStoreIconStyle(
        scale: CGFloat,
        styleID: String
    ) -> PoiStyle {
        let poiImage = UIImage(named: STORE_POI_ICON)?.resize(scale: scale)
        let iconStyle = PoiIconStyle(
            symbol: poiImage,
            anchorPoint: CGPoint(x: 0.5, y: 1.0),
            badges: nil
        )
        
        return PoiStyle(
            styleID: styleID,
            styles: [
                PerLevelPoiStyle(iconStyle: iconStyle, level: 10)
            ]
        )
    }
    
    // Poi 레벨별로 Style 지정
    func createPoiStyle(
        scale: CGFloat,
        upScale: CGFloat
    ) {
        MOALogger.logd()
        if let view = controller?.getView(KAKAO_MAP_DEFAULT_VIEW) as? KakaoMap {
            let manager = view.getLabelManager()
            let cafePoiStyle = getCafePoiIconStyle(scale: scale, styleID: StyleID.Cafe.rawValue)
            let cafeUpPoiStyle = getCafePoiIconStyle(scale: upScale, styleID: StyleID.CafeUp.rawValue)
            let fastFoodPoiStyle = getFastFoodPoiIconStyle(scale: scale, styleID: StyleID.FastFood.rawValue)
            let fastFoodUpPoiStyle = getFastFoodPoiIconStyle(scale: upScale, styleID: StyleID.FastFoodUp.rawValue)
            let storePoiStyle = getStoreIconStyle(scale: scale, styleID: StyleID.Store.rawValue)
            let storeUpPoiStyle = getStoreIconStyle(scale: upScale, styleID: StyleID.StoreUp.rawValue)
            
            manager.addPoiStyle(cafePoiStyle)
            manager.addPoiStyle(cafeUpPoiStyle)
            manager.addPoiStyle(fastFoodPoiStyle)
            manager.addPoiStyle(fastFoodUpPoiStyle)
            manager.addPoiStyle(storePoiStyle)
            manager.addPoiStyle(storeUpPoiStyle)
        }
    }
    
    // Poi 생성
    func createPois(
        searchPlaces: [SearchPlace],
        storeType: StoreType,
        scale: CGFloat,
        upScale: CGFloat,
        refresh: Bool = true
    ) {
        MOALogger.logd()
        if refresh { removePois() }
        createLabelLayer()
        createPoiStyle(scale: scale, upScale: upScale)
        
        if let view = controller?.getView(KAKAO_MAP_DEFAULT_VIEW) as? KakaoMap {
            kakaoMap = view
            view.eventDelegate = eventDelegate
            let manager = view.getLabelManager()
            let layer = manager.getLabelLayer(layerID: storeType.layerID.rawValue)
            let poiOption = PoiOptions(styleID: storeType.styleID.rawValue)
            poiOption.rank = storeType.styleID.rank
            poiOption.clickable = true
            
            for searchPlace in searchPlaces {
                guard let longitude = Double(searchPlace.x) else { return }
                guard let latitude = Double(searchPlace.y) else { return }
                let mapPosition = MapPoint(longitude: longitude, latitude: latitude)
                let poi = layer?.addPoi(option: poiOption, at: mapPosition)
                poi?.show()
            }
        }
    }
    
    func removePois() {
        MOALogger.logd()
        if let view = controller?.getView(KAKAO_MAP_DEFAULT_VIEW) as? KakaoMap {
            let manager = view.getLabelManager()
            manager.removeLabelLayer(layerID: LayerID.Cafe.rawValue)
            manager.removeLabelLayer(layerID: LayerID.FastFood.rawValue)
            manager.removeLabelLayer(layerID: LayerID.Store.rawValue)
        }
    }
}

extension KakaoMapManager {
    public func addObserver() {
        MOALogger.logd()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    public func removeObserver() {
        MOALogger.logd()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didBecomeActive() {
        MOALogger.logd()
        
        if isEngineActive == false {
            controller?.activateEngine()
        }
    }
    
    @objc func willResignActive() {
        MOALogger.logd()
        controller?.pauseEngine()
    }
}

extension KakaoMapManager: MapControllerDelegate {
    public func addViews() {
        MOALogger.logd()
        let longitude = LocationManager.shared.longitude ?? LocationManager.defaultLongitude
        let latitude = LocationManager.shared.latitude ?? LocationManager.defaultLatitude
        let defaultPosition = MapPoint(longitude: longitude, latitude: latitude)
        let mapViewInfo = MapviewInfo(viewName: KAKAO_MAP_DEFAULT_VIEW, defaultPosition: defaultPosition, defaultLevel: KAKAO_MAP_LEVEL_15)
        controller?.addView(mapViewInfo)
    }
    
    public func authenticationSucceeded() {
        MOALogger.logd()
        kmAuth = true
    }
    
    public func authenticationFailed(_ errorCode: Int, desc: String) {
        MOALogger.loge(desc)
        kmAuth = false
        // TODO 지도 로딩 몇번 실패 시 지도 안보여주기
    }
}
