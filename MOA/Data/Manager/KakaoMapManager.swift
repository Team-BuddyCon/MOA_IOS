//
//  KakaoMapManager.swift
//  MOA
//
//  Created by 오원석 on 1/1/25.
//

import UIKit
import KakaoMapsSDK

let KAKAO_MAP_DEFAULT_VIEW = "mapview"
let KAKAO_MAP_DEFAULT_LEVEL = 15
let LAYER_ID = "PoiLayer"
let STYLE_ID = "PerLevelStyle"

public class KakaoMapManager {
    static weak var instance: KakaoMapManager? = nil
    var controller: KMController?
    var container: KMViewContainer?
    var kakaoMap: KakaoMap?

    public init(rect: CGRect) {
        MOALogger.logd()
        container = KMViewContainer(frame: rect)
        controller = KMController(viewContainer: container!)
    }
    
    deinit {
        MOALogger.logd()
        controller?.pauseEngine()
        controller?.resetEngine()
    }
    
    public static func getInstance(rect: CGRect) -> KakaoMapManager {
        if let instance = instance {
            return instance
        } else {
            let ref = KakaoMapManager(rect: rect)
            instance = ref
            return ref;
        }
    }
    
    public func addObserver(_ observer: Any) {
        NotificationCenter.default.addObserver(
            observer,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            observer,
            selector: #selector(willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    public func removeObserver(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer)
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
