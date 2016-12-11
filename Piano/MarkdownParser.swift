//
//  MarkdownParser.swift
//  Piano
//
//  Created by kevin on 2016. 12. 8..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class MarkdownParser {
    
    private let bodyTextAttributes: [String : UIFont] =  [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body)]
    private let titleOneAttributes: [String : UIFont] = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .title1)]
    private let titleTwoAttributes: [String:UIFont] = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .title2)]
    private let titleThreeAttributes: [String:UIFont] = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .title3)]
    private let headline: [String:UIFont] = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .headline)]
    
    
    func parseMarkdown(text: String) -> NSAttributedString {
        
        // 1. break the file into lines and iterate over each line
        let lines = text.components(separatedBy: NSCharacterSet.newlines)
        
        // 2. define a mapping for teh markdown
        let mapping = [
            "###" : titleOneAttributes,
            "##" : titleTwoAttributes,
            "#" : titleThreeAttributes
        ]
        // 3. a function that formats a single line
        let formatLine = {(line: String) -> NSAttributedString in
            
            guard let lineStartExpression = try? NSRegularExpression(pattern: "^(#{0,3})(.*)", options: []) else {
                print("lineStartExpression를 초기화 하는 데 에러")
                return NSAttributedString(string: line + "\n", attributes: self.bodyTextAttributes)
            }
            let matches = lineStartExpression.matches(in: line, options: [], range: NSMakeRange(0, line.characters.count))
            if matches.count > 0 {
                let match = matches[0]
                guard let rangeOne = line.range(from: match.rangeAt(1)),
                let rangeTwo = line.range(from: match.rangeAt(2)) else {
                    print("rangeTwo를 초기화 하는 데 에러")
                    return NSAttributedString(string: line + "\n", attributes: self.bodyTextAttributes)
                }
                let prefix = line.substring(with: rangeOne)
                let remainder = line.substring(with: rangeTwo)
                    
                guard let attributes = mapping[prefix] else {
                    print("attributes를 초기화 하는 데 에러")
                    return NSAttributedString(string: line + "\n", attributes: self.bodyTextAttributes)
                }
                    
                return NSAttributedString(string: remainder + "\n", attributes: attributes)
            }

            return NSAttributedString(string: line + "\n", attributes: self.bodyTextAttributes)
        }
        
        return lines.filter { $0 != ""}.reduce(NSMutableAttributedString(),
                                               { (attributedString, nextLine) in attributedString
                                                .append(formatLine(nextLine))
                                                return attributedString })
    }
    
    
    
    
    
}

