//
//  SpecialsCell.swift
//  ShareFish
//
//  Created by John Malatras on 2/5/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation


class SpecialsCell: UITableViewCell {
    
    @IBOutlet weak var barTitle: UILabel!
    @IBOutlet weak var specialTitle: UILabel!
    @IBOutlet weak var Price: UILabel!
    @IBOutlet weak var Emoji: UILabel!

    
    func setBarName(barName: String) {
        self.barTitle.text = barName
    }
    
    func setSpecialName(specialName: String) {
        self.specialTitle.text = specialName
    }
    
    func setPriceCost(priceString: String) {
        self.Price.text = priceString
    }
    
    func setEmojiText(EmojiCode: Int) {
        if(EmojiCode == 0) {
            Emoji.text = "🍻"
        }
        else if (EmojiCode == 1) {
            Emoji.text = "🍷"
        }
        else if (EmojiCode == 2) {
            Emoji.text = "🍸"
        }
        else {
            Emoji.text = "❌"
        }
    }
    
}