//
//  GooglePlace.swift
//  MapExample
//
//  Created by Abhishek on 19/07/17.
//  Copyright © 2017 NGA. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class GooglePlace {
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let placeType: String
    var photoReference: String?
    var photo: UIImage?
    
    init(dictionary:[String : Any], acceptedTypes: [String])
    {
        name = dictionary["name"] as? String ?? ""
        address = dictionary["vicinity"] as? String ?? ""
        
        if let geometry = dictionary["geometry"] as? [String:Any], let location = geometry["location"] as? [String: Any], let lat = location["lat"] as? Double, let lng = location["lng"] as? Double {
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        } else {
            coordinate = CLLocationCoordinate2D()
        }
        
        if let photos = dictionary["photos"] as? [Any], let firstPhoto = photos.first as? [String: Any], let photo_reference = firstPhoto["photo_reference"] as? String {
            photoReference = photo_reference
        }
        
        var foundType = "restaurant"
        let possibleTypes = acceptedTypes.count > 0 ? acceptedTypes : ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
        guard let types = dictionary["types"] as? [String] else { placeType = foundType; return }
        for type in types {
            if possibleTypes.contains(type) {
                foundType = type
                break
            }
        }
        placeType = foundType
    }
}
