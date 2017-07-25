//
//  GoogleDataProvider.swift
//  MapExample
//
//  Created by Abhishek on 19/07/17.
//  Copyright © 2017 NGA. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class GoogleDataProvider {
    var photoCache = [String:UIImage]()
    var placesTask: URLSessionDataTask?
    var session: URLSession {
        return URLSession.shared
    }
    
    func fetchPlacesNearCoordinate(_ coordinate: CLLocationCoordinate2D, radius: Double, types:[String], completion: @escaping (([GooglePlace]) -> Void)) -> ()
    {
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&key=\(googleMapAPIkey)"
        let typesString = types.count > 0 ? types.joined(separator: "|") : "food"
        urlString += "&types=\(typesString)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        if let task = placesTask, task.taskIdentifier > 0 && task.state == .running {
            task.cancel()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        placesTask = session.dataTask(with: URL(string: urlString)!, completionHandler: {data, response, error in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            var placesArray = [GooglePlace]()
            
            if let aData = data, let jsonObject = try? JSONSerialization.jsonObject(with: aData, options: .allowFragments), let json = jsonObject as? [String: Any], let results = json["results"] as? [[String : AnyObject]] {
                for rawPlace in results {
                    let place = GooglePlace(dictionary: rawPlace, acceptedTypes: types)
                    placesArray.append(place)
                }
            }
            DispatchQueue.main.async {
                completion(placesArray)
            }
        })
        placesTask?.resume()
    }
    
}

