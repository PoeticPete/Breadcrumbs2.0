//
//  Global.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/17/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//
import Firebase

let deviceID = UIDevice.current.identifierForVendor!.uuidString
let themeColor = UIColor(red: 34.0/255.0, green: 167.0/255.0, blue: 240.0/255.0, alpha: 1.0)
let allPostsRef = FIRDatabase.database().reference().child("allPosts")
let currPostsRef = FIRDatabase.database().reference().child("currentPostLocations")
let myVotesRef = FIRDatabase.database().reference().child("myVotes")


// this function will create a new geoFire location in Firebase
func setNewLocation(loc: CLLocation, baseRef: FIRDatabaseReference, key:String) {
    let newGeoFire = GeoFire(firebaseRef: baseRef)
    newGeoFire?.setLocation(loc, forKey: key)
}

func getMyVotes() {
    myVotesRef.child(deviceID).observeSingleEvent(of: .value, with: { (snapshot) in
        print(snapshot)
    })
}
