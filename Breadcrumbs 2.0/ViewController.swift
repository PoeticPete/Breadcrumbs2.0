//
//  ViewController.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/14/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit
import FirebaseDatabase


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    // declare class variables
    var geofireRef:FIRDatabaseReference!
    var geoFire:GeoFire!
    var manager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set class variables
        geofireRef = FIRDatabase.database().reference().child("test")
        geoFire = GeoFire(firebaseRef: geofireRef)
        manager = CLLocationManager()
        manager.allowsBackgroundLocationUpdates = true
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        
        manager.startUpdatingLocation()
        map.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        
//        geoFire?.setLocation(CLLocation(latitude: 37.7853889, longitude: -122.4056973), forKey: "firebase-hq")
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
//        let userLocation:CLLocation = locations[0]
//        let latitude:CLLocationDegrees = userLocation.coordinate.latitude
//        let longitude:CLLocationDegrees = userLocation.coordinate.longitude
        //        let latDelta:CLLocationDegrees = 0.01
        //        let lonDelta:CLLocationDegrees = 0.01
        //        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        //        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        //        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
//                map.setRegion(region, animated: false)
        
        // get region
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.map.setRegion(region, animated: true)
        
        // set to Firebase
        let randomKey = FIRDatabase.database().reference().childByAutoId()
        geoFire.setLocation(location, forKey: randomKey.key)
    
        
        
        
    }

}

