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
        getMyVotes()
        map.showsUserLocation = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getLocalMessages()
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
        mapView.setCenter((view.annotation?.coordinate)!, animated: false)
        
        var annotation = view.annotation as! CustomAnnotation
        let views = Bundle.main.loadNibNamed("Callout", owner: self, options: nil)
        let calloutview = views![0] as! CalloutView
        calloutview.layer.cornerRadius = 20
        calloutview.layer.borderWidth = 5.0
        calloutview.layer.borderColor = getColor(annotation.upVotes!).cgColor
        calloutview.layer.masksToBounds = true
        calloutview.messageLabel.text = annotation.message
        calloutview.upvotesLabel.text = "\(annotation.upVotes!)"
        calloutview.key = annotation.key
        calloutview.annotation = annotation
        if myVotes[calloutview.key] == 1 {
            calloutview.upSelected = true
            calloutview.upOutlet.tintColor = getColor(annotation.upVotes!)
        } else if myVotes[calloutview.key] == -1 {
            calloutview.downSelected = true
            calloutview.downOutlet.tintColor = getColor(annotation.upVotes!)
        }
//        button.addTarget(self, action: "action:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //then make a action method :

        calloutview.commentsButton.addTarget(self, action: #selector(ViewController.action), for: UIControlEvents.touchUpInside)
        calloutview.commentsButton.backgroundColor = getColor(annotation.upVotes!)
        
//        calloutview.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutview.bounds.size.height*0.52)
        calloutview.center = CGPoint(x: self.view.center.x, y: self.view.center.y*0.67)
        calloutview.alpha = 0.0
        calloutview.backgroundColor = UIColor.white
        calloutview.isUserInteractionEnabled = true
        
        
        self.view.addSubview(calloutview)
        UIView.animate(withDuration: 0.4, animations: {
            calloutview.alpha = 1.0
        })
        
        
    }
    
    func action() {
        self.performSegue(withIdentifier: "ShowPostSegue", sender: nil)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        for subview in self.view.subviews
        {
            clearCallouts()
            map.selectedAnnotations.removeAll()

        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AnnotationView.self)
        {
            clearCallouts()
        }
    }
    
    func clearCallouts() {
        for subview in self.view.subviews
        {
            if subview.isKind(of: CalloutView.self) {
                UIView.animate(withDuration: 0.4, animations: {
                    subview.alpha = 0.0
                    }, completion: { void in
                        subview.removeFromSuperview()
                })
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
        let thisAnnotation = annotation as! CustomAnnotation
        print(thisAnnotation.upVotes)
        
        annotationView!.image = flatAnnotationImage.imageWithColor(color1: getColor(thisAnnotation.upVotes))
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
                self.getLocalMessages()
//                self.map.addAnnotation(dropPin)
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
        let currGeoFire = GeoFire(firebaseRef: currPostsRef)
        let center = currentLocation
        let circleQuery = currGeoFire!.query(at: center, withRadius: 100)
        
        circleQuery!.observe(.keyEntered, with: { snapshot in
            print(snapshot.0!)
            
            allPostsRef.child(snapshot.0!).observeSingleEvent(of: .value, with: { messageSnap in
                self.addAnnotation(loc: snapshot.1!, message: messageSnap.childSnapshot(forPath: "message").value as! String, upVotes: messageSnap.childSnapshot(forPath: "upVotes").value as! Int, key: messageSnap.key)
                
            })
            print(snapshot.1!)
            
        })
        
        
    }
    
    func setMessage(loc:CLLocation, message:String) {
        let randomKey = FIRDatabase.database().reference().childByAutoId()
//        let allPosts = FIRDatabase.database().reference().child("allPosts")
//        let myPosts = FIRDatabase.database().reference().child("myPosts")
        
        let firebaseTimeStamp = [".sv":"timestamp"]
        setNewLocation(loc: loc, baseRef: currPostsRef, key: randomKey.key)
        allPostsRef.child(randomKey.key).child("message").setValue(message)
        allPostsRef.child(randomKey.key).child("upVotes").setValue(0)
        allPostsRef.child(randomKey.key).child("timestamp").setValue(firebaseTimeStamp)
        
    }
    
    func addAnnotation(loc:CLLocation, message:String, upVotes:Int, key:String) {
        let point = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
        point.message = message
        point.upVotes = upVotes
        point.key = key
        self.map.addAnnotation(point)
    }
    
    @IBAction func refreshTapped(_ sender: AnyObject) {
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        clearCallouts()
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

