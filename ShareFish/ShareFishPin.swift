//
//  ShareFishPin.swift
//  ShareFish
//
//  Created by Traemani Hawkins on 1/16/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Parse

class ShareFishPin : NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image = UIImage(named: "sharefishpin.png")
    var merchant: PFObject?
    
    init(coordinate: CLLocationCoordinate2D, title : String, merchant: PFObject)
    {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = ""
        self.merchant = merchant
        super.init()
    }
    
    func assignSubtitle(subtitle : String)
    {
        self.subtitle = subtitle
    }
}
