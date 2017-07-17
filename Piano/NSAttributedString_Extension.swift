//
//  NSAttributedString_Extension.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

extension NSAttributedString {
    func resetParagraphStyle() -> NSAttributedString {
        let mutableAttrString = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = NSParagraphStyle()
        if mutableAttrString.length != 0 {
            mutableAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, mutableAttrString.length))
        }
        return mutableAttrString
    }
}
