//
//  FlexibleHeightAttachment.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 31..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class DivineLineAttachment: NSTextAttachment {
    
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        return CGRect(x: 0, y: 0, width: lineFrag.width - (PianoGlobal.indent * 2), height: 25)
    }
}
