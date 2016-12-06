//
//  TextEffectCell.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class TextEffectCell: UICollectionViewCell, Reusable {
    
    @IBOutlet weak var imageView: UIImageView!
    var textEffect: TextEffectAttribute = .headline
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}
