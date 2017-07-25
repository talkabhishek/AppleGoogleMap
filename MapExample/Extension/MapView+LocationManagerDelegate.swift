//
//  MapView+LocationManagerDelegate.swift
//  MapExample
//
//  Created by Abhishek on 19/07/17.
//  Copyright © 2017 NGA. All rights reserved.
//

import UIKit
import CoreLocation

// MARK: - CLLocationManagerDelegate
extension AppleGoogleMapView: CLLocationManagerDelegate {
    
    func requestLocationAuthorization() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted {
            let locationAlert = UIAlertController(title: NSLocalizedString("Location Access", comment: "Location Access Title") , message: NSLocalizedString("Allow App to access your location?", comment: "Location Access Description"), preferredStyle: UIAlertControllerStyle.alert)
            locationAlert.addAction(UIAlertAction(title: NSLocalizedString("Don't Allow", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
            }))
            locationAlert.addAction(UIAlertAction(title: NSLocalizedString("Allow", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: { (comp) in
                    })
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            }))
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.window?.rootViewController?.present(locationAlert, animated: true, completion: nil)
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            locationManager.stopUpdatingLocation()
            delegate?.mapView?(self, LocationManager: manager, didUpdateLocations: locations)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
}
