//
//  PianoLayoutManager.swift
//  Piano
//
//  Created by dalong on 2017. 7. 18..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

let lineSpacing: CGFloat = 8.0

class ElementLayoutManager: NSObject, NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: UIFont, forGlyphRange glyphRange: NSRange) -> Int {
        let glyphCount = glyphRange.length
        
        var properties: UnsafeMutablePointer<NSLayoutManager.GlyphProperty>?
        
        for index in 0..<glyphCount {
            let charIndex = charIndexes[index]
            guard let type = layoutManager.textStorage?.attribute(ElementAttributeName, at: charIndex, effectiveRange: nil) as? Type else { continue }
            if type == .list || type == .checkbox {
                if properties == nil {
                    let memSize = Int(MemoryLayout<NSLayoutManager.GlyphProperty>.size * glyphCount)
                    properties = unsafeBitCast(malloc(memSize), to: UnsafeMutablePointer<NSLayoutManager.GlyphProperty>.self)
                    memcpy(properties, props, memSize)
                }
            
                properties?[index] = .controlCharacter
            }
        }
        
        guard let props = properties else { return 0 }
        
        layoutManager.setGlyphs(glyphs, properties: props, characterIndexes: charIndexes, font: aFont, forGlyphRange: glyphRange)
        free(props)
        return glyphCount
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, shouldUse action: NSLayoutManager.ControlCharacterAction, forControlCharacterAt charIndex: Int) -> NSLayoutManager.ControlCharacterAction {
        if let type = layoutManager.textStorage?.attribute(ElementAttributeName, at: charIndex, effectiveRange: nil) as? Type {
            return .whitespace
        }
        
        return action
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return lineSpacing
    }
}
