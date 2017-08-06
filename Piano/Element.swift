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
    case none = ""
    case number = "^((?=[\n]*)\\d+\\. )"
    case list = "^((?=[\n]*)[•-] )"
    //case checkbox = "^((?=[\n]*)\\* )"
    case division = "divisionLine"
    
    var pattern: String {
        return self.rawValue
    }
}

enum UnitType: String {
    case none
    case head
    case dot
    case whitespace
}

struct Paragraph {
    var element: Element
    var range: NSRange
    
    init(with element: Element, _ range: NSRange) {
        self.element = element
        self.range = range
    }
}

struct Element {
    var type: ElementType
    var text: NSString
    var range: NSRange
    
    init(with type: ElementType, _ text: NSString, _ range: NSRange) {
        self.type = type
        self.text = text
        self.range = range
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
            handler?(Unit(with: .whitespace, whitespaceText as NSString, NSMakeRange(range.location + whitespaceRange.location, whitespaceRange.length)))
        }
    }
    
    private func dotUnit(_ handler: ((Unit)->Void)?) {
        if type == .number {
            let dotRange = NSMakeRange(range.length - 2, 1)
            let dotText = text.substring(with: dotRange)
            handler?(Unit(with: .dot, dotText as NSString, NSMakeRange(range.location + dotRange.location, dotRange.length)))
        }
    }
    
    private func headUnit(_ handler: ((Unit)->Void)?) {
        switch type {
        case .number:
            let headRange = NSMakeRange(0, range.length-2)
            let headText = text.substring(with: headRange)
            handler?(Unit(with: .head, headText as NSString, NSMakeRange(range.location + headRange.location, headRange.length)))
        case .list:
            let headRange = NSMakeRange(0, 1)
            let headText = text.substring(with: headRange)
            handler?(Unit(with: .head, headText as NSString, NSMakeRange(range.location + headRange.location, headRange.length)))
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
