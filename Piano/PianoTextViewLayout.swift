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
    
    // MARK: - public methods
    public func detectIndent() {
        let text = textStorage.string as NSString
        let range = NSMakeRange(0, text.length)
        
        addIndent(in: range)
        ElementInspector.sharedInstance.inspect(document: attributedText) { [weak self] (paragraph: Paragraph) in
            guard let strongSelf = self else { return }
            let (element, paragraphRange) = (paragraph.element, paragraph.range)
            let textRange = NSMakeRange(paragraphRange.location + element.range.location, element.range.length)
            let elementInDocument = Element(with: element.type, element.text, textRange)
            
//            if element.type == .checkbox && element.text == "* " {
//                let attachment = ImageTextAttachment(localIdentifier: "checkbox")
//                attachment.image = UIImage(named: "checkbox_on")
//
//                let attachmentAttributedString = NSAttributedString(attachment: attachment)
//
//                strongSelf.textStorage.replaceCharacters(in: NSMakeRange(textRange.location, 1), with: attachmentAttributedString)
//            } else
            if element.type == .list && element.text == "- " {
                strongSelf.textStorage.replaceCharacters(in: NSMakeRange(textRange.location, 1), with: "•")
            } else if element.type == .none && element.text.contains("•") {
                if let range = element.text.range(of: "•").toTextRange(textInput: strongSelf) {
                    strongSelf.replace(range, withText: "-")
                }
            }
            
            if element.type != .none {
                strongSelf.removeIndent(elementInDocument, paragraphRange)
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
                          ElementAttributeKey: ElementType.division] as [NSAttributedStringKey : Any]
        if let font = self.font {
            attributes[NSAttributedStringKey.font] = font
        }
        attributedString.addAttributes(attributes, range: NSMakeRange(0, 3))
        
        textStorage.replaceCharacters(in: selectedRange, with: attributedString)
        
        selectedRange = NSMakeRange(selectedRange.location + 3, 0)
    }
    
    public func addElementIfNeeded(_ replacementText: NSString, in range: NSRange) -> Bool {
        let context = ElementInspector.sharedInstance.context(of: range, in: textStorage.string as NSString)
    
        if replacementText.rangeOfCharacter(from: .newlines).length > 0 {
            guard let element = context.before else { return true }
            if element.type == .number {
                return changeNumberElement(context: context, in: range)
            } else if element.type == .list {
                return changeListElement(context: context, in: range)
            }
        }
        
        return true
    }
    
    public func chainElements() {
        var before: Element?
        var location = 0
        for paragraph in textStorage.string.components(separatedBy: .newlines) {
            let current = ElementInspector.sharedInstance.inspect(with: paragraph as NSString)
            if let before = before {
                if current.type == .number && current.type == before.type {
                    let elementText = before.text.substring(with: NSMakeRange(before.range.location, before.range.length-2))
                    if let beforeElement = Int(elementText),
                        let range = NSMakeRange(location+current.range.location,current.range.length).toTextRange(textInput: self) {
                        let currentElementText = "\(beforeElement + 1). "
                        if currentElementText != (current.text as String) {
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
    
    // MARK: - listing
    private func changeListElement(context: Context, in range: NSRange) -> Bool {
        guard let before = context.before else { return true }
        
        if (before.range.location + before.range.length) == range.location { // 아무것도 입력하지 않았을 경우
            removeListElement(in: before.range)
        } else { // 무언가 입력했을 경우
            addListElement(in: range)
        }
        
        return false
    }
    
    private func addListElement(in range: NSRange) {
        let elementText = "\n• "
        
        if let range = range.toTextRange(textInput: self) {
            replace(range, withText: elementText)
        }
    }
    
    private func removeListElement(in range: NSRange) {
        if let range = range.toTextRange(textInput: self) {
            replace(range, withText: "")
        }
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
        /*
         var font: UIFont
        if element.type == .checkbox {
            font = UIFont.systemFont(ofSize: 16)
        } else {
            guard let fontAtLocation = attributes[NSAttributedStringKey.font] as? UIFont else { return }
                
            font = fontAtLocation
        }
         */
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
