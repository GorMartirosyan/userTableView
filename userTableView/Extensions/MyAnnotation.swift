//
//  MyAnnotation.swift
//  userTableView
//
//  Created by Gor on 12/31/20.
//

import MapKit

class MyAnnotation : NSObject, MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate : CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
}
