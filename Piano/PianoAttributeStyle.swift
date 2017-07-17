//
//  PianoAttributeStyle.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

enum PianoAttributeStyle: Int {
    case color = 0
    case bold
    case italic
    case underline
    case strikeThrough
    
    func attr() -> [NSAttributedStringKey : Any] {
        switch self {
        case .color:
            return [.foregroundColor : PianoGlobal.color]
        case .bold:
            return [.font : UIFont.boldSystemFont(ofSize: PianoGlobal.fontSize)
            ]
        case .italic:
            return [.font : UIFont.italicSystemFont(ofSize: PianoGlobal.fontSize)]
        case .underline:
            return [.underlineStyle : 1, .underlineColor : PianoGlobal.color]
        case .strikeThrough:
            return [.strikethroughStyle : 1, .strikethroughColor : PianoGlobal.color]
        }
    }
    
    func removeAttr() -> [NSAttributedStringKey : Any] {
        switch self {
        case .color:
            return [.foregroundColor : PianoGlobal.defaultColor]
        case .bold, .italic:
            return [.font : UIFont.systemFont(ofSize: PianoGlobal.fontSize)
            ]
        case .underline:
            return [NSAttributedStringKey.underlineStyle : 0]
        case .strikeThrough:
            return [NSAttributedStringKey.strikethroughStyle : 0]
        }
    }
}
