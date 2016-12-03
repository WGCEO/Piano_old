//
//  PianoControl.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 25..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

protocol PianoControlDelegate: class {
    func textFromTextView(text: String)
    func rectForText(_ rect: CGRect)
    func xPointFromTouch(_ x: CGFloat)
    func isVisible(_ bool: Bool)
    func resetLeftEnd(value: CGFloat)
}

class PianoControl: UIControl {


    weak var delegate: PianoControlDelegate?
    weak var textView: PianoTextView!
    var selectedRect: CGRect?
    
      
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        //1. 텍스트 뷰의 좌표로 점 평행이동
        let point = touch.location(in: self).move(x: 0, y: textView.contentOffset.y - textView.textContainerInset.top)

        
        let rect = textView.getRect(including: point)
        textView.attachEraseView(rect: rect)
        delegate?.textFromTextView(text: textView.getText(from: rect))
        //        selectedRect = rect
        
        //TODO: ContainerViewHeight = 100 이걸 리터럴이 아닌 값으로 표현해야함
        let shiftX = textView.textContainer.lineFragmentPadding + textView.textContainerInset.left
        let shiftY = textView.textContainerInset.top - textView.contentOffset.y + 100
        let newRect = rect.offsetBy(dx: shiftX, dy: shiftY)

        delegate?.rectForText(newRect)
        
        //TODO: 25가 뭔지 정체 알아내기
        delegate?.xPointFromTouch(point.x + 25)
        delegate?.isVisible(true)
        return true
    }
    

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        //TODO: 25의 정체를 밝히기
        delegate?.xPointFromTouch(touch.location(in: self).x + 25)
        return true
    }
    
    override func cancelTracking(with event: UIEvent?) {
        delegate?.isVisible(false)
        delegate?.resetLeftEnd(value: CGFloat.greatestFiniteMagnitude)
        textView.removeEraseView()
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        delegate?.isVisible(false)
        textView.removeEraseView()
        
        
        //TODO: 코드가 너무 더러움... 완전 리펙토링하기
//        let indexs = label.applyEffectIndexSet.sorted()
//        
//        guard let selectedRect = self.selectedRect,
//            let firstIndex = indexs.first,
//            let lastIndex = indexs.last  else { return }
//
//        let lineRange = textView.layoutManager.glyphRange(forBoundingRect: selectedRect, in: textView.textContainer)
//        let selectedTextRange = NSRange(location: lineRange.location + firstIndex, length: lastIndex - firstIndex + 1)
//        
//
//        let attrs: [String : Any] = [
//            NSFontAttributeName: label.font,
//            NSForegroundColorAttributeName: label.textColor,
//            NSBackgroundColorAttributeName: Constant.yellowEffectColor
//        ]
//        textView.layoutManager.textStorage?.setAttributes(attrs, range: selectedTextRange)
//        
//        self.selectedRect = nil
//        label.applyEffectIndexSet.removeAll()
//        
//        //버그 생길 위험이 있는 코드, 점검하기
//        label.leftEndTouchX = CGFloat.greatestFiniteMagnitude
    }
}




