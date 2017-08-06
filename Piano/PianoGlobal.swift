//
//  PianoGlobal.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

struct PianoGlobal {
    static var color = UIColor.red
    static var defaultColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
    static var fontSize: CGFloat = 17
    
    static let paletteViewHeight: CGFloat = 70
    static let toolBarHeight: CGFloat = 44
    static let accessoryViewHeight: CGFloat = 44
    static let duration: Double = 0.2
    static let opacity: CGFloat = 1
    static let transparent: CGFloat = 0.3
    static let mirrorFont: CGFloat = 31
    static let backgroundColor: UIColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
    static let imageWidth: CGFloat = 451.2
    static var indent: CGFloat = 25.0
    static var defaultFont: UIFont = UIFont.systemFont(ofSize: 17)
    static let lineSpacing: CGFloat = 8.0
    
    static let defaultAttributes: [NSAttributedStringKey : Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = 0
        paragraphStyle.tailIndent = 0
        paragraphStyle.lineSpacing = PianoGlobal.lineSpacing
        
        let font = PianoGlobal.defaultFont
        let foregroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        let backgroundColor = UIColor.clear
        
        let attrs: [NSAttributedStringKey : Any] = [.paragraphStyle : paragraphStyle,
                                                    .font : font,
                                                    .foregroundColor: foregroundColor,
                                                    .backgroundColor: backgroundColor,
                                                    .underlineStyle: 0,
                                                    .strikethroughStyle: 0
        ]
        return attrs
    }()
}
