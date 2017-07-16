//
//  ElementInspector.swift
//  Piano
//
//  Created by dalong on 2017. 7. 12..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation

enum Type: String {
    case number = "(?=[\n]*)\\d+\\. "
    case list = "(?=[\n]*)\\-\\. "
    case checkbox = "(?=[\n]*)\\*\\. "
    case none = ""
    
    var pattern: String {
        return self.rawValue
    }
}

typealias Element = (type: Type, text: NSString, range: NSRange)
typealias Context = (before: Element?, after: Element?)

class ElementInspector {
    static let sharedInstance = ElementInspector()
    
    private init() {
        
    }
    
    func inspect(_ text: NSString, handler: ((Element)->Void)?) {
        let element = inspect(text)
        handler?(element)
    }
    
    func inspect(_ text: NSString) -> Element {
        for type in iterateEnum(Type.self) {
            guard let regex = try? NSRegularExpression(pattern: type.pattern, options: []) else { continue }
            
            let matches = regex.matches(in: (text as String), options: [], range: NSMakeRange(0, text.length))
            if let range = matches.first?.range {
                return (type, text.substring(with: range) as NSString, range)
            }
        }
        
        return (.none, "", NSMakeRange(0, 0))
    }
    
    func context(of range: NSRange, in text: NSString) -> Context {
        var before: Element?
        var after: Element?
        
        var position = 0
        for paragraph in text.components(separatedBy: .newlines) {
            let paragraphRange = NSMakeRange(position, paragraph.characters.count)
            position += paragraph.characters.count + 1
            
            if paragraphRange.location <= range.location {
                before = inspect(paragraph as NSString)
                if let range = before?.range {
                    before?.range = NSMakeRange(paragraphRange.location + range.location, range.length)
                }
            } else if (paragraphRange.length+paragraphRange.length) < range.location && paragraphRange.location < 10000000 { // TODO: how to detect range location overflow
                after = inspect(paragraph as NSString)
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
