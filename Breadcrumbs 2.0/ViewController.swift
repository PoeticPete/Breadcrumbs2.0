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
    var flatAnnotationImage:UIImage!
    var currentLocationName = ""
    var imagePicked:UIImage!
    var Cloudinary:CLCloudinary!
    var annotation:CustomAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set class variables
        geofireRef = FIRDatabase.database().reference().child("test")
        geoFire = GeoFire(firebaseRef: geofireRef)
        map.delegate = self
        setupLocationManager()
        setupAnnotationIconImage()
        getMyVotes()
        Cloudinary = CLCloudinary(url: "cloudinary://645121525236522:HQ90xZWm0Dt0w2UzIcSLtjhG5CA@dufz2rmju") // get this value from server later
        map.showsUserLocation = true
        if UserDefaults.standard.object(forKey: "lastLongitude") != nil && UserDefaults.standard.object(forKey: "lastLatitude") != nil && UserDefaults.standard.object(forKey: "lastLocationName") != nil {
            print("successfully retrieved all user defaults")
            currentLocation = CLLocation(latitude: UserDefaults.standard.object(forKey: "lastLatitude") as! CLLocationDegrees, longitude: UserDefaults.standard.object(forKey: "lastLongitude") as! CLLocationDegrees)
            currentLocationName = UserDefaults.standard.object(forKey: "lastLocationName") as! String
            let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10))
            self.map.setRegion(region, animated: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getLocalMessages()
    }
    
    
    @IBAction func composeTapped(_ sender: AnyObject) {
        manager.requestLocation()
        presentAlert(image: nil)

    }

    func presentAlert(image:UIImage?) {
        let alertViewController = NYAlertViewController()
        
        // Set a title and message
        alertViewController.title = currentLocationName
        alertViewController.message = ""
        
        // Customize appearance as desired
        alertViewController.buttonCornerRadius = 20.0
        alertViewController.view.tintColor = self.view.tintColor
        alertViewController.titleFont = UIFont(name: "AvenirNext-Bold", size: 19.0)
        alertViewController.messageFont = UIFont(name: "AvenirNext-Medium", size: 16.0)
        alertViewController.cancelButtonTitleFont = UIFont(name: "AvenirNext-Medium", size: 16.0)
        alertViewController.cancelButtonTitleFont = UIFont(name: "AvenirNext-Medium", size: 16.0)
        alertViewController.swipeDismissalGestureEnabled = true
        alertViewController.backgroundTapDismissalGestureEnabled = true
        // Add alert actions
        
        let photoAction = NYAlertAction(
            title: "Photo",
            style: .default,
            handler: { (action: NYAlertAction?) -> Void in
                self.dismiss(animated: false, completion: nil)
                self.presentCamera()
                
        })
        alertViewController.addAction(photoAction)
        
        let postAction = NYAlertAction(
            title: "Post",
            style: .default,
            handler: { (action: NYAlertAction?) -> Void in
                print("OK PRESSED")
                
                let textString = (alertViewController.textFields![0] as AnyObject).text!
                let trimmedString = textString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                print(trimmedString)
                if image != nil {
                    let randomRef = FIRDatabase.database().reference().childByAutoId()
                    self.uploadToCloudinary(fileId: "\(randomRef.key)")
                } else if trimmedString == "" {
                    print("EMPTY")
                } else {
//                    let dropPin = CustomAnnotation(coordinate: self.currentLocation.coordinate)
//                    dropPin.message = trimmedString
//                    print(self.currentLocation.coordinate)
                    self.setMessage(loc: self.currentLocation, message: trimmedString)
                    self.getLocalMessages()
                }
                self.dismiss(animated: true, completion: nil)
        })
        alertViewController.addAction(postAction)
        
        if image != nil {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width * 4/5, height: self.view.frame.height * 4/5)
            imageView.contentMode = .scaleAspectFit
            alertViewController.alertViewContentView = imageView
        }
        alertViewController.addTextField { (textfield) in
            textfield?.textColor = UIColor.darkText
        }
        
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func presentCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            print("presenting imagePicker")
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("not available")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // get region
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10))
        UserDefaults.standard.set(location.coordinate.latitude as NSNumber, forKey: "lastLatitude")
        UserDefaults.standard.set(location.coordinate.longitude as NSNumber, forKey: "lastLongitude")
        
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
                self.currentLocationName = locationName
                UserDefaults.standard.set(locationName, forKey: "lastLocationName")
