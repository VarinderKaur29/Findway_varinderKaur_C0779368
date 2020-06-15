//
//  Coordinates.swift
//  FindWay_VarinderKaur_C0779368
//
//  Created by user175478 on 6/13/20.
//  Copyright © 2020 user175478. All rights reserved.
//

import Foundation
import MapKit

@objc class Coordinates: NSObject {
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
    static func getPlaces() -> [Coordinates] {
        
        guard let path = Bundle.main.path(forResource: "Coordinates", ofType: "plist"), let array = NSArray(contentsOfFile: path) else { return [] }
        
        var places = [Coordinates]()
        
        for item in array {
            
            let dictionary = item as? [String : Any]
            let title = dictionary?["title"] as? String
            let subtitle = dictionary?["description"] as? String
            let latitude = dictionary?["latitude"] as? Double ?? 0, longitude = dictionary?["longitude"] as? Double ?? 0
            
        
            
            let place = Coordinates(title: title, subtitle: subtitle, coordinate: CLLocationCoordinate2DMake(latitude, longitude))
            places.append(place)
        }
        
        return places as [Coordinates]
    }
}

extension Coordinates: MKAnnotation {
    
}
