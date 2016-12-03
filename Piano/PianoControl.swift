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
    func getIndexes() -> [Int]
    func setIndexes(_ indexes: Set<Int>?) 
}

class PianoControl: UIControl {


    weak var delegate: PianoControlDelegate?
    weak var textView: PianoTextView!
    var selectedRange: NSRange?
    
      
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        //1. 텍스트 뷰의 좌표로 점 평행이동
        let point = touch.location(in: self).move(x: 0, y: textView.contentOffset.y - textView.textContainerInset.top)

        
        let rect = textView.getRect(including: point)
        textView.attachEraseView(rect: rect)
        let (text, range) = textView.getTextAndRange(from: rect)
        delegate?.textFromTextView(text: text)
        selectedRange = range
        
        //TODO: ContainerViewHeight = 100 이걸 리터럴이 아닌 값으로 표현해야함
        let shiftX = textView.textContainer.lineFragmentPadding + textView.textContainerInset.left
        let shiftY = textView.textContainerInset.top - textView.contentOffset.y + 100
        let newRect = rect.offsetBy(dx: shiftX, dy: shiftY)

        delegate?.rectForText(newRect)
        
        //TODO: 25가 뭔지 정체 알아내기
        delegate?.xPointFromTouch(point.x + textView.textContainerInset.left)
        delegate?.isVisible(true)
        return true
    }
    

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        delegate?.xPointFromTouch(touch.location(in: self).x + textView.textContainerInset.left)
        return true
    }
    
    override func cancelTracking(with event: UIEvent?) {
        delegate?.isVisible(false)
        delegate?.resetLeftEnd(value: CGFloat.greatestFiniteMagnitude)
        textView.removeEraseView()
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        
        //끝났으면 텍스트뷰에 칠해야 함
        //TODO: 코드가 너무 더러움... 완전 리펙토링하기

        
        guard let range = self.selectedRange, 
            let indexs = delegate?.getIndexes(), 
            let firstIndex = indexs.first,
            let lastIndex = indexs.last  else { return }

        let selectedTextRange = NSRange(location: range.location + firstIndex, length: lastIndex - firstIndex + 1)
        

        //TODO: 로직 싹 다 고쳐야 함
        let attrs: [String : Any] = [
            NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body),
            NSForegroundColorAttributeName: UIColor.black,
            NSBackgroundColorAttributeName: Constant.yellowEffectColor
        ]
        textView.layoutManager.textStorage?.setAttributes(attrs, range: selectedTextRange)
        
        selectedRange = nil
        delegate?.setIndexes(nil)
        
        delegate?.isVisible(false)
        delegate?.resetLeftEnd(value: CGFloat.greatestFiniteMagnitude)
        textView.removeEraseView()
    }
}




