//
//  MapView+MKMapDelegate.swift
//  MapExample
//
//  Created by Abhishek on 19/07/17.
//  Copyright © 2017 NGA. All rights reserved.
//

import MapKit

//MARK: - MKMap View Delegates
extension AppleGoogleMapView: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var reuseId = ""
        if let markannotation = annotation as? MapAnnotation {
            reuseId = "MarkPin"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            {
                view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: markannotation, reuseIdentifier: reuseId)
            }
            if let markView = markannotation.markView {
                view = markView
            } else {
                view.image = markannotation.icon
            }
            view.annotation = annotation
            view.centerOffset = markannotation.groundAnchor
            view.canShowCallout = markannotation.canShowCallout
            return view
        }
        else {
            return nil
        }
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MapAnnotation {
            selectedAnnotation = annotation
            delegate?.mapView?(self, didSelect: annotation)
        }
    }
    
    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let annotation = view.annotation as? MapAnnotation {
            delegate?.mapView?(self, didDeselect: annotation)
            selectedAnnotation = nil
        }
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        centerOfMap = mkMapView?.region.center
        //redrawAnnotations()
        guard let mkMapView = mkMapView, let trackUserBtn = trackUserBtn else {
            return
        }
        if(mkMapView.userTrackingMode == MKUserTrackingMode.none){
            trackUserBtn.setImage(UIImage(named: "TrackUser"), for: .normal)
        }
        delegate?.mapRegionChanged?(self)
        
    }
    
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.black.withAlphaComponent(0.7)
            lineView.lineWidth = 2
            return lineView
        } else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = UIColor.black.withAlphaComponent(0.7)
            polygonView.lineWidth = 2
            
            let visibleMapRect = mapView.visibleMapRect
            let visibleAnnotation = mapView.annotations(in: visibleMapRect)
            var containPin = false
            for annot in visibleAnnotation {
                if let annotCoordinate = annot as? MKAnnotation {
                    let mapPoint = MKMapPointForCoordinate(annotCoordinate.coordinate)
                    let polygonViewPoint = polygonView.point(for: mapPoint)
                    containPin = polygonView.path.contains(polygonViewPoint)
                    if containPin {
                        polygonView.fillColor = UIColor.gray.withAlphaComponent(0.5)
                        break
                    }
                }
            }
            if containPin == true { print("Polygon containing pin") }
            return polygonView
        }
        return MKOverlayPathRenderer()
    }
    
}
