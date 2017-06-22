//
//  UIColor_Extension.swift
//  Piano
//
//  Created by kevin on 2017. 2. 1..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit


extension UIColor {
    open class var piano: UIColor {
        return UIColor(colorLiteralRed: 30/255, green: 30/255, blue: 30/255, alpha: 1)
    }
}

class PianoColor {
    
    open class var lightGray: UIColor {
        return UIColor(colorLiteralRed: 247/255, green: 247/255, blue: 247/255, alpha: 1)
    }
    
    open class var darkGray: UIColor {
        return UIColor(colorLiteralRed: 0x4C/255, green: 0x4C/255, blue: 0x4C/255, alpha: 1)
    }
    
    open class var red: UIColor {
        return UIColor(colorLiteralRed: 0xFF/255, green: 0/255, blue: 0/255, alpha: 1)
    }
}
