//
//  ViewController.swift
//  Google Map
//
//  Created by AshutoshD on 02/04/20.
//  Copyright © 2020 ravindraB. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    

    @IBOutlet weak var mMapView: MKMapView!
    var zoom = 1.0
    var currentLocationStr = "My location"
    let places = Place.getPlaces()
    var pointAnnotation:CustomPointAnnotation!
    
    @IBOutlet weak var slider: UISlider!
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    //MARK: - UIViewController life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
//        mMapView.mapType = .satellite //for view as satellite
        setUpMapView()
        requestLocationAccess()
        addAnnotations()
        SliderDidTapped(self)
    }
    
    
   /* Do yourself a favor and define a separate IBOutlet for the slider. It turns out that your slider is measured in miles, but the span is measured in degrees latitude and longitude. How long 1 degree of latitude/longitude is in terms of miles vary depend on your location on Earth. Wikipedia has some discussion on latitude and longitude. Assuming you are on the equator, the conversion is 69 miles per degree of both.*/
    
    @IBAction func SliderDidTapped(_ sender: Any) {
        
        let miles = Double(self.slider.value)
        let delta = miles / 69.0
        
        var currentRegion = self.mMapView.region
        currentRegion.span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        self.mMapView.region = currentRegion
        
       print("\(Int(round(miles))) miles")
        
        let (lat, long) = (currentRegion.center.latitude, currentRegion.center.longitude)
//        currentLocationLabel.text = "Current location: \(lat), \(long))"
        print("Current location: \(lat), \(long))")
    }
    
    func addAnnotations() {
        mMapView?.delegate = self
        mMapView?.addAnnotations(places)
    }
    
    
    
    func requestLocationAccess() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
            
        case .denied, .restricted:
            print("location access denied")
            
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //Zoom in map
//    @IBAction func BtnPlusTapped(_ sender: Any) {
////        zoom = zoom + 1
//
//        var zoomRect = MKMapRect.null
//        for annotation in mMapView.annotations {
//            let annotationPoint = MKMapPoint(annotation.coordinate)
//            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
//            if (zoomRect.isNull) {
//                zoomRect = pointRect
//            } else {
//                zoomRect = zoomRect.union(pointRect)
//            }
//        }
//        mMapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: true)
//    }
//    //Zoom out map
//    @IBAction func BtnMinusTapped(_ sender: Any) {
//        if zoom >= 1 {
//            zoom = zoom - 1
//            zoomMap(byFactor: zoom)
//        }
//
////        self.mMapView.animate(toZoom: zoom)
//    }
    
    func zoomMap(byFactor delta: Double) {
        var region: MKCoordinateRegion = self.mMapView.region
        var span: MKCoordinateSpan = mMapView.region.span
        span.latitudeDelta *= delta
        span.longitudeDelta *= delta
        region.span = span
        mMapView.setRegion(region, animated: true)
    }
    
    
    
    
    //MARK: - Setup Methods
    func setUpMapView() {
        mMapView.showsUserLocation = true
        mMapView.showsCompass = true
        mMapView.showsScale = true
        currentLocation()
    }
    
    //MARK: - Helper Method
    func currentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        } else {
            // Fallback on earlier versions
        }
        locationManager.startUpdatingLocation()
    }
    
    
//    //MARK: - CLLocationManagerDelegate Methods
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//    let location = locations.last! as CLLocation
//    let currentLocation = location.coordinate
//    let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 800, longitudinalMeters: 800)
//    mMapView.setRegion(coordinateRegion, animated: true)
//    locationManager.stopUpdatingLocation()
//
//        let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
//        mkAnnotation.coordinate = CLLocationCoordinate2DMake(mUserLocation.coordinate.latitude, mUserLocation.coordinate.longitude)
//        mkAnnotation.title = self.setUsersClosestLocation(mLattitude: mUserLocation.coordinate.latitude, mLongitude: mUserLocation.coordinate.longitude)
//        mMapView.addAnnotation(mkAnnotation)
//
//
//    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mUserLocation:CLLocation = locations[0] as CLLocation
        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
        let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mMapView.setRegion(mRegion, animated: true)

        
        // Get user's Current Location and Drop a pin
        let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
        mkAnnotation.coordinate = CLLocationCoordinate2DMake(mUserLocation.coordinate.latitude, mUserLocation.coordinate.longitude)
        mkAnnotation.title = self.setUsersClosestLocation(mLattitude: mUserLocation.coordinate.latitude, mLongitude: mUserLocation.coordinate.longitude)
        mMapView.addAnnotation(mkAnnotation)
    }
    //MARK:- Intance Methods
    func setUsersClosestLocation(mLattitude: CLLocationDegrees, mLongitude: CLLocationDegrees) -> String {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: mLattitude, longitude: mLongitude)
        
        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            
            if let mPlacemark = placemarks{
                if let dict = mPlacemark[0].addressDictionary as? [String: Any]{
                    if let Name = dict["Name"] as? String{
                        if let City = dict["City"] as? String{
                            self.currentLocationStr = Name + ", " + City
                        }
                    }
                }
            }
        }
        return currentLocationStr
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    
}


extension ViewController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
            
        else {
//            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
////            if annotationView == nil {
//////                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
////            }
////            if let  title =
//            annotationView.image = UIImage(named: "place icon")
//
//            for item in places {
//                print(item.title!)
//                print(item.subtitle!)
//            }
            let reuseIdentifier = "pin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            let customPointAnnotation = annotation as! CustomPointAnnotation
            annotationView?.image = UIImage(named: customPointAnnotation.pinCustomImageName ?? "")

            return annotationView
        }
    }
}


