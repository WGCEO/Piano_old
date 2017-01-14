//
//  GroupCell.swift
//  Piano
//
//  Created by kevin on 2017. 1. 12..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell, Reusable {

    @IBOutlet weak var ibImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        ibImageView.alpha = selected ? 1 : 0.1
    }

}
