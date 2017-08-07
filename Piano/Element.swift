//
//  NSString+Kerning.swift
//  Piano
//
//  Created by dalong on 2017. 7. 16..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

private let standardCharacter: NSString = "4"

enum ElementType: String {
    case none = "None"
    case number = "Number"
    case list = "List"
    case division = "Division"
    case tab = "tab"
    case header = "header"
    case indent = "indent"
    
    var pattern: String {
        switch self {
        case .number:
            return "^((?=[\n]*)\\d+\\. )"
        case .list:
            return "^((?=[\n]*)[•-] )"
        default:
            return ""
        }
    }
}

enum UnitType: String {
    case none
    case head
    case dot
    case whitespace
}

fileprivate let firstNumberText = "1. "
fileprivate let defaultDepth = 1

class Element {
    var type: ElementType
    var text: NSString
    var range: NSRange
    var paragraphRange: NSRange
    
    weak var document: NSAttributedString?
    var depth: Int {
        return document?.attribute(IndentElementAttributeKey, at: range.location, effectiveRange: nil) as? Int ?? defaultDepth
    }
    
    var previous: Element?
    var next: Element? {
        guard let text = document?.string as NSString?,
            range.length + range.length > text.length else { return nil }
        
        let nextRange = text.paragraphRange(for: NSMakeRange(range.length + range.length + 1, 0))
        let nextText = text.substring(with: range)
        let nextElement = ElementInspector.sharedInstance.inspect(with: nextText as NSString, nextRange.location)
        nextElement.paragraphRange = nextRange
        nextElement.document = document
        nextElement.previous = self
        
        return nextElement
    }
    
    static let none = Element(with: .none, "", NSMakeRange(0, 0))
    init(with type: ElementType, _ text: NSString, _ range: NSRange) {
        self.type = type
        self.text = text
        self.range = range
        self.paragraphRange = range
    }
    
    public func increment(with amount: Int) {
        self.range = NSMakeRange(range.location + amount, range.length)
        self.paragraphRange = NSMakeRange(paragraphRange.location + amount, paragraphRange.length)
    }
    
    public func calculateNextNumberText(with depth: Int) -> NSString? {
        var previous: Element? = self
        while true {
            if let prevElement = previous, prevElement.type == .number && prevElement.depth == depth {
                let elementText = prevElement.text.substring(with: NSMakeRange(0, prevElement.range.length-2))
                if let prevNumber = Int(elementText) {
                    return "\(prevNumber + 1). " as NSString
                } else {
                    return nil
                }
            }
            
            previous = previous?.previous
            if previous == nil { return firstNumberText as NSString }
        }
    }
    
    public func enumerateUnits(_ handler: ((Unit)->Void)?) {
        whitespaceUnit(handler)
        dotUnit(handler)
        headUnit(handler)
    }
    
    private func whitespaceUnit(_ handler: ((Unit)->Void)?) {
        if type != .none {
            let whitespaceRange = NSMakeRange(range.length - 1, 1)
            let whitespaceText = text.substring(with: whitespaceRange)
            handler?(Unit(with: .whitespace, whitespaceText as NSString, NSMakeRange(0 + whitespaceRange.location, whitespaceRange.length)))
        }
    }
    
    private func dotUnit(_ handler: ((Unit)->Void)?) {
        if type == .number {
            let dotRange = NSMakeRange(range.length - 2, 1)
            let dotText = text.substring(with: dotRange)
            handler?(Unit(with: .dot, dotText as NSString, NSMakeRange(0 + dotRange.location, dotRange.length)))
        }
    }
    
    private func headUnit(_ handler: ((Unit)->Void)?) {
        switch type {
        case .number:
            let headRange = NSMakeRange(0, range.length-2)
            let headText = text.substring(with: headRange)
            handler?(Unit(with: .head, headText as NSString, NSMakeRange(0 + headRange.location, headRange.length)))
        case .list:
            let headRange = NSMakeRange(0, 1)
            let headText = text.substring(with: headRange)
            handler?(Unit(with: .head, headText as NSString, NSMakeRange(0 + headRange.location, headRange.length)))
        default: ()
        }
    }
}

struct Unit {
    var type: UnitType
    var text: NSString
    var range: NSRange

    init(with type: UnitType, _ text: NSString, _ range: NSRange) {
        self.type = type
        self.text = text
        self.range = range
    }
}
