//
//  LocationManager.swift
//  MOA
//
//  Created by 오원석 on 12/29/24.
//

import UIKit
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MOALogger.logd("\(manager.authorizationStatus)")
        
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isGranted = true
            manager.requestWhenInUseAuthorization()
        default:
            isGranted = false
        }
    }
}
