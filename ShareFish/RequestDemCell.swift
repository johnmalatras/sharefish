//
//  RequestDemCell.swift
//  ShareFish
//
//  Created by John Malatras on 6/28/16.
//  Copyright © 2016 ShareFish LLC. All rights reserved.
//

import Foundation

class RequestDemCell : UITableViewCell {
    var tapAction: ((UITableViewCell) -> Void)?
    
    @IBAction func RequestClick(sender: AnyObject) {
        tapAction?(self)
    }
    
    
}
