//
//  MerchantFifthCell.swift
//  ShareFish
//
//  Created by John Malatras on 3/28/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation

class MerchantFifthCell : UITableViewCell{
    @IBOutlet weak var AgeLabel: UILabel!
    @IBOutlet weak var SingleLabel: UILabel!
    @IBOutlet weak var AgePic: UIImageView!
    
    func setAgeLbl(age : String){
        self.AgeLabel.text = age
    }
    
    func setSingleLbl(singlePercent : Int){
        self.SingleLabel.text = "\(singlePercent)% Singles"
    }
    
    func setAgeImage(pic: UIImage){
        self.AgePic.image = pic
    }
}
