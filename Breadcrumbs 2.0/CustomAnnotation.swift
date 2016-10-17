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
    var phone: String!
    var name: String!
    var address: String!
    var image: UIImage!
    
    var message: String!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
