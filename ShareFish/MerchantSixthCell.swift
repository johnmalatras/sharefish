//
//  MerchantSixthCell.swift
//  ShareFish
//
//  Created by John Malatras on 5/17/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation
import ParseUI

class MerchantSixthCell : UITableViewCell{
    
    @IBOutlet weak var RatingImageView: UIImageView!
    
    func setRatingView(image: UIImage){
        self.RatingImageView.image = image
        self.RatingImageView.sizeToFit()
    }
}