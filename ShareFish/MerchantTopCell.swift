//
//  MerchantTopCell.swift
//  ShareFish
//
//  Created by John Malatras on 2/21/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation
import ParseUI

class MerchantTopCell : UITableViewCell{
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var DistanceLabel: UILabel!
    @IBOutlet var ImageViewV: PFImageView!
    @IBOutlet weak var StatusLabel: UILabel!
    
    
    
    func setNameLbl(name: String){
        self.NameLabel.text = name
    }
    
    func setStatusLbl(status: String){
        self.StatusLabel.text = status
    }
    
    func setDistanceLbl(distanceString: String){
        self.DistanceLabel.text = distanceString
    }
    
    func setImgView(image: PFFile){
        
        self.ImageViewV.layer.borderWidth = 2
        self.ImageViewV.layer.borderColor = UIColor.blackColor().CGColor
        self.ImageViewV.layer.cornerRadius = self.ImageViewV.frame.height/2.033
        self.ImageViewV.contentMode = UIViewContentMode.ScaleAspectFill
        self.ImageViewV.clipsToBounds = true
        
        self.ImageViewV.file = image
        self.ImageViewV.loadInBackground()
        self.ImageViewV.sizeToFit()
    }
}