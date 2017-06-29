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
            
            prepareToReuse()
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
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.allowsEditingTextAttributes = true
        
        addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        canvas.textView = textView
        
        self.textView = textView
    }
    
    private func configurePaletteView() {
        let paletteView = PaletteView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 100))
        paletteView.isHidden = true
        
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
    func appearKeyboardIfNeeded() {
        textView.isWaitingState = false
        textView.appearKeyboard()
    }
    
    public func addImage(_ image: UIImage) {
        textView.addImage(image)
    }
    
    // TODO : eraseView to textview
    public func eraseCurrentLine() {
        textView.eraseCurrentLine()
    }
    
    
    // MARK: - private methods
    private func prepareToReuse() {
        textView.prepareForReuse()
        canvas.removeFromSuperview()
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
    
    // MARK: editing
    private func attachCanvas() {
        canvas.removeFromSuperview()
        
        canvas.textView = textView
        canvas.pianoable = pianoLabel
        
        canvas.frame = textView.bounds
        addSubview(canvas)
        canvas.snp.makeConstraints { (make) in
            make.edges.equalTo(textView)
        }
    }
    
    private func detachCanvas() {
        canvas.removeFromSuperview()
        pianoLabel.isHidden = false
    }
}

extension PNEditor: Effectable {
    func setEffect(textEffect: TextEffect){
        canvas.textEffect = textEffect
    }
}
