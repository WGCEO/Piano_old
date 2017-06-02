//
//  EffectButton.swift
//  Piano
//
//  Created by kevin on 2016. 12. 27..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class EffectButton: UIButton {
    var eidtor: PNEditor?
    
    var textEffect: TextEffect = .color(.red) {
        didSet {
            guard let editor = eidtor else { return }
            
            editor.canvas.textEffect = textEffect
            
            switch textEffect {
            case .color(let x):
                self.setTitleColor(x, for: .selected)
                self.setTitleColor(x.withAlphaComponent(0.3), for: .normal)
            case .line(let x):
                self.setTitle(x != .strikethrough ?  "\u{f0cd}" : "\u{f0cc}", for: .selected)
                self.setTitle(x != .strikethrough ?  "\u{f0cd}" : "\u{f0cc}", for: .normal)
            case .title(let x):
                let font = UIFont.preferredFont(forTextStyle: x)
                let size = font.pointSize + CGFloat(6)
                titleLabel?.font = titleLabel?.font.withSize(size)
            }
        }
    }

}
