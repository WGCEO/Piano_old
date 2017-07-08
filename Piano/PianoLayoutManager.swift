//
//  PianoLayoutManager.swift
//  Piano
//
//  Created by dalong on 2017. 7. 8..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

public let PNIndentationAttributeName = "IndentationAttributeName"
public let PNIndentationRegexPattern = "[\n]*[0-9]+.[ \t]"

fileprivate let lineSpacing: CGFloat = 8.0

class PianoLayoutManager: NSObject, NSLayoutManagerDelegate {
    
    // MARK: - Invalidating Glyphs and Layout
    // 기본 설정과는 다르게 생성해주어야 하는 Character들을 찾아내 원하는 glyph로 만든다.
    // 그러한 glyph의 갯수를 반환한다.
    func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSGlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: UIFont, forGlyphRange glyphRange: NSRange) -> Int
    {
        guard let text = layoutManager.textStorage?.string as NSString? else { return 0 }
        let glyphCount = glyphRange.length
        var newProperties: UnsafeMutablePointer<NSGlyphProperty>?
        
        // PNIndentationAttributeName에 대해서 newProperties 설정
        for index in 0..<glyphCount {
            let charIndex = charIndexes[index]
            if layoutManager.textStorage?.attribute(PNIndentationAttributeName, at: charIndex, effectiveRange: nil) != nil
                && text.substring(with: NSMakeRange(charIndex, 1)) == PNIndentationAttributeName {
                if newProperties == nil {
                    let memSize = Int(MemoryLayout<NSGlyphProperty>.size * glyphCount)
                    newProperties = unsafeBitCast(malloc(memSize), to: UnsafeMutablePointer<NSGlyphProperty>.self)
                    memcpy(newProperties, props, memSize)
                    
                    newProperties?[index] = .controlCharacter
                }
            }
        }
        
        if newProperties != nil {
            layoutManager.setGlyphs(glyphs, properties: newProperties!, characterIndexes: charIndexes, font: aFont, forGlyphRange: glyphRange)
            free(newProperties)
            
            return glyphCount
        }
        
        return 0
    }
    
    // TODO: 정확히 무슨 일은 하는 녀석인지 확인
    func layoutManager(_ layoutManager: NSLayoutManager, shouldUse action: NSControlCharacterAction, forControlCharacterAt charIndex: Int) -> NSControlCharacterAction {
        if layoutManager.textStorage?.attribute(PNIndentationAttributeName, at: charIndex, effectiveRange: nil) != nil {
            return .whitespace
        }
        
        return action
    }
    
    // MARK: - Handling Line Fragments
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return lineSpacing
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, boundingBoxForControlGlyphAt glyphIndex: Int, for textContainer: NSTextContainer, proposedLineFragment proposedRect: CGRect, glyphPosition: CGPoint, characterIndex charIndex: Int) -> CGRect {
        
        return CGRect.zero
    }
}


extension PianoTextView {
    public func addIndentationAttribute(in range: NSRange) {
        textStorage.addAttributes([PNIndentationAttributeName: 1], range: range)
    }
    
    public func removeIndentationAttribute(in range: NSRange) {
        textStorage.addAttributes([PNIndentationAttributeName: 0], range: range)
    }
}
