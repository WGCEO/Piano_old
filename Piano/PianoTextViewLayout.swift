//
//  PianoLayoutManager.swift
//  Piano
//
//  Created by dalong on 2017. 7. 8..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

private let indentWidth: CGFloat = 25.0

let ElementAttributeKey = NSAttributedStringKey("elementAttributeKey")

extension PianoTextView {
    
    override var attributedText: NSAttributedString! {
        didSet {
            detectElement(from: NSMakeRange(0, attributedText.string.count))
        }
    }
    
    // MARK: - public methods
    public func detectElement(from range: NSRange) {
        var before: Element?
        
        let document = attributedText.string as NSString
        let paragraphRange = document.paragraphRange(for: NSMakeRange(range.location, 0))
        document.enumerateSubstrings(in: NSMakeRange(paragraphRange.location, document.length - paragraphRange.location), options: .byParagraphs) { [weak self] (paragraph, paragraphRange, _, stop) in
            guard let strongSelf = self, let paragraph = paragraph as NSString? else { return }
            let element = ElementInspector.sharedInstance.inspect(with: paragraph)
            let textRange = NSMakeRange(paragraphRange.location + element.range.location, element.range.length)
            let elementInDocument = Element(with: element.type, element.text, textRange)
            
            if let before = before {
                if element.type == .number && element.type == before.type {
                    let elementText = before.text.substring(with: NSMakeRange(before.range.location, before.range.length-2))
                    if let beforeElement = Int(elementText),
                        let textRange = NSMakeRange(paragraphRange.location, element.range.length).toTextRange(textInput: strongSelf) {
                        let currentElementText = "\(beforeElement + 1). "
                        if currentElementText != (element.text as String) {
                            strongSelf.replace(textRange, withText: currentElementText)
                            strongSelf.removeIndent(elementInDocument, paragraphRange)
                        }
                    }
                } else {
                    stop.pointee = true
                }
            } else {
                if element.type == .list && element.text == "- " {
                    strongSelf.textStorage.replaceCharacters(in: NSMakeRange(textRange.location, 1), with: "•")
                } else if element.type == .none && element.text.contains("•") {
                    if let range = element.text.range(of: "•").toTextRange(textInput: strongSelf) {
                        strongSelf.replace(range, withText: "-")
                    }
                }
                
                if element.type != .none {
                    strongSelf.removeIndent(elementInDocument, paragraphRange)
                } else {
                    strongSelf.addIndent(in: paragraphRange)
                }
            }
            
            before = element
        }
    }
    
    public func addDivisionLine() {
        let image = UIImage.makeDivisionLine(with: CGSize(width: 1, height: 25))
        let attachment = DivineLineAttachment()
        attachment.image = image
        
        let attributedString = NSMutableAttributedString(string: "\n\n\n")
        attributedString.replaceCharacters(in: NSMakeRange(1, 1), with: NSAttributedString(attachment: attachment))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = indentWidth
        paragraphStyle.headIndent = indentWidth
        
        var attributes = [NSAttributedStringKey.paragraphStyle: paragraphStyle,
                          ElementAttributeKey: ElementType.division] as [NSAttributedStringKey : Any]
        if let font = self.font {
            attributes[NSAttributedStringKey.font] = font
        }
        attributedString.addAttributes(attributes, range: NSMakeRange(0, 3))
        
        textStorage.replaceCharacters(in: selectedRange, with: attributedString)
        
        selectedRange = NSMakeRange(selectedRange.location + 3, 0)
    }
    
    public func addElementIfNeeded(_ replacementText: NSString, in range: NSRange) -> NSRange? {
        let context = ElementInspector.sharedInstance.context(of: range, in: textStorage.string as NSString)
    
        if replacementText.rangeOfCharacter(from: .newlines).length > 0 {
            guard let element = context.before else { return nil }
            if element.type == .number {
                return changeNumberElement(context: context, in: range)
            } else if element.type == .list {
                return changeListElement(context: context, in: range)
            }
        }
        
        return nil
    }
    
    // MARK: - numbering
    private func changeNumberElement(context: Context, in range: NSRange) -> NSRange? {
        guard let before = context.before,
            let current = Int(before.text.substring(with: NSMakeRange(0, before.range.length-2))) else { return nil }
        
        if (before.range.location + before.range.length) == range.location { // 아무것도 입력하지 않았을 경우
            return removeNumberElement(in: before.range)
        } else { // 무언가 입력했을 경우
            let next = current + 1
            return addNumberElement(number: next, in: range)
        }
    }
    
    private func addNumberElement(number: Int, in range: NSRange) -> NSRange? {
        let elementText = "\n\(number). "
        
        guard let textRange = range.toTextRange(textInput: self) else { return nil }
        
        replace(textRange, withText: elementText)
        return NSMakeRange(range.location+1, elementText.count-1)
    }
    
    public func removeNumberElement(in range: NSRange) -> NSRange? {
        guard let textRange = range.toTextRange(textInput: self) else { return nil }
        
        replace(textRange, withText: "")
        return NSMakeRange(range.location, 0)
    }
    
    // MARK: - listing
    private func changeListElement(context: Context, in range: NSRange) -> NSRange? {
        guard let before = context.before else { return nil }
        
        if (before.range.location + before.range.length) == range.location { // 아무것도 입력하지 않았을 경우
            return removeListElement(in: before.range)
        } else { // 무언가 입력했을 경우
            return addListElement(in: range)
        }
    }
    
    private func addListElement(in range: NSRange) -> NSRange? {
        let elementText = "\n• "
        
        guard let textRange = range.toTextRange(textInput: self) else { return nil }
        
        replace(textRange, withText: elementText)
        return NSMakeRange(range.location+1, elementText.count-1)
    }
    
    private func removeListElement(in range: NSRange) -> NSRange? {
        guard let textRange = range.toTextRange(textInput: self) else { return nil }
        
        replace(textRange, withText: "")
        return NSMakeRange(range.location, 0)
    }
    
    // MARK: - indenting
    private func addIndent(in range: NSRange) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = indentWidth
        paragraphStyle.headIndent = indentWidth
        paragraphStyle.lineSpacing = 4
        
        let attributes = [NSAttributedStringKey.paragraphStyle: paragraphStyle,
                          ElementAttributeKey: ElementType.none] as [NSAttributedStringKey: Any]
        textStorage.addAttributes(attributes, range: range)
        textStorage.removeAttribute(NSAttributedStringKey.kern, range: range)
    }
    
    private func removeIndent(_ element: Element, _ paragraphRange: NSRange) {
        guard let font = self.font else { return }
        
        let width = ElementCalculator.sharedInstance.calculateWidth(with: element, font: font)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = indentWidth - width
        paragraphStyle.headIndent = indentWidth - width
        paragraphStyle.lineSpacing = 4
        textStorage.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: paragraphRange)
        
        let elementAttributes = [ElementAttributeKey: element.type,
                                 NSAttributedStringKey.strokeColor: UIColor.black,
                                 NSAttributedStringKey.font: font] as [NSAttributedStringKey : Any]
        textStorage.addAttributes(elementAttributes, range: element.range)
        
        ElementCalculator.sharedInstance.enumerateKerning(with: element, font: font) { [weak self] (kerning: CGFloat, unit: Unit) in
            self?.textStorage.addAttributes([NSAttributedStringKey.kern: kerning], range: unit.range)
        }
    }
}
