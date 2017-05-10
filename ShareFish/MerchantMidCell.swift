//
//  MerchantMidCell.swift
//  ShareFish
//
//  Created by John Malatras on 2/21/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation
import ParseUI

class MerchantMidCell : UITableViewCell{
    
    @IBOutlet weak var AddressLabel: UIButton!
    @IBOutlet weak var PhoneLabel: UIButton!
    @IBOutlet weak var WebsiteLabel: UIButton!
    @IBOutlet weak var UberButton: UIButton!
    
    
    func setAddressLbl(address: String){
        self.AddressLabel.setTitle(address, forState: .Normal)
    }
    
    func setPhoneLbl(phonenum: String){
        self.PhoneLabel.setTitle(phonenum, forState: .Normal)
    }
    
    func setWebsiteLbl(website: String){
        self.WebsiteLabel.setTitle(website, forState: .Normal)
    }
}
