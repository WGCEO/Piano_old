//
//  NSRange_Extension.swift
//  Piano
//
//  Created by 김찬기 on 2016. 12. 3..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

extension NSRange {
    func toTextRange(textInput:UITextInput) -> UITextRange? {
        guard let rangeStart = textInput.position(from: textInput.beginningOfDocument, offset: location),
            let rangeEnd = textInput.position(from: rangeStart, offset: length) else {
            return nil
        }
        
        return textInput.textRange(from: rangeStart, to: rangeEnd)
    }
}
