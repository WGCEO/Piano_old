//
//  PianoControl.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 25..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

typealias PianoViewDataTrigger = () -> PianoViewData
typealias CaptivateResult = (PianoResult) -> Void

protocol Pianoable: class {
    func preparePiano(with dataTrigger: PianoViewDataTrigger)
    func playPiano(previousX: CGFloat, currentX: CGFloat)
    func endPiano(completion: @escaping CaptivateResult)
}

protocol Effectable: class {
    func preparePiano(from point: CGPoint) -> PianoViewDataTrigger
    func endPiano(with result: PianoResult)
}

class PianoControl: UIControl {
    
    public weak var effectable: Effectable?
    public weak var pianoable: Pianoable?
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard let effectable = self.effectable, let pianoable = self.pianoable else { return false }
        let currentPoint = touch.location(in: self)
        let previousPoint = touch.previousLocation(in: self)
        
        guard currentPoint.x != previousPoint.x else { return true }
        
        //1. 피아노 데이터 세팅
        pianoable.preparePiano(with: effectable.preparePiano(from: currentPoint))
        
        //2. 터치점에 따라 피아노 애니메이션 진행
        pianoable.playPiano(previousX: previousPoint.x, currentX: currentPoint.x)
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        guard let effectable = self.effectable,
            let pianoable = self.pianoable else { return }
        
        pianoable.endPiano { (result) in
            effectable.endPiano(with: result)
        }
    }
    
    override func cancelTracking(with event: UIEvent?) {
        guard let effectable = self.effectable, let pianoable = self.pianoable else { return }
        pianoable.endPiano { (result) in
            effectable.endPiano(with: result)
        }
    }
}
