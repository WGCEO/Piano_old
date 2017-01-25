//
//  MemoCell.swift
//  Piano
//
//  Created by kevin on 2017. 1. 23..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class MemoCell: UITableViewCell, Reusable {

    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibSubTitleLabel: UILabel!
    @IBOutlet weak var ibImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        ibTitleLabel.textColor = selected ? .white : .black
        ibSubTitleLabel.textColor = selected ? .white : .lightGray
        contentView.backgroundColor = selected ? .black : .white
    }

}
