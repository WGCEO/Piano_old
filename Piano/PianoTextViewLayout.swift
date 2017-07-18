//
//  PianoLayoutManager.swift
//  Piano
//
//  Created by dalong on 2017. 7. 8..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

private let indentWidth: CGFloat = 30.0

extension PianoTextView {
    
    // MARK: - public methods
    public func detectIndent() {
        let text = textStorage.string as NSString
        let range = NSMakeRange(0, text.length)
        
        addIndent(in: range)
        text.enumerateSubstrings(in: range, options: .byParagraphs) { [weak self] (paragraph: String?, paragraphRange: NSRange, enclosingRange: NSRange, stop) in
            guard let paragraph = paragraph as NSString? else { return }
            ElementInspector.sharedInstance.inspect(paragraph, handler: { (element: Element) in
                let textRange = NSMakeRange(paragraphRange.location + element.range.location, range.length)
                
                if element.type != .none {
                    self?.removeIndent(element.text, textRange, paragraphRange)
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
        
        return true
    }
    
    public func chainElements() {
        var before: Element?
        var location = 0
        for paragraph in textStorage.string.components(separatedBy: .newlines) {
            let current = ElementInspector.sharedInstance.inspect(paragraph as NSString)
            if let before = before {
                if current.type == .number && current.type == before.type {
                    let elementText = before.text.substring(with: NSMakeRange(before.range.location, before.range.length-2))
                    if let beforeElement = Int(elementText),
                        let range = NSMakeRange(location+current.range.location,current.range.length).toTextRange(textInput: self) {
                        let currentElementText = "\(beforeElement + 1). "
                        if currentElementText != (current.text as String) {
                            print(currentElementText,location+current.range.location,current.range.length)
                            replace(range, withText: currentElementText)
                            
                            return
                        }
                    }
                }
            }
            
            before = current
            location += paragraph.characters.count + 1
        }
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
    }
    
    // MARK: - checkboxing
    
    // MARK: - listing
    
    // MARK: - indenting
    private func addIndent(in range: NSRange) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = indentWidth
        paragraphStyle.headIndent = indentWidth
        
        textStorage.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: range)
        
        // TODO: add to indentation
    }
    
    private func removeIndent(_ text: NSString, _ textRange: NSRange, _ paragraphRange: NSRange) {
        let attributes = textStorage.attributes(at: textRange.location, effectiveRange: nil)
        guard let font = attributes[NSAttributedStringKey.font] as? UIFont else { return }
        
        let width = text.width(font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = indentWidth - width
        paragraphStyle.headIndent = indentWidth - width
        textStorage.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: paragraphRange)
        
        text.enumerateKernings(font) { [weak self] (index, kerning) in
            let attributes = [NSAttributedStringKey.kern : kerning]
            
            let range = NSMakeRange(textRange.location + index, 1)
            self?.textStorage.addAttributes(attributes, range: range)
        }
    }
}
