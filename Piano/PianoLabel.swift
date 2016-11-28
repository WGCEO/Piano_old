//
//  PianoLabel.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 27..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class PianoLabel: UILabel {
    
    var actualRect = CGRect.zero
    
    var isAnimating: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var touchPointX: CGFloat? {
        didSet {
            setNeedsDisplay()
        }
    }

    
    // Could be enhanced by kerning text:
    // http://stackoverflow.com/questions/21443625/core-text-calculate-letter-frame-in-ios
    
    override open func drawText(in rect: CGRect) {
        guard let text = self.text,
            let touchPointX = self.touchPointX else { return }
        
        //오른쪽부터 쓰는 글씨도 해결해야함
        var leftOffset: CGFloat = actualRect.origin.x
        let topOffset = actualRect.origin.y   //(bounds.size.height - charHeight) / 2.0 +
        for char in text.characters {
            let charSize = String(char).size(attributes: [NSFontAttributeName: font])
            var rect = CGRect(origin: CGPoint(x: leftOffset, y: topOffset)
                , size: charSize)
            

            let s = String(char)
            let charCenter = leftOffset + charSize.width / 2
            
            if abs(Int32(touchPointX - charCenter)) < 60 {
                rect.origin.y -= CGFloat(60 - abs(Int32(touchPointX - charCenter)))
            } 
            
            s.draw(in: rect, withAttributes: [
                NSFontAttributeName:
                    UIFont.systemFont(ofSize: 17),
                NSForegroundColorAttributeName:
                    textColor.withAlphaComponent(1),
                //NSBackgroundColorAttributeName: UIColor.blue
                ])
            
            leftOffset += charSize.width
        }
        
    }

}
