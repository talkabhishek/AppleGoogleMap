//
//  MapAnnotation.swift
//  MapExample
//
//  Created by Abhishek on 20/07/17.
//  Copyright © 2017 NGA. All rights reserved.
//

import Foundation
import GoogleMaps
import MapKit

class MapAnnotation: GMSMarker, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var subtitle: String?
    var markView: MKAnnotationView? //for marker (view will assign iconView)
    var canShowCallout: Bool = true
    
    //var icon: UIImage?
    //var iconView: UIView?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String? = nil, mark: UIImage? = nil, markView: MKAnnotationView? = nil) {
        super.init()
        
        //Required variable
        self.position = coordinate
        self.coordinate = coordinate
        self.title = title
        
        //Obtional variable
        self.subtitle = subtitle
        self.icon = mark
        self.markView = markView
        
        //Default variable
        self.appearAnimation = .pop
        self.groundAnchor = CGPoint(x: 0.5, y: 1)
    }
    
}
