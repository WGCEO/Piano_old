//
//  PianoEditor.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

enum PianoMode: Int {
    case on = 0
    case off
}

class PianoEditor: UIView {
    
    // MARK: property
    @IBOutlet weak var textView: PianoTextView!
    @IBOutlet weak var pianoView: PianoView!
    @IBOutlet weak var topViewTop: NSLayoutConstraint!
    @IBOutlet var topButtons: [UIButton]!
    
    // MARK: init
    override func awakeFromNib() {
        super.awakeFromNib()
        setValuesForChildViews()
    }
    
    //MARK: Public
    @IBAction func tapTopButton(_ sender: UIButton) {
        setPianoViewAttributeStyle(by: sender)
        animate(for: sender)
    }
    
    @IBAction func tapCloseKeyboardButton(_ sender: Any) {
        textView.resignFirstResponder()
    }
    
    public func animate(for mode: PianoMode) {
        let (topValue, insetTop, completion) = animateValues(for: mode)
        
        UIView.animate(withDuration: PianoGlobal.duration, animations: { [weak self] in
            self?.topViewTop.constant = topValue
            self?.textView.contentInset.top = insetTop
            self?.layoutIfNeeded()
        }) { (_) in
            completion()
        }
    }
    
    //MARK: Private
    private func setValuesForChildViews() {
        textView.control.pianoable = pianoView
        textView.control.effectable = textView
    }
    
    private func setPianoViewAttributeStyle(by button: UIButton) {
        guard let style = PianoAttributeStyle(rawValue: button.tag) else { return }
        pianoView.attributeStyle = style
    }
    
    private func animate(for selectedButton: UIButton){
        for button in topButtons {
            UIView.animate(withDuration: PianoGlobal.duration, animations: {
                if button == selectedButton {
                    button.alpha = PianoGlobal.opacity
                } else {
                    button.alpha = PianoGlobal.transparent
                }
            })
        }
    }
    
    private func animateValues(for mode: PianoMode) -> (CGFloat, CGFloat, completion: () -> Void) {
        let topValue: CGFloat
        let insetTop: CGFloat
        let completion: () -> Void
        
        switch mode {
        case .on:
            topValue = 0
            insetTop = PianoGlobal.paletteViewHeight
            completion = { [weak self] in
                self?.textView.isEditable = false
                self?.textView.isSelectable = false
                self?.textView.attachControl()
                self?.textView.setOffsetForPreventBug()
            }
        case .off:
            topValue = -PianoGlobal.paletteViewHeight
            insetTop = PianoGlobal.navigationBarHeight
            completion = { [weak self] in
                self?.textView.isEditable = true
                self?.textView.isSelectable = true
                self?.textView.detachControl()
            }
        }
        return (topValue, insetTop, completion)
    }
}
