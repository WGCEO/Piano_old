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
    var rightEndTouchX: CGFloat = 0
    var applyEffectIndexSet: Set<Int> = []
    var removeEffectIndexSet: Set<Int> = []

    var textEffect: TextEffect = .color(.red)
    var attributes: [[String : Any]] = []
    
    var cosQuarterPeriod: CGFloat = 70 //이거 Designable
    var cosMaxHeight: CGFloat = 60  //이것도 Designable
    
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
            
            if touchPointX > rightEndTouchX {
                rightEndTouchX = touchPointX
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        backgroundColor = UIColor.white.withAlphaComponent(0.8 * progress)
        
        //TODO: 오른쪽부터 쓰는 글씨도 해결해야함
        var leftOffset: CGFloat = textRect.origin.x
        let topOffset = textRect.origin.y
        
        for (index, char) in text.characters.enumerated() {
            
            let s = String(char)
            var attribute = attributes[index]
            var charSize: CGSize
            if (s == "\t") {
                let size = s.size(attributes: attribute)
                charSize = CGSize(width: getTabLength(of: index, from: text), height: size.height)
                print( getTabLength(of: index, from: text))
            } else {
                charSize = s.size(attributes: attribute)
            }
            
            let rect = CGRect(origin: CGPoint(x: leftOffset, y: topOffset)
                , size: charSize)
            
            let charCenter = leftOffset + charSize.width / 2
            let distance = touchPointX - charCenter
            
            let y = cosMaxHeight * cos(CGFloat.pi / (2 * cosQuarterPeriod) * distance)
            
            //가장 왼쪽의 터치가 단어의 오른쪽 끝보다 왼쪽에 있어야 하고, 현재 터치포인트가 단어의 오른쪽 끝보다 크면 효과 적용
            let isApplyEffect = leftOffset + charSize.width > leftEndTouchX
                && touchPointX > leftOffset + charSize.width
            
            // 가장 오른쪽의 터치가 단어의 왼쪽 끝보다 오른쪽에 있어야 하고, 현재 터치 포인트가 단어의 왼쪽 끝보다 작으면 효과 제거
            let isRemoveEffect = leftOffset > touchPointX && leftOffset < rightEndTouchX
            
            if isRemoveEffect {
                removeEffectIndexSet.insert(index)
                
                let newAttr = makeAttribute(by: textEffect)
                
                if let _ = newAttr[NSFontAttributeName] {
                    attribute[NSFontAttributeName] = UIFont.preferredFont(forTextStyle: .body)
                }
                
                if let _ = newAttr[NSForegroundColorAttributeName] {
                    attribute[NSForegroundColorAttributeName] = UIColor.piano
                }
                
                if let _ = newAttr[NSStrikethroughStyleAttributeName] {
                    attribute[NSStrikethroughStyleAttributeName] = 0
                }
                
                if let _ = newAttr[NSUnderlineStyleAttributeName] {
                    attribute[NSUnderlineStyleAttributeName] = 0
                }
                
            } else {
                removeEffectIndexSet.remove(index)
            }
            
            if isApplyEffect {
                applyEffectIndexSet.insert(index)
                
                let newAttr = makeAttribute(by: textEffect)
                
                if let font = newAttr[NSFontAttributeName] {
                    attribute[NSFontAttributeName] = font
                }
                
                if let color = newAttr[NSForegroundColorAttributeName] {
                    attribute[NSForegroundColorAttributeName] = color
                }
                
                if let strike = newAttr[NSStrikethroughStyleAttributeName] {
                    attribute[NSStrikethroughStyleAttributeName] = strike
                }
                
                if let underline = newAttr[NSUnderlineStyleAttributeName] {
                    attribute[NSUnderlineStyleAttributeName] = underline
                }
            } else {
                applyEffectIndexSet.remove(index)
            }
            

            
            //피아노 효과 입히기
            if distance > -cosQuarterPeriod && distance < cosQuarterPeriod {
            
                let isSelectedCharacter = touchPointX > leftOffset && touchPointX < charSize.width + leftOffset
                let x = rect.origin.x
                let y = rect.origin.y - y * progress
                let point = CGPoint(x: x, y: y)
                
                if isSelectedCharacter {
                    let font = attribute[NSFontAttributeName] as! UIFont
                    attribute[NSFontAttributeName] = UIFont.boldSystemFont(ofSize: font.pointSize)
                    
                }
                
                s.draw(at: point, withAttributes: attribute)
            } else {
                let point = CGPoint(x: rect.origin.x, y: rect.origin.y)
                s.draw(at: point, withAttributes: attribute)
            }
            leftOffset += charSize.width
        }
    }
    
    func makeAttribute(by effect: TextEffect) -> [String : Any] {
        let attribute: [String : Any]
        
        switch effect {
        case .color(let x):
            attribute = [NSForegroundColorAttributeName : x]
        case .title(let x):
            let size = UIFont.preferredFont(forTextStyle: x).pointSize
            attribute = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: size)]
        case .line(.strikethrough):
            attribute = [NSStrikethroughStyleAttributeName : 1]
        case .line(.underline):
            attribute = [NSUnderlineStyleAttributeName : 1]
        }
        return attribute
    }
    
    private func getTabLength(of tabIndex: Int, from text: String) -> CGFloat {
        var length: CGFloat = 0
        for (index, char) in text.characters.enumerated() {
            let standard = "\t".size(attributes: attributes[tabIndex]).width
            let s = String(char)
            if tabIndex == index && s == "\t" {
                return standard-(length-(standard*CGFloat(Int(length/standard))))
            }
            
            if (s == "\t") {
                length += getTabLength(of: index, from: text)
            } else {
                length += s.size(attributes: attributes[index]).width
            }
        }
        
        return 0
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
                removeEffectIndexSet.removeAll()
                leftEndTouchX = CGFloat.greatestFiniteMagnitude
                rightEndTouchX = 0
            case .cancel:
                isHidden = true
                applyEffectIndexSet.removeAll()
                removeEffectIndexSet.removeAll()
                animateComplete()
                leftEndTouchX = CGFloat.greatestFiniteMagnitude
                rightEndTouchX = 0
            default:
                ()
            }
        }
    }
}

extension PianoLabel: Pianoable {
    
    func attributesForText(_ attributes: [[String : Any]]) {
        self.attributes = attributes
    }
    func textFromTextView(text: String) {
        self.text = text
    }
    
    func rectForText(_ rect: CGRect) {
        textRect = rect
    }
    
    func isVisible(_ bool: Bool) {
        self.isHidden = !bool
    }
    
    func getIndexesForAdd() -> [Int] {
        return applyEffectIndexSet.sorted()
    }
    
    func getIndexesForRemove() -> [Int] {
        return removeEffectIndexSet.sorted()
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
    
    //곧바로 움직인다면 디스플레이링크를 멈추고 프로그레스로 넘어가야함
    func ismoveDirectly(bool: Bool) {
        guard animatingState != .progress else { return }

        animatingState = bool ? .progress : .begin
        displayLink.isPaused = bool
        
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
    
    func set(effect: TextEffect) {
        textEffect = effect
    }
}
