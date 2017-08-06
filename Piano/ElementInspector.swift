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
    private let inspectables: [ElementType] = [
        .list,
        .number
    ]
    
    private init() {
        
    }
    
    public func inspect(with text: NSString) -> Element {
        for type in inspectables {
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
