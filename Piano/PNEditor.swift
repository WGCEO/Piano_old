//
//  PNEditor.swift
//  Piano
//
//  Created by dalong on 2017. 6. 2..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

@objc class PNEditor: UIView {
    var textView: PianoTextView!
    var canvas = PianoControl()
    
    var memo: Memo? {
        willSet {
            //startLoading()
            //우선 이미지에 nil 대입하기
            //firstImage = nil
            //resignFirstResponder()
            //saveCoreDataIfNeed()
        }
        didSet {
            /*
            showTopView(bool: false)
            editor?.canvas.removeFromSuperview()
            guard memo != oldValue else {
                editor?.isEdited = false
                stopLoading()
                return
            }
            
            self.setTextView(with: self.memo)
            DispatchQueue.main.async { [weak self] in
                self?.stopLoading()
                self?.contentOffset = CGPoint.zero
            }
            */
        }
    }
    
    // MARK: views
    lazy var eraseTextView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let textView = PianoTextView(frame: frame)
        
        textView.textContainerInset = UIEdgeInsetsMake(20, 25, 0, 25)
        textView.linkTextAttributes = [NSUnderlineStyleAttributeName: 1]
        textView.allowsEditingTextAttributes = true
        
        canvas.textView = textView
        
        self.textView = textView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: eraserView
    func attachEraseView(rect: CGRect) {
        let left = textView.textContainerInset.left + textView.textContainer.lineFragmentPadding
        let top = textView.textContainerInset.top
        eraseTextView.frame = rect.offsetBy(dx: left, dy: top)
        
        self.addSubview(eraseTextView)
    }
    
    func removeEraseView() {
        eraseTextView.removeFromSuperview()
    }
    
    // MARK: canvas
    func attachCanvas() {
        let contentOffset = textView.contentOffset
        
        canvas.removeFromSuperview()
        let top = contentOffset.y
        let canvasWidth = bounds.width
        let canvasHeight = bounds.height
        canvas.frame = CGRect(x: 0, y: top, width: canvasWidth, height: canvasHeight)
        self.addSubview(canvas)
    }
}


