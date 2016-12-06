//
//  PianoTextView.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class PianoTextView: UITextView {
    
    var cacheCursorPosition: CGPoint = CGPoint(x: 0, y: -10)
    var bottomDistance: CGFloat?
    var isAnimating: Bool = false
    
    var mode: TextViewMode = .typing
    let canvas = PianoControl()
    lazy var eraseTextView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.textContainerInset = UIEdgeInsetsMake(20, 20, 0, 20)
        self.delegate = self
        canvas.textView = self
    }
    

    
    //애니메이션중이면 액션을 실행하면 안됨, 실행하게 된다면 둘다 애니메이션이라 blocking이 됨 
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return isAnimating ? false : true
    }
    
    func attachEraseView(rect: CGRect) {
        let left = textContainerInset.left + textContainer.lineFragmentPadding
        let top = textContainerInset.top
        eraseTextView.frame = rect.offsetBy(dx: left, dy: top)
        self.addSubview(eraseTextView)
    }
    
    func removeEraseView() {
        eraseTextView.removeFromSuperview()
    }
    
    func attachCanvas() {
        canvas.removeFromSuperview()
        let left = textContainerInset.left
        let right = textContainerInset.right
        let top = contentOffset.y
        let canvasWidth = bounds.width - (left + right)
        let canvasHeight = bounds.height
        canvas.frame = CGRect(x: left, y: top, width: canvasWidth, height: canvasHeight)
        self.addSubview(canvas)
    }
}

extension PianoTextView: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        guard let nowCursorPosition = textView.selectedTextRange?.start else { return } 
        let cursorPosition = textView.caretRect(for: nowCursorPosition).origin
        
        
        if !isCursorAttachingKeyboard(cursorPosition: cursorPosition) 
            && textView.selectedRange.length < 1 {
            moveCursor(from: cursorPosition)
        }
    }
    
    //현재 커서가 키보드에 붙어있는 지 아닌 지 체크 isCursorAttachingKeyboard
    func isCursorAttachingKeyboard(cursorPosition: CGPoint) -> Bool{
        return cursorPosition.y != cacheCursorPosition.y ? false : true
    }
    
    //커서를 이동시키는 메서드
    func moveCursor(from: CGPoint) {
        guard let bottomDistance = bottomDistance
            else { return }
        
        cacheCursorPosition = from
        let currentCursorY = cacheCursorPosition.y
        let textInsetTop = textContainerInset.top
        let padding2x = textContainer.lineFragmentPadding * 2
        let topInset = bounds.height - (bottomDistance + padding2x + currentCursorY + textInsetTop)
        //textView.textContainer.lineFragmentPadding * 2 이게 맞는 건지 확인해야함
        isAnimating = true
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            if topInset > 0 {
                self?.contentInset.top = topInset
            }
            self?.contentInset.bottom = bottomDistance
            self?.contentOffset.y = -topInset
        }) { [weak self](bool) in
            if bool {
                self?.isAnimating = false
            }
        }
    }
}

extension PianoTextView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if mode != .typing {
            attachCanvas()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if mode != .typing {
            attachCanvas()
        }
    }
}
