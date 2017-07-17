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
    
    //이놈 시키기 문제인듯 방법: apply와 remove를 위한 range를 따로 만들자!!
    func getRangeForApply(farLeft: CGPoint, final: CGPoint) -> NSRange {
        let beginIndex = self.layoutManager.glyphIndex(for: farLeft, in: self.textContainer)
        let endIndex = self.layoutManager.glyphIndex(for: final, in: self.textContainer)
        let endFrame = self.layoutManager.boundingRect(forGlyphRange: NSMakeRange(endIndex, 1), in: self.textContainer)
        
        let length = endFrame.origin.x + endFrame.size.width < final.x ? endIndex - beginIndex + 1 : endIndex - beginIndex
        
        return NSRange(location: beginIndex, length: length)
    }
    
    func getRangeForRemove(final: CGPoint, farRight: CGPoint) -> NSRange {
        let beginIndex = self.layoutManager.glyphIndex(for: final, in: self.textContainer)
        let endIndex = self.layoutManager.glyphIndex(for: farRight, in: self.textContainer)
        let beginFrame = self.layoutManager.boundingRect(forGlyphRange: NSMakeRange(beginIndex, 1), in: self.textContainer)
        let location = beginFrame.origin.x > final.x ? beginIndex : beginIndex + 1
        let length = beginFrame.origin.x > final.x ? endIndex - beginIndex + 1 : endIndex - beginIndex
        return NSRange(location: location, length: length)
        
    }
    
    func getParagraphInfo(with range: NSRange) -> (range: NSRange, textRange: UITextRange, text: String)?{
        guard !(range.location + range.length > self.text.characters.count) else {
            return nil
        }
        let paragraphRange = (self.text as NSString).paragraphRange(for: range)
        guard let paragraphTextRange = paragraphRange.toTextRange(textInput: self),
            let paragraphText = self.text(in: paragraphTextRange)
            else { return nil }
        return (paragraphRange, paragraphTextRange, paragraphText)
    }
}
