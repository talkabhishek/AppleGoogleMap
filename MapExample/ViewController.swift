//
//  ViewController.swift
//  MapExample
//
//  Created by Abhishek on 18/07/17.
//  Copyright © 2017 NGA. All rights reserved.
//

import UIKit
import MapKit

let googleMapAPIkey  = "AIzaSyDVZ5N3lR5xH0RQYn_YC5h-cKIvkDV65Ms"

class ViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    var appleMapView: AppleGoogleMapView?
    var googleMapView: AppleGoogleMapView?
    let dataProvider = GoogleDataProvider()
    
    var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        appleMapView = AppleGoogleMapView(type: MapType.apple)
        self.view.addSubview(appleMapView!)
        appleMapView?.isDrawingEnable = true
        appleMapView?.requestLocationAuthorization()
  
        googleMapView = AppleGoogleMapView(type: .google, googleAPIkey: googleMapAPIkey)
        //googleMapView?.googleMapAPIkey  = googleMapAPIkey
        googleMapView?.isDrawingEnable = true
        googleMapView?.requestLocationAuthorization()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    @IBAction func refreshAction(_ sender: Any) {
        appleMapView?.removeMarkers(self)
        googleMapView?.removeMarkers(self)
        appleMapView?.lock()
        googleMapView?.lock()
        if appleMapView?.centerOfMap != nil {
            fetchNearbyPlaces(coordinate: appleMapView!.centerOfMap!, completion: { (pins) in
                self.appleMapView?.addMarkers(self, mapPins: pins)
                self.googleMapView?.addMarkers(self, mapPins: pins)
                self.appleMapView?.unlock()
                self.googleMapView?.unlock()
            })
        }
       
    }
    
    @IBAction func segmentSelectorClicked(_ sender: Any) {
        guard let segment = sender as? UISegmentedControl else {
            return
        }
        
        if segment.selectedSegmentIndex == 0 {
            guard let mapView = appleMapView else {
                return
            }
            self.view.addSubview(mapView)
            UIView.transition(from: googleMapView!, to: mapView, duration: 1.0, options: .transitionFlipFromLeft, completion: { (status) in
            })
        } else {
            guard let mapView = googleMapView else {
                return
            }
            self.view.addSubview(mapView)
            UIView.transition(from: appleMapView!, to: mapView, duration: 1.0, options: .transitionFlipFromRight, completion: { (status) in
            })
        }

    }
    
    
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D, completion:@escaping (([MapAnnotation]) -> Void) ) {
        let searchRadius: Double = 1000
        
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
            var mapPins = [MapAnnotation]()
            for place: GooglePlace in places {
                let mapPin = MapAnnotation(coordinate: place.coordinate, title: place.name)
                mapPin.icon = UIImage(named: "\(place.placeType)_pin")
                mapPins.append(mapPin)
            }
            completion(mapPins)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypesSegue" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! TypesTableViewController
            controller.selectedTypes = searchedTypes
            controller.delegate = self
        }
    }

}

// MARK: - TypesTableViewControllerDelegate
extension ViewController: TypesTableViewControllerDelegate {
    func typesController(_ controller: TypesTableViewController, didSelectTypes types: [String]) {
        searchedTypes = controller.selectedTypes.sorted()
        refreshAction(self)
        dismiss(animated: true, completion: nil)
    }
}
