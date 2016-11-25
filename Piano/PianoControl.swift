//
//  PianoControl.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 25..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class PianoControl: UIControl {

    @IBOutlet weak var label: UILabel!
    
    //TODO: super 메서드 호출해도 되는 것인지.
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        
        return true
    }
    
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
    }
}
