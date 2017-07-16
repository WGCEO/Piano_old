//
//  NSString+Kerning.swift
//  Piano
//
//  Created by dalong on 2017. 7. 16..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

fileprivate let standardCharacter = "4"

extension NSString {
    func enumerateKernings(_ font: UIFont, _ handler: ((Int, CGFloat)->Void)?) {
        let attributedText = NSMutableAttributedString(string: standardCharacter)
        attributedText.addAttributes([NSFontAttributeName : font, NSKernAttributeName: 0], range: NSMakeRange(0, 1))
        let standardWidth = attributedText.boundingRect(with: CGSize(width: 0, height: 0), options: [], context: nil).width
        
        let decimals = CharacterSet.decimalDigits
        for (index, unicode) in (self as String).unicodeScalars.enumerated() {
            let charString = String(unicode)
            if decimals.contains(unicode) {
                let attributedText = NSMutableAttributedString(string: charString)
                attributedText.addAttributes([NSFontAttributeName : font, NSKernAttributeName: 0], range: NSMakeRange(0, 1))
                let width = attributedText.boundingRect(with: CGSize(width: 0, height: 0), options: [], context: nil).width
                
                //let kerning = (standardWidth - width) / 2
                handler?(index, 0)
            } else if charString == "." {
                let attributedText = NSMutableAttributedString(string: ".")
                attributedText.addAttributes([NSFontAttributeName : font], range: NSMakeRange(0, 1))
                let kerning = attributedText.boundingRect(with: CGSize(width: 0, height: 0), options: [], context: nil).width * 0.3
                
                handler?(index, kerning)
            } else if charString == " " {
                handler?(index, 0)
            }
        }
    }
    
    func width(_ font: UIFont) -> CGFloat {
        let numberRange = NSMakeRange(0, length-2)
        let numberText = substring(with: numberRange) as NSString
        
        var width: CGFloat = 0.0
        width += numberText.kernedWidth(font)
        width += kernedDotWidth(font)
        width += kernedWhiteSpaceWidth(font)
        
        return width
    }
    
    func standardWidth(_ font: UIFont) -> CGFloat {
        let attributedText = NSMutableAttributedString(string: standardCharacter)
        attributedText.addAttributes([NSFontAttributeName : font, NSKernAttributeName: 0], range: NSMakeRange(0, 1))
        let standardWidth = attributedText.boundingRect(with: CGSize(width: 0, height: 0), options: [], context: nil).width
        
        return standardWidth
    }
    
    func kernedWidth(_ font: UIFont) -> CGFloat {
        var width: CGFloat = 0.0
        //var beforeKern: CGFloat = 0.0
        
        //let standardWidth = self.standardWidth(font)
        var attributedText: NSMutableAttributedString
        for character in (self as String).characters.reversed() {
            attributedText = NSMutableAttributedString(string: String(describing: character))
            attributedText.addAttributes([NSFontAttributeName: font, NSKernAttributeName: 0], range: NSMakeRange(0, 1))
            let charWidth = attributedText.boundingRect(with: CGSize(width: 0, height: 0), options: [], context: nil).width
            
            /*
            let diff = (standardWidth - charWidth)
            
            width += charWidth + (diff / 2) + beforeKern
            beforeKern = diff/2
             */
            width = charWidth
        }
        
        return width
    }
    
    func kernedDotWidth(_ font: UIFont) -> CGFloat {
        let attributedText = NSMutableAttributedString(string: ".")
        attributedText.addAttributes([NSFontAttributeName : font], range: NSMakeRange(0, 1))
        
        return attributedText.boundingRect(with: CGSize(width: 0, height: 0), options: [], context: nil).width * 1.3
    }
    
    func kernedWhiteSpaceWidth(_ font: UIFont) -> CGFloat {
        let attributedText = NSMutableAttributedString(string: " ")
        attributedText.addAttributes([NSFontAttributeName : font], range: NSMakeRange(0, 1))
        
        return attributedText.boundingRect(with: CGSize(width: 0, height: 0), options: [], context: nil).width * 1
    }
}