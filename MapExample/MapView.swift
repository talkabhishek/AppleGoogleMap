//
//  MapView.swift
//  Map
//
//  Created by Abhishek on 18/07/17.
//  Copyright © 2015 New Gennerations Applications. All rights reserved.
//

import Foundation
import MapKit
import GoogleMaps

@objc protocol AppleGoogleMapDelegate: class {
    @objc optional func mapView(_ mapView: AppleGoogleMapView, LocationManager manager: CLLocationManager, didUpdateLocations locations: [CLLocation])

    @objc optional func mapView(_ mapView: AppleGoogleMapView, didSelect annotation: MapAnnotation)
    @objc optional func mapView(_ mapView: AppleGoogleMapView, didDeselect annotation: MapAnnotation)
    @objc optional func mapView(_ gmsMapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView?
    
    @objc optional func mapRegionChanged(_ mapView: AppleGoogleMapView)
}

class AppleGoogleMapView: UIView {
    
    
    var googleMapAPIkey: String? {
        didSet {
            if gmsMapView == nil {
                GMSServices.provideAPIKey(googleMapAPIkey!)
                gmsMapView = GMSMapView()
            }
        }
    }
    let locationManager: CLLocationManager = CLLocationManager()
    
    let clusteringManager = FBClusteringManager()
    var gmsMapView: GMSMapView? {
        didSet {
            if gmsMapView != nil {
                setupGoogleMap()
            }
        }
    }
    var mkMapView: MKMapView? {
        didSet {
            if mkMapView != nil {
                setupMapKit()
            }
        }
    }
    var trackUserBtn: UIButton?
    var isMKMapKit: Bool = true {
        didSet {
            if isMKMapKit {
                gmsMapView = nil
                mkMapView = MKMapView()
                setupMapKit()
            } else if gmsMapView == nil && googleMapAPIkey != nil {
                GMSServices.provideAPIKey(googleMapAPIkey!)
                mkMapView = nil
                gmsMapView = GMSMapView()
            }
        }
    }
    
    //Drawing Elements
    fileprivate var canvasView: UIImageView?
    fileprivate var drawBtn: UIButton?
    fileprivate var cancelDrawBtn: UIButton?
    
    var drawingCoordinates = [CLLocationCoordinate2D]()
    fileprivate var touchLocation: CGPoint = CGPoint()
    var centerOfMap: CLLocationCoordinate2D?
    var selectedAnnotation: MapAnnotation?
    
    var isDrawingEnable: Bool = false {
        didSet {
            setupDrawingView()
        }
    }

    //Variables to play with
    var clusterCellSize: Float = 3

    var delegate: AppleGoogleMapDelegate?

    override func awakeFromNib() { }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func layoutSubviews() { }

    deinit {
        // perform the deinitialization
        self.mkMapView?.delegate = nil
    }
    
    //MARK: - Setup Views
    func setup() {
        clusteringManager.delegate = self
        //requestLocationAuthorization()
    }
    
