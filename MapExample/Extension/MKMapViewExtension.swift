//
//  MKMapViewExtension.swift
//  MapExample
//
//  Created by Abhishek on 19/07/17.
//  Copyright © 2017 NGA. All rights reserved.
//

import MapKit

extension MKMapView {
    func fitMapViewToAnnotaionList(_ allAnnotations: [MKAnnotation]) -> Void {
        let minWidthInMapPoints: Double = 10000.0
        let mapEdgePadding = UIEdgeInsets(top: 80, left: 20, bottom: 80, right: 20)
        var zoomRect:MKMapRect = MKMapRectNull
        
        for index in 0..<allAnnotations.count {
            let annotation = allAnnotations[index]
            if(annotation.coordinate.latitude == 0.0 && annotation.coordinate.longitude == 0.0){
                continue
            }
            let aPoint:MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let rect:MKMapRect = MKMapRectMake(aPoint.x - minWidthInMapPoints/2, aPoint.y - minWidthInMapPoints/2, minWidthInMapPoints, minWidthInMapPoints)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        self.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: false)
    }
    
    func getMapWidthInMeters()->Double{
        let deltaLongitude: CLLocationDegrees = self.region.span.longitudeDelta
        let latitudeCircumference: Double = Double(40075160) * cos(self.region.center.latitude * M_PI / 180)
        return (deltaLongitude * latitudeCircumference / Double(360))
        
    }
    
}
