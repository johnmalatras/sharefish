//
//  NearMeFreeCell.swift
//  ShareFish
//
//  Created by John Malatras on 6/25/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation
import ParseUI

class NearMeFreeCell : UITableViewCell {
    
    @IBOutlet weak var ImageViewV: PFImageView!
    @IBOutlet weak var DistanceLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    
    var tapAction: ((UITableViewCell) -> Void)?
    
    func setNameLbl(name: String){
        self.NameLabel.text = name
    }
    
    func setDistanceLbl(distance: Double){
        let distanceString = "\(round(distance * 10)/10) mi away"
        self.DistanceLabel.text = distanceString
    }
    
    func setImgView(image: PFFile, open: Bool){
        
        self.ImageViewV.layer.borderWidth = 2.2
        if open {
            self.ImageViewV.layer.borderColor = UIColor(red: 37.0/255.0, green: 182.0/255.0, blue: 71.0/255.0, alpha: 1.0).CGColor
        }
        else {
            self.ImageViewV.layer.borderColor = UIColor(red: 220.0/255.0, green: 26.0/255.0, blue: 26.0/255.0, alpha: 1.0).CGColor
        }
        self.ImageViewV.layer.cornerRadius = self.ImageViewV.frame.height/2.033
        self.ImageViewV.contentMode = UIViewContentMode.ScaleAspectFill
        self.ImageViewV.clipsToBounds = true
        
        self.ImageViewV.file = image
        self.ImageViewV.loadInBackground()
        self.ImageViewV.sizeToFit()
    }
    
    @IBAction func RequestButtonClicked(sender: AnyObject) {
        tapAction?(self)
    }
}