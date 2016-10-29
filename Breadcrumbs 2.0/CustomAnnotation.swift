//
//  CustomAnnotation.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/17/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//


import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D

    var key:String!
    var message: String!
    var upVotes: Int!
    var timestamp: NSDate!
    var hasPicture: Bool!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
