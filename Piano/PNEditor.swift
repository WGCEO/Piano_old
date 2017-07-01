//
//  PNEditor.swift
//  Piano
//
//  Created by dalong on 2017. 6. 2..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SnapKit

@objc(PNEditorEditMode)
enum EditMode: Int {
    case typing
    case effect
    case none
}

@objc class PNEditor: UIView {
    public var attributedText: NSAttributedString {
        get {
            return textView.attributedText
        } set {
            guard newValue != attributedText else { return }
            
            prepareForReuse()
            textView.attributedText = newValue
        }
    }
    
    public var isEdited: Bool {
        return textView.isEdited
    }
    
    public var editMode: EditMode = .none {
        didSet {
            prepare(editMode)
        }
    }
    
    internal var textView: PianoTextView!
    internal var paletteView: PaletteView!
    internal var pianoLabel: PianoLabel!
    internal var canvas = PianoControl()
    
    // MARK: life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    private func configure() {
        configureSubviews()
        
        editMode = .typing
    }
    
    // MARK: configure subviews
    private func configureSubviews() {
        configurePianoTextView()
        configurePaletteView()
        configurePianoLabel()
    }
    
    private func configurePianoTextView() {
        let textView = PianoTextView(frame: CGRect.zero, textContainer: nil)
        
        textView.textContainerInset = UIEdgeInsetsMake(20, 25, 0, 25)
        textView.linkTextAttributes = [NSUnderlineStyleAttributeName: 1]
        textView.allowsEditingTextAttributes = true
        textView.delegate = self
        
        addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        self.textView = textView
    }
    
    private func configurePaletteView() {
        let paletteView = PaletteView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 100))
        paletteView.isHidden = true
        paletteView.effector = canvas
        
        addSubview(paletteView)
        paletteView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(100)
        }
        
        self.paletteView = paletteView
    }
    
    public func configurePianoLabel() {
        let pianoLabel = PianoLabel(frame: bounds)
        pianoLabel.isHidden = true
        
        addSubview(pianoLabel)
        pianoLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(textView)
        }
        
        self.pianoLabel = pianoLabel
    }
    
    // MARK: - public methods
    public func appearKeyboardIfNeeded() {
        textView.isWaitingState = false
        textView.appearKeyboard()
    }
    
    public func addImage(_ image: UIImage) {
        textView.addImage(image)
    }
    
    public func eraseCurrentLine() {
        //textView.eraseCurrentLine()
    }
    
    public func handleChangedText(_ handler: ((NSAttributedString)->Void)?) {
        textView.textChangedHandler = handler
    }
    
    // MARK: - private methods
    private func prepareForReuse() {
        textView.prepareForReuse()
        detachCanvas()
    }
    
    private func prepare(_ editMode: EditMode) {
        switch editMode {
        case .effect:
            showPaletteView()
            attachCanvas()
            textView.isEditable = false
        case .typing:
            hidePaletteView()
            detachCanvas()
            textView.isEditable = true
        case .none:
            hidePaletteView()
            detachCanvas()
            textView.isEditable = false
        }
    }
    
    private func showPaletteView() {
        textView.makeEffectable()
        textView.sizeToFit()
        
        paletteView.isHidden = false
        bringSubview(toFront: paletteView)
        
        animateTextView()
    }
    
    private func hidePaletteView() {
        textView.makeTappable()
        
        paletteView.isHidden = true
        
        animateTextView()
    }
    
    private func animateTextView() {
        let amount = paletteView.isHidden ? 0 : 100
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.textView.snp.updateConstraints({ [weak self] (make) in
                guard let strongSelf = self else { return }
                
                make.top.equalTo(strongSelf).inset(amount)
            })
            self?.layoutIfNeeded()
        }
    }

    private func attachCanvas() {
        detachCanvas()
        
        canvas.textView = textView
        canvas.pianoable = pianoLabel
        
        textView.addSubview(canvas)
        
        updateCanvasFrame()
    }
    
    private func detachCanvas() {
        canvas.removeFromSuperview()
        
        canvas.pianoable = nil
        canvas.textView = nil
        
        pianoLabel.isHidden = true
    }
    
    internal func updateCanvasFrame() {
        let y = textView.contentOffset.y
        let height = textView.bounds.height
        let width = textView.bounds.width
        
        canvas.frame = CGRect(x: 0, y: y, width: width, height: height)
    }
}

extension PNEditor: UITextViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if editMode != .typing {
            updateCanvasFrame()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if editMode != .typing {
            updateCanvasFrame()
        }
    }
}
