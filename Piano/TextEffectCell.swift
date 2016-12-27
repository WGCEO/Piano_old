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
    var textEffect: TextEffect = .color(.red)
    
//    override var isSelected: Bool {
//        didSet {
//            awesomeLabel.textColor = isSelected ? #colorLiteral(red: 0.8913504464, green: 0.1568627506, blue: 0.2921995391, alpha: 1) : #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
//        }
//    }
}
