//
//  PianoLayoutManager.swift
//  Piano
//
//  Created by dalong on 2017. 7. 8..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit


fileprivate let indentWidth: CGFloat = 30.0

extension PianoTextView {
    public func detectIndentation() {
        let text = textStorage.string as NSString
        let range = NSMakeRange(0, text.length)
        
        text.enumerateSubstrings(in: range, options: .byParagraphs) { [weak self] (paragraph: String?, paragraphRange: NSRange, enclosingRange: NSRange, stop) in
            guard let paragraph = paragraph as NSString? else { return }
            
            ElementInspector.sharedInstance.inspect(paragraph, handler: { (type: Type, text: NSString, range: NSRange) in
                if type == .none {
                    self?.addIndentationAttribute(in: paragraphRange)
                    return
                } else if type == .number {
                    guard let font = self?.font else { return }
                    
                    // 1. 숫자의 width를 검사하기
                    var width: CGFloat = 0.0
                    var attributedText = NSMutableAttributedString(string: text as String)
                    attributedText.addAttributes([NSFontAttributeName : font], range: range)
                    width = attributedText.boundingRect(with: CGSize(width: 0, height: 0), options: [], context: nil).width
                    
                    // 2. 마침표의 길이 구하기
                    attributedText = NSMutableAttributedString(string: ".")
                    attributedText.addAttributes([NSFontAttributeName : font], range: NSMakeRange(0, 1))
                    width += attributedText.boundingRect(with: CGSize(width: 0, height: 0), options: [], context: nil).width * 1 // Todo: 커닝 적용하고 1.3으으로 바꿔야 함
                    
                    // 3. 공백의 길이 구하기
                    attributedText = NSMutableAttributedString(string: " ")
                    attributedText.addAttributes([NSFontAttributeName : font], range: NSMakeRange(0, 1))
                    width += attributedText.boundingRect(with: CGSize(width: 0, height: 0), options: [], context: nil).width * 1
                    
                    self?.removeIndentationAttribute(width, in: paragraphRange)
                }
            })
        }
    }
    
    public func addElementIfNeeded(_ replacementText: NSString, in range: NSRange) -> Bool {
        let (before, _) = ElementInspector.sharedInstance.context(of: range, in: textStorage.string as NSString)
        
        if replacementText.rangeOfCharacter(from: .newlines).length > 0 {
            guard let (type, text) = before else { return true }
            if type == .number {
                let next = text.intValue + 1
                let element = "\n\(next). "
                if let newRange = range.toTextRange(textInput: self) {
                    replace(newRange, withText: element)
                    
                    return false
                }
            }
        }
        
        return true
    }
    
    private func addIndentationAttribute(in range: NSRange) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = indentWidth
        paragraphStyle.headIndent = indentWidth
        
        textStorage.addAttributes([NSParagraphStyleAttributeName: paragraphStyle], range: range)
    }
    
    private func removeIndentationAttribute(_ width: CGFloat, in range: NSRange) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = indentWidth-width
        paragraphStyle.headIndent = indentWidth-width
        
        textStorage.addAttributes([NSParagraphStyleAttributeName: paragraphStyle], range: range)
    }
    
}
