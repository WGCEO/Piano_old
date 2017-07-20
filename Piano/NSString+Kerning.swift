//
//  NSString+Kerning.swift
//  Piano
//
//  Created by dalong on 2017. 7. 16..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

fileprivate let standardCharacter: NSString = "4"

extension NSString {
    func kerningOfDot(_ font: UIFont) -> CGFloat {
        let width = dotWidth(font)
        
        return width * 0.3
    }
    
    func boundingWidth(with type: ElementType, font: UIFont) -> CGFloat {
        var width = whiteSpaceWidth(font)
        width += dotWidth(font) * 1.3
        
        if type == .number {
            let numberRange = NSMakeRange(0, length-2)
            let numberText = substring(with: numberRange) as NSString
            
            width += numberText.stringWidth(font)
        } else if type == .list || type == .checkbox {
            width += standardCharacter.characterWidth(font)
        }
        
        return width
    }
    
    func stringWidth(_ font: UIFont) -> CGFloat {
        var width: CGFloat = 0.0
        for character in (self as String).characters.reversed() {
            let charWidth = (String(character) as NSString).boundingRect(with: CGSize(), options: [], attributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.kern: 0], context: nil).width
            
            width += charWidth
        }
        
        return width
    }
    
    func characterWidth(_ font: UIFont) -> CGFloat {
        return boundingRect(with: CGSize(), options: [], attributes: [NSAttributedStringKey.font : font], context: nil).width
    }
    
    func dotWidth(_ font: UIFont) -> CGFloat {
        let width = ("." as NSString).boundingRect(with: CGSize(), options: [], attributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.kern: 0], context: nil).width
        
        return width
    }
    
    func whiteSpaceWidth(_ font: UIFont) -> CGFloat {
        let width = (" " as NSString).boundingRect(with: CGSize(), options: [], attributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.kern: 0], context: nil).width
        
        return width
    }
}
