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
    
    var textEffect: TextEffectAttribute = .headline
    
    
    var waveLength: CGFloat = 70 //이거 Designable
    
    var textRect = CGRect.zero
    
    var animatingState: PianoLabelAnimation = .begin
    var animateComplete: () -> Void = {}
    
    var animationProgress: CGFloat = 0.0
    var currentFrame: Int = 0
    var totalFrames: Int = 0
    var animationDuration: CGFloat = 0.1
    
    var touchPointX: CGFloat? {
        didSet {
            guard let touchPointX = self.touchPointX else { return }
            if  touchPointX < leftEndTouchX {
                leftEndTouchX = touchPointX
            }
            setNeedsDisplay()
        }
    }
    
    fileprivate lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(
            target: self,
            selector: #selector(PianoLabel.displayFrameTick))
        displayLink.add(
            to: RunLoop.current,
            forMode: RunLoopMode.commonModes)
        return displayLink
    }()

    // Could be enhanced by kerning text:
    // http://stackoverflow.com/questions/21443625/core-text-calculate-letter-frame-in-ios
    
    override open func drawText(in rect: CGRect) {
        guard let text = self.text,
            let touchPointX = self.touchPointX else { return }
        
        let progress: CGFloat
        switch animatingState {
        case .begin:
            progress = animationProgress < 1 ? animationProgress : 1
        case .progress:
            progress = 1
        case .end:
            progress = animationProgress < 1 ? 1 - animationProgress : 0
        case .cancel:
            return
        }
        
        if progress > 1 {
            print(progress)
        }
        
        backgroundColor = UIColor.white.withAlphaComponent(0.8 * progress)
        
        //TODO: 오른쪽부터 쓰는 글씨도 해결해야함
        var leftOffset: CGFloat = textRect.origin.x
        let topOffset = textRect.origin.y   
        
        for (index, char) in text.characters.enumerated() {
            
            let s = String(char)
            let charSize = s.size(attributes: [NSFontAttributeName: self.font])
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
            
            let attribute : [String : Any]
            let font: UIFont
            switch isApplyEffect {
            case true:
                attribute = setAttribute(effect: textEffect)
                font = attribute[NSFontAttributeName] as! UIFont
            case false where isSelectedCharacter:
                attribute = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .title1)]
                font = attribute[NSFontAttributeName] as! UIFont
            default:
                attribute = setAttribute(effect: .normal)
                font = attribute[NSFontAttributeName] as! UIFont
            }
            
            
            //효과 입히기
            if x > -waveLength && x < waveLength {
                
                
            
                let size = s.size(attributes: [NSFontAttributeName: font])
                let x = rect.origin.x
                let y = rect.origin.y - (isSelectedCharacter ? 
                    (y + size.height / 2) * progress  : 
                    y * progress)
                let point = CGPoint(x: x, y: y)
                let rect = CGRect(origin: point, size: size)
                
                s.draw(in: rect, withAttributes: attribute)
            } else {
                
                s.draw(in: rect, withAttributes: attribute)
            }
            leftOffset += charSize.width
        }
    }
    
    func setAttribute(effect: TextEffectAttribute) -> [String : Any] {
        let attribute: [String : Any]
        switch effect {
        case .normal:
            attribute = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body)]
        case .headline:
            attribute = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .headline)]
        case .red:
            attribute = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body),
                         NSForegroundColorAttributeName : UIColor.red]
        case .green:
            attribute = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body),
                         NSForegroundColorAttributeName : UIColor.green]
        case .strike:
            attribute = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body),
                         NSStrikethroughStyleAttributeName : 1]
        case .underline:
            attribute = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body),
                         NSUnderlineStyleAttributeName : 1]
        }
        return attribute
    }
    
    
    
}

extension PianoLabel {
    func displayFrameTick() {
        if displayLink.duration > 0.0 && totalFrames == 0 {
            let frameRate = CGFloat(displayLink.duration)
            totalFrames = Int(ceil(animationDuration / frameRate))
        }
        
        currentFrame += 1
        
        //5 더한 것 때문에 다른 디바이스에서 문제 없는 지 체크해야함..
        if currentFrame < totalFrames + 5 {
        
            animationProgress += 1.0 / CGFloat(totalFrames)
            setNeedsDisplay()
        } else {
            displayLink.isPaused = true
            animationProgress = 0.0
            currentFrame = 0
            totalFrames = 0
            
            switch animatingState {
            case .end:
                isHidden = true
                animateComplete()
                applyEffectIndexSet.removeAll()
                leftEndTouchX = CGFloat.greatestFiniteMagnitude
            case .cancel:
                isHidden = true
                applyEffectIndexSet.removeAll()
                animateComplete()
                leftEndTouchX = CGFloat.greatestFiniteMagnitude
            default:
                ()
            }
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
    
    func isVisible(_ bool: Bool) {
        self.isHidden = !bool
    }
    
    func getIndexes() -> [Int] {
        return applyEffectIndexSet.sorted()
    }
    
    func beginAnimating(at x: CGFloat) {
        isHidden = false
        animatingState = .begin
        displayLink.isPaused = false
        touchPointX = x
    }
    
    func finishAnimating(at x: CGFloat, completion: @escaping () -> Void) {
        animatingState = .end
        displayLink.isPaused = false
        touchPointX = x
        animateComplete = completion

    }
    
    func cancelAnimating(completion: @escaping () -> Void) {
        animatingState = .cancel
        displayLink.isPaused = false
        animateComplete = completion
    }
    
    func progressAnimating(at x: CGFloat) {
        guard displayLink.isPaused else { return }
        displayLink.isPaused = true
        animatingState = .progress
        touchPointX = x
    }
    
    func set(effect: TextEffectAttribute) {
        textEffect = effect
    }

}
