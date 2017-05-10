//
//  MerchantSpecialCell.swift
//  ShareFish
//
//  Created by John Malatras on 3/26/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation

class MerchantSpecialCell: UITableViewCell {
    
    @IBOutlet weak var specialTitle: UILabel!
    @IBOutlet weak var Price: UILabel!
    
    func setSpecialName(specialName: String) {
        self.specialTitle.text = specialName
    }
    
    func setPriceCost(priceString: String) {
        self.Price.text = priceString
    }
    
}