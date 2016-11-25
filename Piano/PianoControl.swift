//
//  PianoControl.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 25..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class PianoControl: UIControl {

    @IBOutlet weak var label: UILabel!
    weak var textView: PianoTextView?
    
    
    //TODO: super 메서드 호출해도 되는 것인지.    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        guard let textView = self.textView else { return true }
        let point = touch.location(in: self)
        let realY = point.y + textView.contentOffset.y - textView.textContainerInset.top
        let textViewPoint = CGPoint(x: point.x, y: realY)
        let manager = textView.layoutManager
        let container = textView.textContainer
        let index = manager.glyphIndex(for: textViewPoint, in: container)
        var rect = manager.lineFragmentRect(forGlyphAt: index, effectiveRange: nil)
        let range = manager.glyphRange(forBoundingRect: rect, in: container)
        
        //TODO1: -1 과 5에 대해 해결하기 -> lineFragmentPadding = 5임. TODO2: 이 함수 리펙토링(효율적인 방법 있을 듯)
        rect.origin.y = rect.origin.y + textView.textContainerInset.top - textView.contentOffset.y - 4
        rect.origin.x += 5
        label.frame = rect
        
        let begin = textView.beginningOfDocument
        guard let start = textView.position(from: begin, offset: range.location),
            let end = textView.position(from: start, offset: range.length),
            let textRange = textView.textRange(from: start, to: end) else {
                return true
        }
        
        label.text = textView.text(in: textRange)
        
        
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        
        return true
    }
    
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
    }
}
