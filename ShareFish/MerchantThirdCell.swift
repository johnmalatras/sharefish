//
//  MerchantThirdCell.swift
//  ShareFish
//
//  Created by John Malatras on 3/28/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation

class MerchantThirdCell : UITableViewCell{
    
    @IBOutlet weak var HoursLabel: UILabel!
    @IBOutlet weak var NotesLabel: UILabel!
    
    func setHoursLbl(hours: String){
        self.HoursLabel.text = hours
    }
    
    func setNotesLbl(notes: String){
        self.NotesLabel.text = "Events: " + notes
    }
}