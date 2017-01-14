//
//  DeletedMemoCell.swift
//  Piano
//
//  Created by kevin on 2017. 1. 14..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class DeletedMemoCell: UITableViewCell {

    @IBOutlet weak var ibImageView: UIImageView!
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibSubtitleLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
