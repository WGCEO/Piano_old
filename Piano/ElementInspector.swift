//
//  ElementInspector.swift
//  Piano
//
//  Created by dalong on 2017. 7. 12..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation

enum Type: String {
    case number = "(?=[\n]*)\\d+(?=\\. )"
    case list = "(?=[\n]*)\\-(?=\\. )"
    case checkbox = "(?=[\n]*)\\*(?=\\. )"
    case none = ""
    
    var pattern: String {
        return self.rawValue
    }
}

class ElementInspector {
    static let sharedInstance = ElementInspector()
    
    private init() {
        
    }
    
    func inspect(_ text: NSString, handler: ((_ type: Type, _ text: NSString, _ range: NSRange)->Void)?) {
        for type in iterateEnum(Type.self) {
            guard let regex = try? NSRegularExpression(pattern: type.pattern, options: []) else { continue }
            
            let matches = regex.matches(in: (text as String), options: [], range: NSMakeRange(0, text.length))
            if let range = matches.first?.range {
                handler?(type, text.substring(with: range) as NSString, range)
                
                return
            }
        }
        
        handler?(.none, "", NSMakeRange(0, 0))
    }
    
    func inspect(_ text: NSString) -> (type: Type, text: NSString) {
        for type in iterateEnum(Type.self) {
            guard let regex = try? NSRegularExpression(pattern: type.pattern, options: []) else { continue }
            
            let matches = regex.matches(in: (text as String), options: [], range: NSMakeRange(0, text.length))
            if let range = matches.first?.range {
                return (type, text.substring(with: range) as NSString)
            }
        }
        
        return (.none, "")
    }
    
    func context(of range: NSRange, in text: NSString) -> (before: (type: Type, text: NSString)?, after: (type: Type, text: NSString)?) {
        var before: (type: Type, text: NSString)?
        var after: (type: Type, text: NSString)?
        
        for paragraph in text.components(separatedBy: .newlines) {
            let paragraphRange = text.range(of: paragraph)
            
            if paragraphRange.location < range.location {
                before = inspect(paragraph as NSString)
            } else if (paragraphRange.length+paragraphRange.length) < range.location && paragraphRange.location < 10000000 { // TODO: how to detect range location overflow 
                after = inspect(paragraph as NSString)
                
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
