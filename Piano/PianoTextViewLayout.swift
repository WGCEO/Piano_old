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
    
    // MARK: - public methods
    public func detectIndentation() {
        let text = textStorage.string as NSString
        let range = NSMakeRange(0, text.length)
        
        addIndentAttribute(in: range)
        text.enumerateSubstrings(in: range, options: .byParagraphs) { [weak self] (paragraph: String?, paragraphRange: NSRange, enclosingRange: NSRange, stop) in
            guard let paragraph = paragraph as NSString? else { return }
            ElementInspector.sharedInstance.inspect(paragraph, handler: { (type: Type, text: NSString, range: NSRange) in
                
                if type == .number {
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
                    
                    self?.removeIndentAttribute(width, in: paragraphRange)
                }
            })
        }
    }
    
    public func addElementIfNeeded(_ replacementText: NSString, in range: NSRange) -> Bool {
        let context = ElementInspector.sharedInstance.context(of: range, in: textStorage.string as NSString)
    
        if replacementText.rangeOfCharacter(from: .newlines).length > 0 {
            guard let element = context.before else { return true }
            if element.type == .number {
                return changeNumberElement(context: context, in: range)
            }
        }
        
        detectIndentation()
        
        return true
    }
    
    // MARK: - numbering
    private func changeNumberElement(context: Context, in range: NSRange) -> Bool {
        guard let before = context.before,
            let current = Int(before.text.substring(with: NSMakeRange(0, before.range.length-2))) else { return true }
        
        if (before.range.location + before.range.length) == range.location { // 아무것도 입력하지 않았을 경우
            removeNumberElement(in: before.range)
        } else { // 무언가 입력했을 경우
            let next = current + 1
            addNumberElement(number: next, in: range)
        }
        
        return false
    }
    
    private func addNumberElement(number: Int, in range: NSRange) {
        let elementText = "\n\(number). "
        
        if let range = range.toTextRange(textInput: self) {
            replace(range, withText: elementText)
        }
    }
    
    public func removeNumberElement(in range: NSRange) {
        if let range = range.toTextRange(textInput: self) {
            replace(range, withText: "")
        }
        
        print("remove \(range.location)-\(range.length): ?")
    }
    
    // MARK: - checkboxing
    
    // MARK: - listing
    
    // MARK: - indenting
    private func addIndentAttribute(in range: NSRange) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = indentWidth
        paragraphStyle.headIndent = indentWidth
        
        textStorage.addAttributes([NSParagraphStyleAttributeName: paragraphStyle], range: range)
    }
    
    private func removeIndentAttribute(_ width: CGFloat, in range: NSRange) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = indentWidth-width
        paragraphStyle.headIndent = indentWidth-width
        
        textStorage.addAttributes([NSParagraphStyleAttributeName: paragraphStyle], range: range)
    }
    
}
