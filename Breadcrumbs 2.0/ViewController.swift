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
    var currentLocation:CLLocation!
    let alert = UIAlertController(title: "Drop a crumb", message: nil, preferredStyle: UIAlertControllerStyle.alert)
    
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
        manager.requestLocation()
        map.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        setupAlertView()
        
        
        // TESTING
        var coordinates = [[48.85672,2.35501],[48.85196,2.33944],[48.85376,2.33953]]// Latitude,Longitude

        let coordinate = coordinates[0]
        let point = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: coordinate[0] , longitude: coordinate[1] ))
        self.map.addAnnotation(point)
        
    }
    
    
    @IBAction func composeTapped(_ sender: AnyObject) {
        manager.requestLocation()
        
//        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))

        
        self.present(alert, animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        // get region
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.map.setRegion(region, animated: true)
        
        // set to Firebase
        let randomKey = FIRDatabase.database().reference().childByAutoId()
//        geoFire.setLocation(location, forKey: randomKey.key)
    
        currentLocation = location

        setCurrentLocationName()
        print("UPDATED \(location)")

    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failllleeeddd\n")
        print(error)
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation
//        {
//            print("annotation is user location")
//            return nil
//        }
//        var annotationView = self.map.dequeueReusableAnnotationView(withIdentifier: "Pin")
//        if annotationView == nil{
//            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
//            annotationView?.canShowCallout = false
//        }else{
//            annotationView?.annotation = annotation
//        }
//        annotationView?.image = UIImage(named: "map-marker")
//        return annotationView
//    }
    
    func setCurrentLocationName() {
        
        CLGeocoder().reverseGeocodeLocation(currentLocation)
        {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            if placeMark == nil {
                return
            }
            
            // Location name
            if let locationName = placeMark.addressDictionary?["Name"] as? String
            {
                self.alert.title = locationName
                
            }
        }
    }
    
    func setupAlertView() {
        alert.addTextField { (textfield) in
            textfield.textColor = UIColor.darkText
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            print("OK PRESSED")
            let textString = self.alert.textFields![0].text!
            let trimmedString = textString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)

            if trimmedString == "" {
                print("EMPTY")
            } else {
                let dropPin = CustomAnnotation(coordinate: self.currentLocation.coordinate)
                dropPin.message = trimmedString
                self.map.addAnnotation(dropPin)
            }
            self.alert.textFields![0].text = ""

        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            print("CANCEL PRESSED")
            self.alert.textFields![0].text = ""
        }))
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("hi")
        print(view.annotation?.title)
    }

}


// OLD LOCATION CODE
//        let userLocation:CLLocation = locations[0]
//        let latitude:CLLocationDegrees = userLocation.coordinate.latitude
//        let longitude:CLLocationDegrees = userLocation.coordinate.longitude
//        let latDelta:CLLocationDegrees = 0.01
//        let lonDelta:CLLocationDegrees = 0.01
//        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
//        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
//        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
//        map.setRegion(region, animated: false)