//                self.alert.title = locationName
                
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
        
        
        annotation = view.annotation as! CustomAnnotation
        
        if annotation.hasPicture == true {
            print("THIS VIEW HAS A PICTURE")
            let views = Bundle.main.loadNibNamed("PhotoCallout", owner: self, options: nil)
            let calloutview = views![0] as! PhotoCalloutView
            calloutview.layer.cornerRadius = 20
            calloutview.layer.borderWidth = 5.0
            calloutview.layer.borderColor = getColor(annotation.upVotes!).cgColor
            calloutview.layer.masksToBounds = true
            calloutview.annotation = annotation
            calloutview.photoView.contentMode = .scaleAspectFill
            
            
            let url = "https://res.cloudinary.com/dufz2rmju/\(annotation.key!)"
            if let img = getImageFromURL(url) {
                calloutview.photoView.image = img
                annotation.picture = img
            } else {
                calloutview.photoView.image = UIImage()
                annotation.picture = UIImage()
            }

            calloutview.commentsButton.addTarget(self, action: #selector(ViewController.toCrumbTableView), for: UIControlEvents.touchUpInside)
            calloutview.commentsButton.backgroundColor = getColor(annotation.upVotes!)
            
            calloutview.center = CGPoint(x: self.view.center.x, y: self.view.center.y*0.67)
            calloutview.alpha = 0.0
            calloutview.backgroundColor = UIColor.white
            calloutview.isUserInteractionEnabled = true
            self.view.addSubview(calloutview)
            UIView.animate(withDuration: 0.4, animations: {
                calloutview.alpha = 1.0
            })
            
            
        } else {
            let views = Bundle.main.loadNibNamed("Callout", owner: self, options: nil)
            let calloutview = views![0] as! CalloutView
            calloutview.layer.cornerRadius = 20
            calloutview.layer.borderWidth = 5.0
            calloutview.layer.borderColor = getColor(annotation.upVotes!).cgColor
            calloutview.layer.masksToBounds = true
            calloutview.messageLabel.text = annotation.message
            calloutview.upvotesLabel.text = "\(annotation.upVotes!)"
            calloutview.annotation = annotation
            calloutview.timestampLabel.text = timeAgoSinceDate(date: calloutview.annotation.timestamp, numericDates: true)
            
            if myVotes[annotation.key] == 1 {
                calloutview.upSelected = true
                calloutview.upOutlet.tintColor = getColor(annotation.upVotes!)
            } else if myVotes[annotation.key] == -1 {
                calloutview.downSelected = true
                calloutview.downOutlet.tintColor = getColor(annotation.upVotes!)
            }
            //        button.addTarget(self, action: "action:", forControlEvents: UIControlEvents.TouchUpInside)
            
            //then make a action method :
            
            calloutview.commentsButton.addTarget(self, action: #selector(ViewController.toCrumbTableView), for: UIControlEvents.touchUpInside)
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

    }
    
    func toCrumbTableView() {
        self.performSegue(withIdentifier: "ShowPostSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPostSegue" {
            var nextVC = segue.destination as! CrumbTableViewController
            nextVC.annotation = annotation
        }
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
            if subview.isKind(of: CalloutView.self) || subview.isKind(of: PhotoCalloutView.self){
                UIView.animate(withDuration: 0.4, animations: {
                    subview.alpha = 0.0
                    }, completion: { void in
                        subview.removeFromSuperview()
                })
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            if (view.annotation?.isKind(of: MKUserLocation.self))! {
                view.canShowCallout = false
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
        
        annotationView!.image = flatAnnotationImage.imageWithColor(color1: getColor(thisAnnotation.upVotes))
        return annotationView
    }
    
    
    
    // --------------------------SETUP FUNCTIONS (CALLED IN VIEW DID LOAD)--------------------------

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
    
    
    // ----------------------Retrieve from Database-------------------------------------------
    func getLocalMessages() {
        print("getting local messages")
        let currGeoFire = GeoFire(firebaseRef: currPostsRef)
        let center = currentLocation
        let circleQuery = currGeoFire!.query(at: center, withRadius: 100)
        
        circleQuery!.observe(.keyEntered, with: { snapshot in
            
            allPostsRef.child(snapshot.0!).observeSingleEvent(of: .value, with: { messageSnap in
                if let time = messageSnap.childSnapshot(forPath: "timestamp").value as? TimeInterval {
                    let date = NSDate(timeIntervalSince1970: time/1000)
                    var hasPicture = false
                    if messageSnap.childSnapshot(forPath: "hasPicture").exists() {
                        hasPicture = messageSnap.childSnapshot(forPath: "hasPicture").value as! Bool
                    }
                    self.addAnnotation(loc: snapshot.1!, message: messageSnap.childSnapshot(forPath: "message").value as! String, upVotes: messageSnap.childSnapshot(forPath: "upVotes").value as! Int, key: messageSnap.key, timestamp: date, hasPicture: hasPicture)
                }
            })
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
    
    func addAnnotation(loc:CLLocation, message:String, upVotes:Int, key:String, timestamp:NSDate, hasPicture:Bool) {
        let point = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
        point.message = message
        point.upVotes = upVotes
        point.key = key
        point.timestamp = timestamp
        point.hasPicture = hasPicture
        self.map.addAnnotation(point)
    }
    
    @IBAction func refreshTapped(_ sender: AnyObject) {
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        clearCallouts()
        getLocalMessages()
    }


}

extension ViewController: UIImagePickerControllerDelegate,
UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let photo = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imagePicked = photo
            print("picked \(photo)")
        }
        self.dismiss(animated: true, completion: nil)
        
        presentAlert(image: imagePicked)
    }
    
}
extension ViewController: CLUploaderDelegate {
    
    func uploadToCloudinary(fileId:String){
        //        let forUpload = UIImagePNGRepresentation(self.image!)! as Data
        let forUpload = UIImageJPEGRepresentation(self.imagePicked!, 0.2)! as Data
        let uploader = CLUploader(Cloudinary, delegate: self)
        
        //        uploader?.upload(forUpload, options: ["public_id":fileId])
        
        uploader?.upload(forUpload, options: ["public_id":fileId], withCompletion:onCloudinaryCompletion, andProgress:onCloudinaryProgress)
        
    }
    
    func onCloudinaryCompletion(successResult:[AnyHashable : Any]?, errorResult:String?, code:Int, idContext:Any?) {
        print(successResult?.values)
        print(code)
        print(errorResult)
        let fileId = successResult?["public_id"] as! String
        
        uploadDetailsToServer(fileId: fileId, loc: self.currentLocation)
    }
    
    func uploadDetailsToServer(fileId:String, loc:CLLocation){
        
        //        let allPosts = FIRDatabase.database().reference().child("allPosts")
        //        let myPosts = FIRDatabase.database().reference().child("myPosts")
        print(fileId)
        let firebaseTimeStamp = [".sv":"timestamp"]
        setNewLocation(loc: loc, baseRef: currPostsRef, key: fileId)
        allPostsRef.child(fileId).child("upVotes").setValue(0)
        allPostsRef.child(fileId).child("timestamp").setValue(firebaseTimeStamp)
        allPostsRef.child(fileId).child("hasPicture").setValue(true)
        allPostsRef.child(fileId).child("message").setValue("picture with ID \(fileId)")

    }
    
    func onCloudinaryProgress(bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, idContext:Any?) {
        //do any progress update you may need
        print("bytes written: \(bytesWritten)")
        print("total bytes written \(totalBytesWritten)")
        print("total bytes expected to write \(totalBytesExpectedToWrite)")
    }
    
}


