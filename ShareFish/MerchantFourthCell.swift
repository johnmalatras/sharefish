//
//  MerchantFourthCell.swift
//  ShareFish
//
//  Created by John Malatras on 3/28/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation
import ParseUI

class MerchantFourthCell : UITableViewCell{
    
    @IBOutlet weak var GenderRatioImgView: UIImageView!
    
    func setGenderView(image: UIImage){
        self.GenderRatioImgView.image = image
        self.GenderRatioImgView.sizeToFit()
    }
}
