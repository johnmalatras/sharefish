//
//  NearMeCell.swift
//  ShareFish
//
//  Created by John Malatras on 2/6/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation
import ParseUI

class NearMeCell : UITableViewCell{
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var DistanceLabel: UILabel!
    @IBOutlet var ImageViewV: PFImageView!
    @IBOutlet weak var AgeImageView: UIImageView!
    @IBOutlet weak var AgeLabel: UILabel!
    @IBOutlet weak var GenderImageView: UIImageView!
    
    
    func setAgeLbl(info: String){
        self.AgeLabel.text = info
    }
    
    func setAgeImgView(pic: UIImage){
        AgeImageView.image = pic
    }
    
    func setGenderImgView(pic: UIImage){
        GenderImageView.image = pic
    }
    
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
}