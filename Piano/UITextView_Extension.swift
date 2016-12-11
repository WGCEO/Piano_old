//
//  UITextView_Extension.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 28..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit


extension UITextView {
    func getTextAndRange(from rect: CGRect) -> (String, NSRange) {
        let range = self.layoutManager.glyphRange(forBoundingRect: rect, in: self.textContainer)
        let begin = self.beginningOfDocument
        guard let start = self.position(from: begin, offset: range.location),
            let end = self.position(from: start, offset: range.length),
            let textRange = self.textRange(from: start, to: end),
            let text = self.text(in: textRange) 
            else { return ("", range) }
        return (text, range)
    }
    
    func getRect(including point: CGPoint) -> CGRect {
        let index = self.layoutManager.glyphIndex(for: point, in: self.textContainer)
        return self.layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: nil)
    }
    
    func getRange(begin: CGPoint, end: CGPoint) -> NSRange {
        let beginY = begin.y + self.contentOffset.y - self.textContainerInset.top
        let endY = end.y + self.contentOffset.y - self.textContainerInset.top
        let textViewTouchBeginPoint = CGPoint(x: begin.x, y: beginY)
        let textViewTouchEndPoint = CGPoint(x: end.x, y: endY)
        let beginIndex = self.layoutManager.glyphIndex(for: textViewTouchBeginPoint, in: self.textContainer)
        let endIndex = self.layoutManager.glyphIndex(for: textViewTouchEndPoint, in: self.textContainer)
        
        return NSRange(location: beginIndex, length: endIndex - beginIndex)
        
    }
    
    
}
