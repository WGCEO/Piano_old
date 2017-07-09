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
public let PNIndentationRegexPatterns = ["(?=[\n]*)\\d+\\. "]

fileprivate let lineSpacing: CGFloat = 8.0
fileprivate let indentWidth: CGFloat = 30.0

class PNLayoutManager: NSLayoutManager {
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
        
        let range = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        
        textStorage?.enumerateAttribute(NSParagraphStyleAttributeName, in: range, options: [], using: { [weak self] (attribute, range, _) in
            guard let paragraphStyle = attribute as? NSParagraphStyle,
                let text = self?.textStorage?.string,
                let strongSelf = self else { return }
            
            if paragraphStyle.hasIndent == false {
                let ranges = text.match().filter { $0.location == range.location }
                let string = text as NSString
                
                if let range = ranges.first {
                    let substring = string.substring(with: range) as NSString
                    
                    let glyphRange = strongSelf.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
                    let glyphContainer = strongSelf.textContainer(forGlyphAt: glyphRange.location, effectiveRange: nil)!
                    let glyphBounds = strongSelf.boundingRect(forGlyphRange: glyphRange, in: glyphContainer)
                    
                    substring.draw(in: glyphBounds, withAttributes: nil)
                }
                
            }
        })
    }
}

class PNLayoutManagerDelegate: NSObject, NSLayoutManagerDelegate {
    
    // MARK: - Invalidating Glyphs and Layout
    // 기본 설정과는 다르게 생성해주어야 하는 Character들을 찾아내 원하는 glyph로 만든다.
    // 그러한 glyph의 갯수를 반환한다.
    func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSGlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: UIFont, forGlyphRange glyphRange: NSRange) -> Int {
        guard let text = layoutManager.textStorage?.string else { return 0 }
        let glyphCount = glyphRange.length
        var newProperties: UnsafeMutablePointer<NSGlyphProperty>?
        let matches = text.match()

        // PNIndentationAttributeName에 대해서 newProperties 설정
        for index in 0..<glyphCount {
            let charIndex = charIndexes[index]
            if let paragraphStyle = layoutManager.textStorage?.attribute(NSParagraphStyleAttributeName, at: charIndex, effectiveRange: nil) as? NSParagraphStyle {
                let matches = matches.filter { charIndex >= $0.location && charIndex < ($0.location + $0.length) }
                
                if paragraphStyle.hasIndent == false && matches.count > 0 {
                    print("shouldGenerateGlyphs" + "\(charIndex)")
                    if newProperties == nil {
                        let memSize = Int(MemoryLayout<NSGlyphProperty>.size * glyphCount)
                        newProperties = unsafeBitCast(malloc(memSize), to: UnsafeMutablePointer<NSGlyphProperty>.self)
                        memcpy(newProperties, props, memSize)
                    }
                    
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
    
    func layoutManager(_ layoutManager: NSLayoutManager, shouldUse action: NSControlCharacterAction, forControlCharacterAt charIndex: Int) -> NSControlCharacterAction {
        guard let text = layoutManager.textStorage?.string else { return action }
        let matches = text.match().filter { $0.location == charIndex }
        
        if matches.count > 0 {
            print("shouldUse" + "\(charIndex)")
            return .whitespace
        }
        
        return action
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, boundingBoxForControlGlyphAt glyphIndex: Int, for textContainer: NSTextContainer, proposedLineFragment proposedRect: CGRect, glyphPosition: CGPoint, characterIndex charIndex: Int) -> CGRect {
        print("boundingBoxForControlGlyphAt" + "\(charIndex)")
        return CGRect(origin: glyphPosition, size: CGSize(width: 30, height: proposedRect.height))
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
            
            if paragraph.match().count > 0 {
                self?.removeIndentationAttribute(in: paragraphRange)
            } else {
                self?.addIndentationAttribute(in: paragraphRange)
            }
        }
    }
    
    private func addIndentationAttribute(in range: NSRange) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = indentWidth
        paragraphStyle.headIndent = indentWidth
        
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
    func match() -> [NSRange] {
        guard let regex = try? NSRegularExpression(pattern: PNIndentationRegexPatterns[0], options: []) else { return [] }
        
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, characters.count))
        return matches.map { $0.range }
    }
}

fileprivate extension NSParagraphStyle {
    var hasIndent: Bool {
        return (firstLineHeadIndent > 0) && (headIndent > 0)
    }
}
