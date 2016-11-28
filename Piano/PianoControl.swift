//
//  PianoControl.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 25..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class PianoControl: UIControl {

    @IBOutlet weak var label: PianoLabel!
    @IBOutlet weak var curtainView: UIView!

    weak var textView: PianoTextView?
    
    
    //TODO: super 메서드 호출해도 되는 것인지.    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        guard let textView = self.textView else { return true }
        
        label.isHidden = false
        curtainView.isHidden = false
        
        
        let point = touch.location(in: self)
        
        let realY = point.y + textView.contentOffset.y - textView.textContainerInset.top
        let textViewPoint = CGPoint(x: point.x, y: realY)
        let manager = textView.layoutManager
        let container = textView.textContainer
        let index = manager.glyphIndex(for: textViewPoint, in: container)
        var rect = manager.lineFragmentRect(forGlyphAt: index, effectiveRange: nil)
        let range = manager.glyphRange(forBoundingRect: rect, in: container)

        //ContainerViewHeight = 100
        rect.origin.y = rect.origin.y + textView.textContainerInset.top - textView.contentOffset.y + 100
        rect.origin.x += (textView.textContainer.lineFragmentPadding + textView.textContainerInset.left)
        //label.bounds = rect  todo: 여기에 새로운 뷰 만들어서 뒤 레이블 가려야함

        
        label.actualRect = rect
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        rect.origin.y += statusBarHeight
        curtainView.frame = rect
        
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
        label.touchPointX = touch.location(in: self).x
        return true
    }
    
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        
        label.isHidden = true
        curtainView.isHidden = true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        label.isHidden = true
        curtainView.isHidden = true
    }
}
