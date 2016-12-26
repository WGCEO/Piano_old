//
//  TextEffectCell.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class TextEffectCell: UICollectionViewCell, Reusable {
    
    
    @IBOutlet weak var awesomeLabel: UILabel!
    var textEffect: TextEffectAttribute = .red
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}
