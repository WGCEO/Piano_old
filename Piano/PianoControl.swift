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
    func getIndexesForAdd() -> [Int]
    func getIndexesForRemove() -> [Int]
    func beginAnimating(at x: CGFloat)
    func finishAnimating(at x: CGFloat, completion: @escaping () -> Void)
    func progressAnimating(at x: CGFloat)
    func cancelAnimating(completion: @escaping () -> Void)
    func set(effect: TextEffectAttribute)
    func attributesForText(_ attributes: [[String : Any]])
    func ismoveDirectly(bool : Bool)
}

class PianoControl: UIControl {

    weak var delegate: PianoControlDelegate?
    weak var textView: PianoTextView!
    var selectedRange: NSRange?
    var textEffect: TextEffectAttribute = .headline {
        didSet {
            delegate?.set(effect: textEffect)
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        //1. 텍스트 뷰의 좌표로 점 평행이동
        let point = touch.location(in: self).move(x: 0, y: textView.contentOffset.y - textView.textContainerInset.top)

        let rect = textView.getRect(including: point)
        textView.attachEraseView(rect: rect)
        let (text, range) = textView.getTextAndRange(from: rect)
        delegate?.textFromTextView(text: text)
        selectedRange = range
        
        var attributes:[[String : Any]] = []
        textView.attributedText.enumerateAttributes(in: range, options: []) { (attribute, range, _) in
            //length가 1보다 크면 for문 돌아서 차례대로 더하기
            for _ in 1...range.length {
                attributes.append(attribute)
            }
        }
        delegate?.attributesForText(attributes)
        
        
        //TODO: ContainerViewHeight = 100 이걸 리터럴이 아닌 값으로 표현해야함
        let shiftX = textView.textContainer.lineFragmentPadding + textView.textContainerInset.left
        let shiftY = textView.textContainerInset.top - textView.contentOffset.y + 100
        let newRect = rect.offsetBy(dx: shiftX, dy: shiftY)

        delegate?.rectForText(newRect)
        
        //여기서 레이블을 애니메이션으로 띄워야 함
        delegate?.beginAnimating(at: point.x + textView.textContainerInset.left)
        return true
    }
    

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        delegate?.progressAnimating(at: touch.location(in: self).x + textView.textContainerInset.left)
        let isMoveDirectly = touch.previousLocation(in: self).x != touch.location(in: self).x
        delegate?.ismoveDirectly(bool: isMoveDirectly)
        return true
    }
    
    override func cancelTracking(with event: UIEvent?) {
        delegate?.cancelAnimating(completion: { [unowned self] in
            self.textView.removeEraseView()
            self.selectedRange = nil
        })
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        
        //끝났으면 텍스트뷰에 칠해야 함
        //TODO: 코드가 너무 더러움... 완전 리펙토링하기

        guard let touch = touch else { return }
        let x = touch.location(in: self).x + textView.textContainerInset.left
        delegate?.finishAnimating(at: x, completion: { [unowned self] in 
            self.textView.removeEraseView()
            
            if let range = self.selectedRange,
                let indexsForAdd = self.delegate?.getIndexesForAdd(),
                let firstIndexForAdd = indexsForAdd.first,
                let lastIndexForAdd = indexsForAdd.last {
                let selectedTextRangeForAdd = NSRange(location: range.location + firstIndexForAdd, length: lastIndexForAdd - firstIndexForAdd + 1)
                self.setAttribute(effect: self.textEffect, range: selectedTextRangeForAdd)
                
            }
            
            if let range = self.selectedRange,
                let indexsForRemove = self.delegate?.getIndexesForRemove(),
                let firstIndexForRemove = indexsForRemove.first,
                let lastIndexForRemove = indexsForRemove.last{
                let selectedTextRangeForRemove = NSRange(location: range.location + firstIndexForRemove, length: lastIndexForRemove - firstIndexForRemove + 1)
                
                self.removeAttribute(effect: self.textEffect, range: selectedTextRangeForRemove)
            }
            
            self.selectedRange = nil
        }) 
    }
    
    func setAttribute(effect:TextEffectAttribute, range: NSRange) {
        let attribute: [String : Any]
        switch effect {
        case .normal:
            attribute = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body)]
        case .headline:
            attribute = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .headline)]
        case .red:
            attribute = [NSForegroundColorAttributeName : UIColor.red]
        case .green:
            attribute = [NSForegroundColorAttributeName : UIColor.green]
        case .strike:
            attribute = [NSStrikethroughStyleAttributeName : 1]
        case .underline:
            attribute = [NSUnderlineStyleAttributeName : 1]
        }
        
        textView.layoutManager.textStorage?.addAttributes(attribute, range: range)
    }
    
    func removeAttribute(effect: TextEffectAttribute, range: NSRange) {
        let attribute: [String : Any]
        switch effect {
        case .normal:
            attribute = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body)]
        case .headline:
            attribute = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body)]
        case .red:
            attribute = [NSForegroundColorAttributeName : UIColor.black]
        case .green:
            attribute = [NSForegroundColorAttributeName : UIColor.black]
        case .strike:
            attribute = [NSStrikethroughStyleAttributeName : 0]
        case .underline:
            attribute = [NSUnderlineStyleAttributeName : 0]
        }
        
        textView.layoutManager.textStorage?.addAttributes(attribute, range: range)
    }
    

}




