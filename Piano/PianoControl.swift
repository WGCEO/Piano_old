//
//  PianoControl.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 25..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

protocol Pianoable: class {
    func textFromTextView(text: String)
    func rectForText(_ rect: CGRect)
    func getIndexesForAdd() -> [Int]
    func getIndexesForRemove() -> [Int]
    func beginAnimating(at x: CGFloat)
    func finishAnimating(at x: CGFloat, completion: @escaping () -> Void)
    func progressAnimating(at x: CGFloat)
    func cancelAnimating(completion: @escaping () -> Void)
    func set(effect: TextEffect)
    func attributesForText(_ attributes: [[String : Any]])
    func ismoveDirectly(bool : Bool)
}

class PianoControl: UIControl {

    weak var pianoable: Pianoable?
    weak var textView: PianoTextView!
    weak var editor: PNEditor?
    
    var selectedRange: NSRange?
    var textEffect: TextEffect = .color(.red) {
        didSet {
            pianoable?.set(effect: textEffect)
        }
    }
    
    private func setAttribute(effect:TextEffect, range: NSRange) {
        let attribute: [String : Any]
        switch effect {
        case .color(let x):
            attribute = [NSForegroundColorAttributeName : x]
        case .title(let x):
            let size = UIFont.preferredFont(forTextStyle: x).pointSize
            attribute = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: size)]
        case .line(.underline):
            attribute = [NSUnderlineStyleAttributeName : 1]
        case .line(.strikethrough):
            attribute = [NSStrikethroughStyleAttributeName : 1]
        }
        
        textView.layoutManager.textStorage?.addAttributes(attribute, range: range)
    }
    
    private func removeAttribute(effect: TextEffect, range: NSRange) {
        let attribute: [String : Any]
        switch effect {
        case .color:
            attribute = [NSForegroundColorAttributeName : UIColor.piano]
        case .title:
            attribute = [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body)]
        case .line(.strikethrough):
            attribute = [NSStrikethroughStyleAttributeName : 0]
        case .line(.underline):
            attribute = [NSUnderlineStyleAttributeName : 0]
        }
        
        textView.layoutManager.textStorage?.addAttributes(attribute, range: range)
    }

    // MARK: override methods
    internal override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        //1. 텍스트 뷰의 좌표로 점 평행이동(여기선 수직 오프셋값 - 텍스트 마진)
        let point = touch.location(in: self).move(x: 0, y: textView.contentOffset.y - textView.textContainerInset.top)

        let rect = textView.getRect(including: point)
        let (text, range) = textView.getTextAndRange(from: rect)
        guard !text.isEmptyOrWhitespace() else { return false }
        
        editor?.attachCoverView(rect: rect)
        pianoable?.textFromTextView(text: text)
        selectedRange = range
        
        var attributes:[[String : Any]] = []
        textView.attributedText.enumerateAttributes(in: range, options: []) { (attribute, range, _) in
            //length가 1보다 크면 for문 돌아서 차례대로 더하기
            for _ in 1...range.length {
                attributes.append(attribute)
            }
        }
        pianoable?.attributesForText(attributes)
        
        
        //TODO: TopView = 100 이걸 리터럴이 아닌 값으로 표현해야함
        let shiftX = textView.textContainer.lineFragmentPadding + textView.textContainerInset.left
        let shiftY = textView.textContainerInset.top - textView.contentOffset.y + 100
        let newRect = rect.offsetBy(dx: shiftX, dy: shiftY)

        pianoable?.rectForText(newRect)
        
        //여기서 레이블을 애니메이션으로 띄워야 함
        pianoable?.beginAnimating(at: point.x)
        return true
    }
    
    internal override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        pianoable?.progressAnimating(at: touch.location(in: self).x)
        let isMoveDirectly = touch.previousLocation(in: self).x != touch.location(in: self).x
        pianoable?.ismoveDirectly(bool: isMoveDirectly)
        return true
    }
    
    internal override func cancelTracking(with event: UIEvent?) {
        pianoable?.cancelAnimating(completion: { [unowned self] in
            self.editor?.detach()
            self.selectedRange = nil
        })
    }
    
    internal override func endTracking(_ touch: UITouch?, with event: UIEvent?) {

        guard let touch = touch else { return }
        let x = touch.location(in: self).x
        pianoable?.finishAnimating(at: x, completion: { [unowned self] in
            self.editor?.removeEraseView()
            
            if let range = self.selectedRange,
                let indexsForAdd = self.pianoable?.getIndexesForAdd(),
                let firstIndexForAdd = indexsForAdd.first,
                let lastIndexForAdd = indexsForAdd.last {
                let selectedTextRangeForAdd = NSRange(location: range.location + firstIndexForAdd, length: lastIndexForAdd - firstIndexForAdd + 1)
                self.setAttribute(effect: self.textEffect, range: selectedTextRangeForAdd)
                
            }
            
            if let range = self.selectedRange,
                let indexsForRemove = self.pianoable?.getIndexesForRemove(),
                let firstIndexForRemove = indexsForRemove.first,
                let lastIndexForRemove = indexsForRemove.last{
                let selectedTextRangeForRemove = NSRange(location: range.location + firstIndexForRemove, length: lastIndexForRemove - firstIndexForRemove + 1)
                
                self.removeAttribute(effect: self.textEffect, range: selectedTextRangeForRemove)
            }
            
            self.selectedRange = nil
        }) 
    }
}




