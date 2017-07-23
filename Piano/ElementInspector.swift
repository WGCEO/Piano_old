//
//  ElementInspector.swift
//  Piano
//
//  Created by dalong on 2017. 7. 12..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation

typealias Context = (before: Element?, after: Element?)

class ElementInspector {
    static let sharedInstance = ElementInspector()
    
    private init() {
        
    }
    
    public func inspect(document attributedText: NSAttributedString, handler: ((Paragraph)->Void)?) {
        let text = attributedText.string as NSString
        text.enumerateSubstrings(in: NSMakeRange(0, text.length), options: .byParagraphs) { [weak self] (paragraph, paragraphRange, enclosingRange, stop) in
            guard let strongSelf = self, paragraph != "" else { return }
            
            let paragraphAttributedText = attributedText.attributedSubstring(from: paragraphRange)
            let element = strongSelf.inspect(paragraph: paragraphAttributedText)
            let paragraph = Paragraph(with: element, paragraphRange)
            
            handler?(paragraph)
        }
    }
    
     
    public func inspect(paragraph attributedText: NSAttributedString) -> Element {
        let text = attributedText.string as NSString
        if let attachment = attributedText.attribute(NSAttributedStringKey.attachment, at: 0, effectiveRange: nil) as? ImageTextAttachment {
            if attachment.localIdentifier == "checkbox" && text.length > 1 && text.substring(with: NSMakeRange(1,1)) == " " {
                return Element(with: .checkbox, "* ", NSMakeRange(0, 2))
            }
        }
        
        return inspect(with: text)
    }
    
    public func inspect(with text: NSString) -> Element {
        for type in iterateEnum(ElementType.self) {
            guard let regex = try? NSRegularExpression(pattern: type.pattern, options: []) else { continue }
            
            let matches = regex.matches(in: (text as String), options: [], range: NSMakeRange(0, text.length))
            if let range = matches.first?.range {
                return Element(with: type, text.substring(with: range) as NSString, range)
            }
        }
        
        return Element(with: .none, "", NSMakeRange(0, 0))
    }
    
    public func context(of range: NSRange, in text: NSString) -> Context {
        var before: Element?
        var after: Element?
        
        var position = 0
        for paragraph in text.components(separatedBy: .newlines) {
            let paragraphRange = NSMakeRange(position, paragraph.characters.count)
            position += paragraph.characters.count + 1
            
            if paragraphRange.location <= range.location {
                before = inspect(with: paragraph as NSString)
                if let range = before?.range {
                    before?.range = NSMakeRange(paragraphRange.location + range.location, range.length)
                }
            } else if (paragraphRange.length+paragraphRange.length) < range.location && paragraphRange.location < 10000000 { // TODO: how to detect range location overflow
                after = inspect(with: paragraph as NSString)
                if let range = after?.range {
                    after?.range = NSMakeRange(paragraphRange.location + range.location, range.length)
                }
                
                break
            }
        }
        
        return (before, after)
    }
}

fileprivate func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}
