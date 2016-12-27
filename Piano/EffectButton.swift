//
//  EffectButton.swift
//  Piano
//
//  Created by kevin on 2016. 12. 27..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class EffectButton: UIButton {

    weak var textView: PianoTextView?
    var textEffect: TextEffect = .color(.red) {
        didSet {
            guard let textView = self.textView else { return }
            textView.canvas.textEffect = textEffect
            
            switch textEffect {
            case .color(let x):
                self.setTitleColor(x, for: .selected)
                self.setTitleColor(x.withAlphaComponent(0.3), for: .normal)
            default:
                ()
            }
        }
    }

}
