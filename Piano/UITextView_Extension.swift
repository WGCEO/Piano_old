//
//  UITextView_Extension.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 28..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit


extension UITextView {
    func getText(from rect: CGRect) -> String {
        let range = self.layoutManager.glyphRange(forBoundingRect: rect, in: self.textContainer)
        let begin = self.beginningOfDocument
        guard let start = self.position(from: begin, offset: range.location),
            let end = self.position(from: start, offset: range.length),
            let textRange = self.textRange(from: start, to: end),
            let text = self.text(in: textRange) 
            else { return "" }
        
        return text
    }
    
    func getRect(including point: CGPoint) -> CGRect {
        let realY = point.y + self.contentOffset.y - self.textContainerInset.top
        let textViewPoint = CGPoint(x: point.x, y: realY)
        let index = self.layoutManager.glyphIndex(for: textViewPoint, in: self.textContainer)
        return self.layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: nil)
    }
}
