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
public let PNIndentationRegexPatterns = ["^[\\s\\t]*\\d+(?=\\. )"]

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
}


extension PianoTextView {
    public func detectIndentation() {
        let text = textStorage.string as NSString
        let range = NSMakeRange(0, text.length)
        
        text.enumerateSubstrings(in: range, options: .byParagraphs) { [weak self] (paragraph: String?, paragraphRange: NSRange, enclosingRange: NSRange, stop) in
            guard let paragraph = paragraph else { return }
            
            if paragraph.match() {
                self?.removeIndentationAttribute(in: paragraphRange)
            } else {
                self?.addIndentationAttribute(in: paragraphRange)
            }
            
            print("paragraph(\(paragraphRange.location)~\(paragraphRange.length)): \(paragraph)")
        }
    }
    
    private func addIndentationAttribute(in range: NSRange) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 30.0
        paragraphStyle.headIndent = 30.0
        
        textStorage.addAttributes([NSParagraphStyleAttributeName: paragraphStyle], range: range)
    }
    
    private func removeIndentationAttribute(in range: NSRange) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0.0
        paragraphStyle.headIndent = 0.0
        
        textStorage.addAttributes([NSParagraphStyleAttributeName: paragraphStyle], range: range)
    }
    
}

extension String {
    func match() -> Bool {
        guard let regex = try? NSRegularExpression(pattern: PNIndentationRegexPatterns[0], options: []) else { return false }
        
        // set attribute in range for indentation
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, characters.count))
        for match in matches {
            return true
        }
        
        return false
    }
}
