//
//  LocationManager.swift
//  MOA
//
//  Created by 오원석 on 12/29/24.
//

import UIKit
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    static let defaultLatitude: Double = 37.402001
    static let defaultLongitude: Double = 127.108678
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    
    var isGranted: Bool = false
    var latitude: Double? = nil
    var longitude: Double? = nil
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationAuthorization() {
        MOALogger.logd()
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        MOALogger.logd()
        if isGranted {
            manager.startUpdatingLocation()
        } else {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            MOALogger.logd("\(location.coordinate)")
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        MOALogger.loge("\(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MOALogger.logd("\(manager.authorizationStatus)")
        
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isGranted = true
            manager.startUpdatingLocation()
        default:
            isGranted = false
        }
    }
}
