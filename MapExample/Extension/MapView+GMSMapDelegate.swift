//
//  MapView+GMSMapDelegate.swift
//  MapExample
//
//  Created by Abhishek on 19/07/17.
//  Copyright © 2017 NGA. All rights reserved.
//

import GoogleMaps

//MARK: - GMSMap View Delegates
extension AppleGoogleMapView: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        centerOfMap = mapView.camera.target
        //reverseGeocodeCoordinate(coordinate: position.target)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(AppleGoogleMapView.callRegionChangeDelegate), with: nil, afterDelay: 0.5)
    }
    
    func callRegionChangeDelegate() {
        delegate?.mapRegionChanged?(self)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let annotation = marker as? MapAnnotation {
            selectedAnnotation = annotation
            delegate?.mapView?(self, didSelect: annotation)
        }
        if let markerPin = marker as? MapAnnotation {
            return !markerPin.canShowCallout
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        if let annotation = selectedAnnotation {
            delegate?.mapView?(self, didDeselect: annotation)
            selectedAnnotation = nil
        }
    }

    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        return delegate?.mapView?(mapView, markerInfoContents: marker)
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.selectedMarker = nil
        return false
    }
}
