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
