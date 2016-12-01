//
//  PianoControl.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 25..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class PianoControl: UIControl {

    @IBOutlet weak var label: PianoLabel!
    @IBOutlet weak var curtainView: UIView!

    weak var textView: PianoTextView?
    
      
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard let textView = self.textView else { return true }
        
        //1. rect 가져오기 2. 터치포인트에 해당하는 텍스트 라인 가져오기
        let point = touch.location(in: self)
        var rect = textView.getRect(including: point)
        label.text = textView.getText(from: rect)
        
        let shiftX = textView.textContainer.lineFragmentPadding + textView.textContainerInset.left
        //TODO: ContainerViewHeight = 100 이걸 리터럴이 아닌 값으로 표현해야함
        let shiftY = textView.textContainerInset.top - textView.contentOffset.y + 100
        rect.origin.move(x: shiftX, y: shiftY)

        label.actualRect = rect
        rect.origin.move(x: 0, y: UIApplication.shared.statusBarFrame.height)
        curtainView.frame = rect
    
        //TODO: 25가 뭔지 정체 알아내기
        label.touchPointX = touch.location(in: self).x + 25
        label.isHidden = false
        curtainView.isHidden = false
        return true
    }
    

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        //TODO: 25의 정체를 밝히기
        label.touchPointX = touch.location(in: self).x + 25
        return true
    }
    
    override func cancelTracking(with event: UIEvent?) {
        label.isHidden = true
        curtainView.isHidden = true
        label.leftEndTouchX = CGFloat.greatestFiniteMagnitude
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        label.isHidden = true
        curtainView.isHidden = true
        
        
        //버그 생길 위험이 있는 코드, 점검하기
        label.leftEndTouchX = CGFloat.greatestFiniteMagnitude
        
        
    }
}
