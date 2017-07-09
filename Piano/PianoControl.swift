//
//  PianoControl.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 25..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

protocol Pianoable: class {
    func preparePiano(in rect: CGRect, with attributedString: NSAttributedString, standard: CGPoint)
    func showPiano(with textEffect: TextEffect, to point: CGPoint)
    func hidePiano()
}

class PianoControl: UIControl {

    weak var pianoable: Pianoable?
    weak var textView: PianoTextView!
    
    var textEffect: TextEffect = .color(.red)
    var startPoint: CGPoint = CGPoint.zero
    
    // MARK: override methods
    internal override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        //1. 텍스트 뷰의 좌표로 점 평행이동(여기선 수직 오프셋값 - 텍스트 마진)
        let point = touch.location(in: self).move(x: 0, y: textView.contentOffset.y - textView.textContainerInset.top)
        
        //2. 가리키고 있는 줄에 있는 attributedText 얻어오기
        let rect = textView.getRect(including: point)
        let attributedText = textView.getAttributedString(in: rect)
        guard attributedText.string.isNotEmptyOrWhitespace else { return false }
        
        //3. attributedText의 rect 얻어오기
        let shiftX = textView.textContainer.lineFragmentPadding + textView.textContainerInset.left
        let shiftY = textView.textContainerInset.top - textView.contentOffset.y
        let newRect = rect.offsetBy(dx: shiftX, dy: shiftY)

        //4. 얻은 정보들을 가지고 Piano 효과를 준비한다.
        textView.cover(rect)
        pianoable?.preparePiano(in: newRect, with: textView.attributedText, standard: point)
        
        return true
    }
    
    internal override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        pianoable?.showPiano(with: textEffect, to: touch.location(in: self))

        return true
    }
    
    internal override func cancelTracking(with event: UIEvent?) {
        finishPiano()
    }
    
    internal override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        finishPiano()
        
        if let endPoint = touch?.location(in: self) {
            applyTextEffect(from: startPoint, to: endPoint)
        }
    }
    
    // MARK: - private methods
    private func finishPiano() {
        pianoable?.hidePiano()
        textView.uncover()
    }
    
    private func applyTextEffect(from: CGPoint, to: CGPoint) {
        
    }
    
    private func setAttribute(effect:TextEffect, range: NSRange) {
        var attribute: [String : Any] = [:]
        switch effect {
        case .color(let x):
            attribute = [NSForegroundColorAttributeName : x]
        case .title(let x):
            let size = UIFont.preferredFont(forTextStyle: x).pointSize
            attribute = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: size)]
        case .line(.underline):
            attribute = [NSUnderlineStyleAttributeName : 1]
        case .line(.strikethrough):
            attribute = [NSStrikethroughStyleAttributeName : 1]
        case .bold:
            for index in range.location...(range.location+range.length) {
                let attributes = textView.layoutManager.textStorage?.attributes(at: index, effectiveRange: nil)
                if let font = attributes?[NSFontAttributeName] as? UIFont {
                    let attribute = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: font.pointSize)]
                    textView.layoutManager.textStorage?.addAttributes(attribute, range: NSMakeRange(index, 1))
                }
            }
        }
        
        textView.layoutManager.textStorage?.addAttributes(attribute, range: range)
    }
    
    private func removeAttribute(effect: TextEffect, range: NSRange) {
        var attribute: [String : Any] = [:]
        switch effect {
        case .color:
            attribute = [NSForegroundColorAttributeName : UIColor.piano]
        case .title:
            attribute = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body)]
        case .line(.strikethrough):
            attribute = [NSStrikethroughStyleAttributeName : 0]
        case .line(.underline):
            attribute = [NSUnderlineStyleAttributeName : 0]
        case .bold:
            for index in range.location...(range.location+range.length) {
                let attributes = textView.layoutManager.textStorage?.attributes(at: index, effectiveRange: nil)
                if let font = attributes?[NSFontAttributeName] as? UIFont {
                    let attribute = [NSFontAttributeName : UIFont.systemFont(ofSize: font.pointSize)]
                    textView.layoutManager.textStorage?.addAttributes(attribute, range: NSMakeRange(index, 1))
                }
            }
        }
        
        textView.layoutManager.textStorage?.addAttributes(attribute, range: range)
    }
}

extension PianoControl: Effectable {
    func setEffect(textEffect: TextEffect){
        self.textEffect = textEffect
    }
}
