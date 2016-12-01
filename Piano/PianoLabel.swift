//
//  PianoLabel.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 27..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class PianoLabel: UILabel {
    
    var waveLength: CGFloat = 60
    
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
        
        //TODO: 오른쪽부터 쓰는 글씨도 해결해야함
        var leftOffset: CGFloat = actualRect.origin.x
        let topOffset = actualRect.origin.y   
        
        for char in text.characters {
            
            let s = String(char)
            let charSize = s.size(attributes: [NSFontAttributeName: font])
            var rect = CGRect(origin: CGPoint(x: leftOffset, y: topOffset)
                , size: charSize)
            
            let charCenter = leftOffset + charSize.width / 2
            
            //2차 함수
            let distance = touchPointX - charCenter
            let x = distance < 0 ? -distance : distance
            // y = - 2.5x^2 + C
            let leftLamda = (x + waveLength) / waveLength
            let rightLamda = (x - waveLength) / waveLength
            
            // 4차식
            let y = leftLamda * leftLamda * rightLamda * rightLamda * waveLength
            
            if x > -waveLength && x < waveLength {

                let textAlpha: CGFloat = x < charSize.width/2 ? 1 : 0.4
                

                // 20(더할 수 있는 최대값) / 10000(y의 최대값) = 500
                //let fontSize: CGFloat = y < 17 ? 17 : 17 + y/500
//                let fontSize: CGFloat = x < charSize.width/2 ? 37 : 17
                let fontStyle: UIFontTextStyle = x < charSize.width/2 ? .title1 : .body

                let font = UIFont.preferredFont(forTextStyle: fontStyle)
                let size = s.size(attributes: [NSFontAttributeName: font])
                rect.origin.y -= x < charSize.width/2 ? (y + size.height)  : y
                rect.size = size
                s.draw(in: rect, withAttributes: [
                    NSFontAttributeName:
                        font,
                    NSForegroundColorAttributeName:
                        textColor.withAlphaComponent(textAlpha),
                    //NSBackgroundColorAttributeName: UIColor.blue
                    ])

            } else {
                
                s.draw(in: rect, withAttributes: [
                    NSFontAttributeName:
                        UIFont.preferredFont(forTextStyle: .body),
                    NSForegroundColorAttributeName:
                        textColor.withAlphaComponent(1),
                    //NSBackgroundColorAttributeName: UIColor.blue
                    ])
            }
            
            
            
            leftOffset += charSize.width
        }
        
    }

}