    func setupMapKit() {
        mkMapView?.delegate = self
        mkMapView?.mapType = MKMapType.standard
        centerOfMap = mkMapView?.region.center
        mkMapView?.showsUserLocation = true
        
        self.insertSubview(mkMapView!, at: 0)
        mkMapView?.translatesAutoresizingMaskIntoConstraints = false
        mkMapView?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        mkMapView?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        mkMapView?.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        mkMapView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        trackUserBtn = UIButton()
        trackUserBtn?.addTarget(self, action: #selector(onTrackUserAction(_:)), for: .touchUpInside)
        trackUserBtn?.setImage(UIImage(named: "TrackUser"), for: .normal)
        mkMapView?.setUserTrackingMode(MKUserTrackingMode.none, animated: true)
        self.addSubview(trackUserBtn!)
        
        trackUserBtn?.translatesAutoresizingMaskIntoConstraints = false
        trackUserBtn?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
        trackUserBtn?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50).isActive = true
        trackUserBtn?.widthAnchor.constraint(equalToConstant: 44).isActive = true
        trackUserBtn?.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    func setupGoogleMap() {
        gmsMapView?.delegate = self
        gmsMapView?.mapType = GMSMapViewType.normal
        centerOfMap = gmsMapView?.camera.target
        gmsMapView?.isMyLocationEnabled = true
        gmsMapView?.settings.myLocationButton = true
        gmsMapView?.padding = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        
        self.insertSubview(gmsMapView!, at: 0)
        gmsMapView?.translatesAutoresizingMaskIntoConstraints = false
        gmsMapView?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        gmsMapView?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        gmsMapView?.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        gmsMapView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
    
    func setupDrawingView() {
        if isDrawingEnable {
            canvasView = UIImageView()
            self.addSubview(canvasView!)
            canvasView?.translatesAutoresizingMaskIntoConstraints = false
            canvasView?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
            canvasView?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
            canvasView?.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            canvasView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            
            drawBtn = UIButton()
            drawBtn?.addTarget(self, action: #selector(onDrawAction(_:)), for: .touchUpInside)
            drawBtn?.setImage(#imageLiteral(resourceName: "Draw"), for: .normal)
            drawBtn?.setImage(#imageLiteral(resourceName: "DrawSelected"), for: .selected)
            self.addSubview(drawBtn!)
            drawBtn?.translatesAutoresizingMaskIntoConstraints = false
            drawBtn?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
            drawBtn?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50).isActive = true
            drawBtn?.widthAnchor.constraint(equalToConstant: 44).isActive = true
            drawBtn?.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            cancelDrawBtn = UIButton()
            cancelDrawBtn?.isHidden = true
            cancelDrawBtn?.addTarget(self, action: #selector(onCancelDrawAction(_:)), for: .touchUpInside)
            cancelDrawBtn?.setImage(#imageLiteral(resourceName: "RemoveDraw"), for: .normal)
            self.addSubview(cancelDrawBtn!)
            cancelDrawBtn?.translatesAutoresizingMaskIntoConstraints = false
            cancelDrawBtn?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
            cancelDrawBtn?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50).isActive = true
            cancelDrawBtn?.widthAnchor.constraint(equalToConstant: 44).isActive = true
            cancelDrawBtn?.heightAnchor.constraint(equalToConstant: 44).isActive = true
        } else {
            canvasView?.removeFromSuperview()
            canvasView = nil
            drawBtn?.removeFromSuperview()
            drawBtn = nil
            cancelDrawBtn?.removeFromSuperview()
            cancelDrawBtn = nil
        }
    }

    func onDrawAction(_ sender: Any) {
        guard let canvasView = canvasView, let drawBtn = drawBtn else {
            return
        }
        if (!drawBtn.isSelected) {

            drawBtn.isSelected = true
            drawingCoordinates.removeAll()
            
            if let mkMapView = mkMapView {
                mkMapView.removeOverlays(mkMapView.overlays)
            } else if let gmsMapView = gmsMapView {
                gmsMapView.clear()
            }
            canvasView.image = UIImage()
            canvasView.isHidden = false;
            canvasView.isUserInteractionEnabled = true
        } else {
            let numberOfPoints = drawingCoordinates.count
            if(numberOfPoints > 2){
                if isMKMapKit {
                    let myPolygon = MKPolygon(coordinates: &drawingCoordinates, count: numberOfPoints)
                    mkMapView?.add(myPolygon)
                } else {
                    let path = GMSMutablePath()
                    for coordinate in self.drawingCoordinates{
                        path.add(coordinate)
                    }
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeColor = UIColor.black.withAlphaComponent(0.7)
                    polyline.strokeWidth = 2.5
                    polyline.map = gmsMapView
                }
                self.drawBtn?.isHidden = true
                self.cancelDrawBtn?.isHidden = false;
            }
            drawBtn.isSelected = false
            canvasView.isHidden = true;
            canvasView.isUserInteractionEnabled = false
        }
    }

    func onCancelDrawAction(_ sender: Any) {
        if let mkMapView = mkMapView {
            mkMapView.removeOverlays(mkMapView.overlays)
        }
        cancelDrawBtn?.isHidden = true;
        drawBtn?.isHidden = false
    }

    func onTrackUserAction(_ sender: Any) {

        guard let mkMapView = mkMapView, let trackUserBtn = trackUserBtn else {
            return
        }
        switch(mkMapView.userTrackingMode){
        case MKUserTrackingMode.none:
            trackUserBtn.setImage(UIImage(named: "TrackUserSelected"), for: .normal)
            mkMapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
            break
        case MKUserTrackingMode.follow:
            trackUserBtn.setImage(UIImage(named: "TrackUserWithHeading"), for: .normal)
            mkMapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
            break
        case MKUserTrackingMode.followWithHeading:
            trackUserBtn.setImage(UIImage(named: "TrackUser"), for: .normal)
            mkMapView.setUserTrackingMode(MKUserTrackingMode.none, animated: true)
            break
        }
    }
    
    func refreshAction(_ sender: Any) {
        if centerOfMap != nil {
            //fetchNearbyPlaces(coordinate: centerOfMap!)
        }
    }
    
    func addMarkers(_ sender: Any, mapPins: [MapAnnotation]) {
        for pin in mapPins {
            if gmsMapView != nil {
                pin.map = gmsMapView
            }
            mkMapView?.addAnnotation(pin)
        }
    }
    
    func removeMarkers(_ sender: Any) {
        gmsMapView?.clear()
        if mkMapView != nil {
            mkMapView?.removeAnnotations(mkMapView!.annotations)
        }
    }
    
    func redrawAnnotations(){
        if let mkMapView = mkMapView {
            OperationQueue().addOperation({
                let mapBoundsWidth = Double(mkMapView.bounds.size.width)
                let mapRectWidth:Double = mkMapView.visibleMapRect.size.width
                let scale:Double = mapBoundsWidth / mapRectWidth
                let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(mkMapView.visibleMapRect, withZoomScale:scale)
                self.clusteringManager.displayAnnotations(annotationArray, onMapView:mkMapView)
            })
        }
    }

    func calculateMetreDistanceBetweenTwoCoords(_ sourceCoord:CLLocationCoordinate2D, destinationCoord:CLLocationCoordinate2D) -> Double{

        let srcLat: CLLocationDegrees = sourceCoord.latitude
        let srcLon: CLLocationDegrees = sourceCoord.longitude
        let srcLocation: CLLocation =  CLLocation(latitude: srcLat, longitude: srcLon)

        let destLat: CLLocationDegrees = destinationCoord.latitude
        let destLon: CLLocationDegrees = destinationCoord.longitude
        let destLocation: CLLocation =  CLLocation(latitude: destLat, longitude: destLon)

        let distanceMeters = srcLocation.distance(from: destLocation)
        return distanceMeters
    }
    
    func centerMapOnLocation(_ latitude: Double, longitude: Double, widthInMetres: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let regionWidth: CLLocationDistance = widthInMetres
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionWidth, regionWidth)
        centerOfMap = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        mkMapView?.setRegion(coordinateRegion, animated: false)
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            /*if let address = response?.firstResult() {
             let linesText = address.lines?.joined(separator: "\n")
             UIView.animate(withDuration: 0.25) {
             self.layoutIfNeeded()
             }
             }*/
        }
    }

}

//MARK: - Draw polygon on Map
extension AppleGoogleMapView {
    //MARK: - touch Canvasview delegates
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let drawBtn = drawBtn else {
            return
        }
        if (drawBtn.isSelected) {
            let touch = touches.first!
            addCoordinates(touch)
            touchLocation = touch.location(in: canvasView)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let drawBtn = drawBtn else {
            return
        }
        if (drawBtn.isSelected) {
            let touch = touches.first!
            self.addCoordinates(touch)
            drawStrokeOnTouch(touch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let drawBtn = drawBtn else {
            return
        }
        if (drawBtn.isSelected) {
            let touch = touches.first!
            self.addCoordinates(touch)
            drawStrokeOnTouch(touch)
            self.onDrawAction("")
        }
    }
    
    func drawStrokeOnTouch(_ touch: UITouch) {
        guard let canvasView = canvasView else {
            return
        }
        
        let currentLocation = touch.location(in: canvasView)
        
        UIGraphicsBeginImageContextWithOptions(canvasView.frame.size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        canvasView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasView.frame.width, height: canvasView.frame.height))
        ctx!.setLineCap(CGLineCap.round)
        ctx!.setLineWidth(3.0)
        ctx!.setStrokeColor(UIColor.black.withAlphaComponent(1).cgColor)
        ctx!.beginPath()
        ctx!.move(to: CGPoint(x: touchLocation.x, y: touchLocation.y))
        ctx!.addLine(to: CGPoint(x: currentLocation.x, y: currentLocation.y))
        ctx!.strokePath()
        canvasView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        touchLocation = currentLocation
    }
    
    //get coordinate of selected location
    func addCoordinates(_ touch: UITouch) {
        if let mkMapView = mkMapView {
            let location = touch.location(in: mkMapView)
            let coordinate = mkMapView.convert(location, toCoordinateFrom: mkMapView)
            drawingCoordinates.append(coordinate)
        } else if let gmsMapView = gmsMapView {
            let location = touch.location(in: gmsMapView)
            let coordinate = gmsMapView.projection.coordinate(for: location)
            drawingCoordinates.append(coordinate)
        }
    }
    
}

//MARK: - FBClusteringManagerDelegate View Delegates
extension AppleGoogleMapView: FBClusteringManagerDelegate {

    func cellSizeFactorForCoordinator(_ coordinator:FBClusteringManager) -> CGFloat{
        return CGFloat(clusterCellSize)
    }

}
