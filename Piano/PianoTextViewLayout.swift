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

let IndentElementAttributeKey = NSAttributedStringKey(ElementType.indent.rawValue)
let DivisionElementAttributeKey = NSAttributedStringKey(ElementType.division.rawValue)
let HeaderElementAttributeKey = NSAttributedStringKey(ElementType.header.rawValue)

extension PianoTextView {
    
    override var attributedText: NSAttributedString! {
        didSet {
            detectElement(from: NSMakeRange(0, attributedText.string.count))
        }
    }
    
    // MARK: - public methods
    public func detectElement(from range: NSRange) {
        let context = ElementInspector.sharedInstance.context(of: range, in: attributedText)
        if context.current.type != .none {
            changeCharacterIfNeeded(with: context.current)
            removeIndent(of: context.current)
        } else {
            addIndent(to: context.current)
        }
        
        var current: Element? = context.current
        var previous = context.previous
        current?.previous = previous
        repeat {
            if let current = current,
                (current.type == .number && current.type == previous?.type),
                let nextNumberText = previous?.calculateNextNumberText(with: current.depth),
                nextNumberText != current.text {
                
                let difference = nextNumberText.length - current.range.length
                textStorage.replaceCharacters(in: current.range, with: nextNumberText as String)
                removeIndent(of: current)
                
                current.increment(with: difference)
            }
            
            previous = current
            current = current?.next
        } while (current != nil)
    }
    
    public func changeCharacterIfNeeded(with element: Element) {
        if element.type == .list && element.text == "- " {
            textStorage.replaceCharacters(in: NSMakeRange(element.range.location, 1), with: "•")
        } else if element.type == .none && element.text.contains("•") {
            if let range = element.text.range(of: "•").toTextRange(textInput: self) {
                replace(range, withText: "-")
            }
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
                          DivisionElementAttributeKey: ElementType.division] as [NSAttributedStringKey : Any]
        if let font = self.font {
            attributes[NSAttributedStringKey.font] = font
        }
        attributedString.addAttributes(attributes, range: NSMakeRange(0, 3))
        
        textStorage.replaceCharacters(in: selectedRange, with: attributedString)
        
        selectedRange = NSMakeRange(selectedRange.location + 3, 0)
    }
    
    public func addElementIfNeeded(_ replacementText: NSString, in range: NSRange) -> NSRange? {
        if replacementText.rangeOfCharacter(from: .newlines).length > 0 {
            let current = ElementInspector.sharedInstance.context(of: range, in: attributedText).current
            
            guard current.range.location + current.range.length <= range.location else { return nil }
            
            if current.type == .number {
                return changeNumberElement(with: current, in: range)
            } else if current.type == .list {
                return changeListElement(with: current, in: range)
            }
        } else if replacementText.contains("\t") {
            guard let before = ElementInspector.sharedInstance.context(of: range, in: attributedText).previous,
                before.type == .number || before.type == .list else { return nil }
            
            let depth = textStorage.attribute(IndentElementAttributeKey, at: before.range.location, effectiveRange: nil) as? Int ?? 1
            textStorage.addAttributes([IndentElementAttributeKey: (depth+1)], range: before.range)
            
            let changedRange = NSMakeRange(range.location, 0)
            detectElement(from: changedRange)
            
            return changedRange
        }
        
        return nil
    }
    
    // MARK: - numbering
    private func changeNumberElement(with element: Element, in range: NSRange) -> NSRange? {
        if (element.range.location + element.range.length) == range.location { // 아무것도 입력하지 않았을 경우
            return removeNumberElement(in: element.range)
        } else { // 무언가 입력했을 경우
            return addNumberElement(with: element, in: range)
        }
    }
    
    private func addNumberElement(with element: Element, in range: NSRange) -> NSRange? {
        guard let current = Int(element.text.substring(with: NSMakeRange(0, element.range.length-2))),
            let textRange = range.toTextRange(textInput: self) else { return nil }
        
        let next = current + 1
        let elementText = "\n\(next). "
        
        
        replace(textRange, withText: elementText)
        
        let depth = textStorage.attribute(IndentElementAttributeKey, at: element.range.location, effectiveRange: nil) as? Int ?? 1
        let changedRange = NSMakeRange(range.location+1, elementText.count-1)
        textStorage.addAttributes([IndentElementAttributeKey: depth], range: changedRange)
        detectElement(from: changedRange)
        
        return changedRange
    }
    
    public func removeNumberElement(in range: NSRange) -> NSRange? {
        textStorage.replaceCharacters(in: range, with: "")
        selectedRange = NSMakeRange(range.location, 0)
        
        return NSMakeRange(range.location, 0)
    }
    
    // MARK: - listing
    private func changeListElement(with element: Element, in range: NSRange) -> NSRange? {
        if (element.range.location + element.range.length) == range.location { // 아무것도 입력하지 않았을 경우
            return removeListElement(in: element.range)
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
    private func addIndent(to element: Element) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = indentWidth
        paragraphStyle.headIndent = indentWidth
        paragraphStyle.lineSpacing = 4
        
        let attributes = [NSAttributedStringKey.paragraphStyle: paragraphStyle] as [NSAttributedStringKey: Any]
        textStorage.addAttributes(attributes, range: element.paragraphRange)
        textStorage.removeAttribute(NSAttributedStringKey.kern, range: element.range)
    }
    
    private func removeIndent(of element: Element) {
        guard let font = self.font else { return }
        
        let width = ElementCalculator.sharedInstance.calculateWidth(with: element, font: font)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = indentWidth * CGFloat(element.depth) - width
        paragraphStyle.headIndent = indentWidth * CGFloat(element.depth) - width
        paragraphStyle.lineSpacing = 4
        textStorage.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: element.paragraphRange)
        
        let elementAttributes = [NSAttributedStringKey.strokeColor: UIColor.black,
                                 NSAttributedStringKey.font: font] as [NSAttributedStringKey : Any]
        textStorage.addAttributes(elementAttributes, range: element.range)
        
        ElementCalculator.sharedInstance.enumerateKerning(with: element, font: font) { [weak self] (kerning: CGFloat, unit: Unit) in
            self?.textStorage.addAttributes([NSAttributedStringKey.kern: kerning], range: unit.range)
        }
    }
}
