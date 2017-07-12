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
    
    var pattern: String {
        return self.rawValue
    }
}

enum Unit: String {
    case dot = "\\."
    case whitespace = " "
    case characters = "\\d+(?=\\. )"
    
    var pattern: String {
        return self.rawValue
    }
}

class ElementInspector {
    func inspect(_ text: NSString, handler: (([Unit: (NSString, NSRange)]?)->Void)?) {
        for type in iterateEnum(Type.self) {
            guard let regex = try? NSRegularExpression(pattern: type.pattern, options: []) else { continue }
            
            let matches = regex.matches(in: (text as String), options: [], range: NSMakeRange(0, text.length))
            if let range = matches.first?.range {
                let units = map(text.substring(with: range) as NSString)
                handler?(units)
                
                return
            } else {
                handler?(nil)
            }
        }
    }
    
    private func map(_ text: NSString) -> [Unit: (NSString, NSRange)] {
        var units = [Unit: (NSString, NSRange)]()
        
        for unit in iterateEnum(Unit.self) {
            guard let regex = try? NSRegularExpression(pattern: unit.pattern, options: []) else { continue }
            
            let matches = regex.matches(in: (text as String), options: [], range: NSMakeRange(0, text.length))
            if let range = matches.first?.range {
                units[unit] = (text.substring(with: range) as NSString, range)
            }
        }
        return units
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
