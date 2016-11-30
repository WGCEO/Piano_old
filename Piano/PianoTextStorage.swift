//
//  PianoTextStorage.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 30..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class PianoTextStorage: NSTextStorage {
    
    private let backingStore = NSMutableAttributedString()
    
    override var string: String {
        return backingStore.string
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [String : Any] {
        return backingStore.attributes(at: location, effectiveRange: range)
    }
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        print("replaceCharactersInRange(\(NSStringFromRange(range)) withString: \(str)")
        
        beginEditing()
        backingStore.replaceCharacters(in: range, with: str)
        edited([.editedAttributes, .editedCharacters], range: range, changeInLength: str.characters.count - range.length)
        endEditing()
    }
    
    override func setAttributes(_ attrs: [String : Any]?, range: NSRange) {
        print("setAttributes(\(attrs), range: \(NSStringFromRange(range))")
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited([.editedAttributes], range: range, changeInLength: 0)
        endEditing()
    }

}
