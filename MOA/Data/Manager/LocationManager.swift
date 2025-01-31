//
//  LocationManager.swift
//  MOA
//
//  Created by 오원석 on 12/29/24.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import RxRelay

final class LocationManager: NSObject, CLLocationManagerDelegate {
    static let defaultLatitude: Double = 37.402001
    static let defaultLongitude: Double = 127.108678
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    
    var isGranted = BehaviorRelay(value: false)
    var latitude: Double? = nil
    var longitude: Double? = nil
    var address: String? = nil
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startUpdatingLocation() {
        MOALogger.logd()
        if isGranted.value {
            manager.startUpdatingLocation()
        } else {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            MOALogger.logd("\(location.coordinate)")
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            manager.stopUpdatingLocation()
            
            
            // didUpdatLocation이 연속 호출됨에 따라 isGranted 이벤트 방출되어서 방지
            if isGranted.value == false {
                isGranted.accept(true)
            }
            
            let geocoder = CLGeocoder.init()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let placemark = placemarks?.first {
                    self.address = "\(placemark.administrativeArea ?? "") \(placemark.locality ?? "") \(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? "")"
                }
            }
        } else {
            isGranted.accept(false)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MOALogger.logd("\(manager.authorizationStatus)")
        
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            isGranted.accept(false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        MOALogger.loge("\(error.localizedDescription)")
        latitude = nil
        longitude = nil
        address = nil
    }
}
