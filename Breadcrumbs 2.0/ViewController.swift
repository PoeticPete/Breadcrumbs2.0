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
    var flatAnnotationImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set class variables
        geofireRef = FIRDatabase.database().reference().child("test")
        geoFire = GeoFire(firebaseRef: geofireRef)
        map.delegate = self
        setupLocationManager()
        setupAlertView()
        setupAnnotationIconImage()
        
        
        // TESTING
        var coordinates = [[37.35647419,-122.11607907],[48.85196,2.33944],[48.85376,2.33953]]// Latitude,Longitude

        let coordinate = coordinates[0]
        let point = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: coordinate[0] , longitude: coordinate[1] ))
        point.message = "First message"
        self.map.addAnnotation(point)
        
    }
    
    
    @IBAction func composeTapped(_ sender: AnyObject) {
        manager.requestLocation()
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
    
    
    // --------------------------ANNOTATIONS--------------------------
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // 1
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        var annotation = view.annotation as! CustomAnnotation
        let views = Bundle.main.loadNibNamed("Callout", owner: self, options: nil)
        let calloutview = views![0] as! CalloutView
        calloutview.layer.cornerRadius = 20
        calloutview.layer.masksToBounds = true
        calloutview.messageLabel.text = annotation.message
        
        calloutview.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutview.bounds.size.height*0.52)
        calloutview.alpha = 0.0
        calloutview.backgroundColor = themeColor
        calloutview.isUserInteractionEnabled = true
        
        //-------------------------------optional stuff------------------------------
        print(calloutview.frame)

        //-------------------------------------------------------------------------------
        
//        calloutview.frame = CGRect(x: Double(calloutview.center.x - 330/2), y: Double(calloutview.center.y - 230/2), width: 330.0, height: 230.0)
        view.addSubview(calloutview)
        UIView.animate(withDuration: 0.4, animations: {
            calloutview.alpha = 1.0
        })
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AnnotationView.self)
        {
            for subview in view.subviews
            {
                UIView.animate(withDuration: 0.4, animations: {
                    subview.alpha = 0.0
                    }, completion: { void in
                        subview.removeFromSuperview()
                })
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("IN VIEW FOR ANNOTATION")
        if annotation is MKUserLocation
        {
            return nil
        }
        var annotationView = self.map.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView!.canShowCallout = false
        } else{
            annotationView?.annotation = annotation
        }
        annotationView!.image = flatAnnotationImage.imageWithColor(color1: themeColor)
        return annotationView
    }
    
    
    
    // --------------------------SETUP FUNCTIONS (CALLED IN VIEW DID LOAD)--------------------------
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
                print(self.currentLocation.coordinate)
                self.setMessage(loc: self.currentLocation, message: trimmedString)
                self.map.addAnnotation(dropPin)
            }
            self.alert.textFields![0].text = ""
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            print("CANCEL PRESSED")
            self.alert.textFields![0].text = ""
        }))
    }
    
    
    func setupAnnotationIconImage() {
        flatAnnotationImage = UIImage(named: "map-marker")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    }
    
    func setupLocationManager() {
        manager = CLLocationManager()
        manager.allowsBackgroundLocationUpdates = true
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        manager.requestLocation()
    }
    
    
    // ----------------------Retrieve from Database------------------------
    func getLocalMessages() {
        print("getting local messages")
        let currPosts = FIRDatabase.database().reference().child("currentPosts")
        let currGeoFire = GeoFire(firebaseRef: currPosts)
        let center = currentLocation
        let circleQuery = currGeoFire!.query(at: center, withRadius: 100)
        
        circleQuery!.observe(.keyEntered, with: { snapshot in
            print(snapshot.0!)
            currPosts.child(snapshot.0!).observeSingleEvent(of: .value, with: { messageSnap in
                self.addAnnotation(loc: snapshot.1!, message: messageSnap.childSnapshot(forPath: "message").value as! String)
                
            })
            print(snapshot.1!)
            
        })
        
        
    }
    
    func setMessage(loc:CLLocation, message:String) {
        let randomKey = FIRDatabase.database().reference().childByAutoId()
        let currPosts = FIRDatabase.database().reference().child("currentPosts")
//        let allPosts = FIRDatabase.database().reference().child("allPosts")
//        let myPosts = FIRDatabase.database().reference().child("myPosts")
        
        let firebaseTimeStamp = [".sv":"timestamp"]
        setNewLocation(loc: loc, baseRef: currPosts, key: randomKey.key)
        currPosts.child(randomKey.key).child("message").setValue(message)
        currPosts.child(randomKey.key).child("timestamp").setValue(firebaseTimeStamp)
        

    }
    
    func addAnnotation(loc:CLLocation, message:String) {
        let point = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
        point.message = message
        self.map.addAnnotation(point)
    }
    
    @IBAction func refreshTapped(_ sender: AnyObject) {
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        getLocalMessages()
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

