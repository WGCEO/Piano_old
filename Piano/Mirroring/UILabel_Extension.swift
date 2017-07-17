//
//  UILabel_Extension.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

extension UILabel {
    func getGlyphIndex(from point: CGPoint) -> Int? {
        guard let attrText = self.attributedText else { return nil }
        let textStorage = NSTextStorage(attributedString: attrText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)
        return layoutManager.glyphIndex(for: point, in: textContainer)
    }
}
