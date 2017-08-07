//
//  ElementInspector.swift
//  Piano
//
//  Created by dalong on 2017. 7. 12..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation

typealias Context = (previous: Element?, current: Element)

class ElementInspector {
    static let sharedInstance = ElementInspector()
    private let inspectables: [ElementType] = [
        .list,
        .number
    ]

    public func inspect(with text: NSString, _ position: Int = 0) -> Element {
        for type in inspectables {
            guard let regex = try? NSRegularExpression(pattern: type.pattern, options: []) else { continue }
            
            let matches = regex.matches(in: (text as String), options: [], range: NSMakeRange(0, text.length))
            if let range = matches.first?.range {
                return Element(with: type, text.substring(with: range) as NSString, NSMakeRange(position + range.location, range.length))
            }
        }
        
        return Element(with: .none, "", NSMakeRange(0, 0))
    }
    
    public func context(of range: NSRange, in attributedText: NSAttributedString) -> Context {
        let text = attributedText.string as NSString
        
        let currentRange = text.paragraphRange(for: NSMakeRange(range.location, 0))
        let currentText = text.substring(with: currentRange)
        let current = inspect(with: currentText as NSString, currentRange.location)
        current.document = attributedText
        current.paragraphRange = currentRange
        
        var previous: Element?
        if currentRange.location > 0 {
            let previousRange = text.paragraphRange(for: NSMakeRange(currentRange.location-1, 0))
            let previousText = text.substring(with: previousRange)
            previous = inspect(with: previousText as NSString, previousRange.location)
            previous?.document = attributedText
            previous?.paragraphRange = previousRange
        }
        
        return (previous, current)
    }
}
