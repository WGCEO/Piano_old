//
//  PianoLabel.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 27..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class PianoLabel: UILabel {
    
    
    var leftEndTouchX: CGFloat = CGFloat.greatestFiniteMagnitude 
    var applyEffectIndexSet: Set<Int> = []
    
    
    var waveLength: CGFloat = 60 //이거 Designable
    
    var textRect = CGRect.zero
    
    var isAnimating: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var touchPointX: CGFloat? {
        didSet {
            
            guard let touchPointX = self.touchPointX else { return }
            if  touchPointX < leftEndTouchX {
                leftEndTouchX = touchPointX
            }
            
            setNeedsDisplay()
        }
    }

    // Could be enhanced by kerning text:
    // http://stackoverflow.com/questions/21443625/core-text-calculate-letter-frame-in-ios
    
    override open func drawText(in rect: CGRect) {
        guard let text = self.text,
            let touchPointX = self.touchPointX else { return }
        
        //TODO: 오른쪽부터 쓰는 글씨도 해결해야함
        var leftOffset: CGFloat = textRect.origin.x
        let topOffset = textRect.origin.y   
        
        for (index, char) in text.characters.enumerated() {
            
            let s = String(char)
            let charSize = s.size(attributes: [NSFontAttributeName: font])
            let rect = CGRect(origin: CGPoint(x: leftOffset, y: topOffset)
                , size: charSize)
            
            
            let charCenter = leftOffset + charSize.width / 2
            let distance = touchPointX - charCenter
            let x = distance < 0 ? -distance : distance
            let leftLamda = (x + waveLength) / waveLength
            let rightLamda = (x - waveLength) / waveLength
            
            // 4차식
            let y = leftLamda * leftLamda * rightLamda * rightLamda * waveLength
            

            let isSelectedCharacter = touchPointX - leftOffset > 0 && 
                touchPointX - leftOffset < charSize.width
            let isApplyEffect = leftOffset + charSize.width > leftEndTouchX &&
                touchPointX - leftOffset > 0 &&
                !isSelectedCharacter ? true : false
            
            if isApplyEffect {
                applyEffectIndexSet.insert(index)
            } else {
                applyEffectIndexSet.remove(index)
            }
            
            
            
            //효과 입히기
            if x > -waveLength && x < waveLength {
                
                let textAlpha: CGFloat = 1//isSelectedCharacter ? 1 : 0.4
                let fontStyle: UIFontTextStyle = isSelectedCharacter ? .title1 : .body

                let font = UIFont.preferredFont(forTextStyle: fontStyle)
                let size = s.size(attributes: [NSFontAttributeName: font])
                let x = rect.origin.x
                let y = rect.origin.y - (isSelectedCharacter ? (y + size.height)  : y)
                let point = CGPoint(x: x, y: y)
                let rect = CGRect(origin: point, size: size)
                
                s.draw(in: rect, withAttributes: [
                    NSFontAttributeName: font,
                    NSForegroundColorAttributeName: textColor.withAlphaComponent(textAlpha),
                    NSBackgroundColorAttributeName: isApplyEffect ? Constant.yellowEffectColor : UIColor.clear
                    ])

            } else {
                
                s.draw(in: rect, withAttributes: [
                    NSFontAttributeName:
                        UIFont.preferredFont(forTextStyle: .body),
                    NSForegroundColorAttributeName:
                        textColor.withAlphaComponent(1),
                    NSBackgroundColorAttributeName: isApplyEffect ? Constant.yellowEffectColor : UIColor.clear
                    ])
            }
            
            leftOffset += charSize.width
        }
        
    }
}


extension PianoLabel: PianoControlDelegate {
    func textFromTextView(text: String) {
        self.text = text
    }
    
    func rectForText(_ rect: CGRect) {
        textRect = rect
    }
    
    func xPointFromTouch(_ x: CGFloat) {
        touchPointX = x
    }
    
    func isVisible(_ bool: Bool) {
        self.isHidden = !bool
    }
    
    func resetLeftEnd(value: CGFloat) {
        leftEndTouchX = value
    }
    
    func getIndexes() -> [Int] {
        return applyEffectIndexSet.sorted()
    }
    
    func setIndexes(_ indexes: Set<Int>?) {
        guard let indexes = indexes else { 
            applyEffectIndexSet.removeAll()
            return
        }
        
        applyEffectIndexSet = indexes
    }
}
