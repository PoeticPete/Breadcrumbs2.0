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
var myVotes = [String: Int]()


// this function will create a new geoFire location in Firebase
func setNewLocation(loc: CLLocation, baseRef: FIRDatabaseReference, key:String) {
    let newGeoFire = GeoFire(firebaseRef: baseRef)
    newGeoFire?.setLocation(loc, forKey: key)
}

func getMyVotes() {
    myVotesRef.child(deviceID).observeSingleEvent(of: .value, with: { (snapshot) in
        for child in snapshot.children {
            let childSnap = child as! FIRDataSnapshot
            myVotes[childSnap.key] = childSnap.value as! Int
        }
    })
}

// get color based on number of likes
func getColor(_ likes:Int) -> UIColor {
    switch likes {
    case let x where x >= 100:
        return UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1.0)
    case let x where x >= 50:
        return UIColor(red: 211.0/255.0, green: 84.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    case let x where x >= 25:
        return UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1.0)
    case let x where x >= 5:
        return UIColor(red: 243.0/255.0, green: 156.0/255.0, blue: 18.0/255.0, alpha: 1.0)
    default:
        return UIColor(red: 241.0/255.0, green: 196.0/255.0, blue: 15.0/255.0, alpha: 1.0)
    }
}
