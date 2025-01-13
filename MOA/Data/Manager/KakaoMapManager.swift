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
let LAYER_ID = "PoiLayer"
let STYLE_ID = "PerLevelStyle"

public class KakaoMapManager: NSObject {
    static weak var instance: KakaoMapManager? = nil
    private static var rect: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    var kmAuth: Bool = false
    var controller: KMController?
    var container: KMViewContainer?
    var kakaoMap: KakaoMap?
    
    var isEngineActive: Bool { controller?.isEngineActive ?? false }
    
    public init(rect: CGRect) {
        MOALogger.logd()
        KakaoMapManager.rect = rect
        self.container = KMViewContainer(frame: rect)
        self.controller = KMController(viewContainer: container!)
        super.init()
        
        controller?.delegate = self
        LocationManager.shared.startUpdatingLocation()
    }
    
    deinit {
        MOALogger.logd()
        controller?.pauseEngine()
        controller?.resetEngine()
    }
    
    public static func getInstance(rect: CGRect) -> KakaoMapManager {
        if let instance = instance, KakaoMapManager.rect == rect {
            return instance
        } else {
            let ref = KakaoMapManager(rect: rect)
            instance = ref
            return ref;
        }
    }
    
    public func prepareEngine() {
        controller?.prepareEngine()
    }
    
    public func activeEngine() {
        controller?.activateEngine()
    }
    
    public func pauseEngine() {
        controller?.pauseEngine()
    }
    
    public func resetEngine() {
        controller?.resetEngine()
    }
    
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
    
    // Poi 생성을 위한 LabelLayer(Poi, WaveText를 담을 수 있는 Layer) 생성
    public func createLabelLayer() {
        MOALogger.logd()
        if let view = controller?.getView(KAKAO_MAP_DEFAULT_VIEW) as? KakaoMap {
            let manager = view.getLabelManager()
            let layerOption = LabelLayerOptions(
                layerID: LAYER_ID,
                competitionType: .none,
                competitionUnit: .symbolFirst,
                orderType: .rank,
                zOrder: 0
            )
            let _ = manager.addLabelLayer(option: layerOption)
        }
    }
    
    // Poi 레벨별로 Style 지정
    func createPoiStyle(scale: CGFloat) {
        MOALogger.logd()
        if let view = controller?.getView(KAKAO_MAP_DEFAULT_VIEW) as? KakaoMap {
            let manager = view.getLabelManager()
            let poiImage = UIImage(named: CAFE_POI_ICON)?.resize(scale: scale)
            let iconStyle = PoiIconStyle(
                symbol: poiImage,
                anchorPoint: CGPoint(x: 0.5, y: 1.0),
                badges: nil
            )
            let poiStyle = PoiStyle(
                styleID: STYLE_ID,
                styles: [
                    PerLevelPoiStyle(iconStyle: iconStyle, level: 10)
                ]
            )
            manager.addPoiStyle(poiStyle)
        }
    }
    
    // Poi 생성
    func createPois(searchPlaces: [SearchPlace]) {
        MOALogger.logd()
        if let view = controller?.getView(KAKAO_MAP_DEFAULT_VIEW) as? KakaoMap {
            let manager = view.getLabelManager()
            let layer = manager.getLabelLayer(layerID: LAYER_ID)
            let poiOption = PoiOptions(styleID: STYLE_ID)
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

extension KakaoMapManager {
    @objc func didBecomeActive() {
        MOALogger.logd()
        controller?.activateEngine()
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
