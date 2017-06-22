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
    
    // MARK: views
    lazy var eraseTextView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(PNEditor.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PNEditor.keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PNEditor.keyboardDidHide(notification:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    // MARK: public methods
    func appearKeyboardIfNeeded() {
        textView.isWaitingState = false
        
        //TODO: 코드 리펙토링제대로하기
        //textView.isWaitingState = false
        //appearKeyboardIfNeeded()
        //appearKeyboardIfNeeded = { }
    }
    
    public func addImage(_ image: UIImage) {
        textView.addImage(image)
    }
    
    func showPaletteView() {
        textView.makeEffectable()
        textView.sizeToFit()
        
        paletteView.isHidden = false
        bringSubview(toFront: paletteView)
        
        animateTextView()
    }
    
    func hidePaletteView() {
        textView.makeTappable()
        
        paletteView.isHidden = true
        
        animateTextView()
    }
    
    public func attachEraseView(rect: CGRect) {
        let left = textView.textContainerInset.left + textView.textContainer.lineFragmentPadding
        let top = textView.textContainerInset.top
        eraseTextView.frame = rect.offsetBy(dx: left, dy: top)
        
        self.addSubview(eraseTextView)
    }
    
    public func removeEraseView() {
        eraseTextView.removeFromSuperview()
    }
    
    // MARK: private methods
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
    
    // MARK: edit text?
    func removeSubrange(from: Int) {
        //layoutManager에서 접근을 해야 캐릭터들을 올바르게 지울 수 있음(안그러면 이미지가 다 지워져버림)
        /*
         let range = NSMakeRange(from, textView.selectedRange.location - from)
         textView.layoutManager.textStorage?.deleteCharacters(in: range)
         textView.selectedRange = NSRange(location: from, length: 0)
         */
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
    
    // MARK: keyboard
    func keyboardWillShow(notification: Notification){
        /*
         textView.isWaitingState = true
         
         guard let userInfo = notification.userInfo,
         let kbFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
         let height = navigationController?.toolbar.bounds.height else { return }
         
         
         //kbFrame의 y좌표가 실제로 키보드의 위치임 따라서 화면 높이에서 프레임 y를 뺸 게 바텀이면 됨!
         let inset = UIEdgeInsetsMake(0, 0, UIScreen.main.bounds.height - kbFrame.origin.y - height, 0)
         textView.contentInset = inset
         textView.scrollIndicatorInsets = inset
         textView.scrollRangeToVisible(textView.selectedRange)
         */
    }
    
    func keyboardDidHide(notification: Notification) {
        //textView.makeTappable()
    }
    
    func keyboardWillHide(notification: Notification){
        /*
         textView.makeUnableTap()
         
         textView.contentInset = UIEdgeInsets.zero
         textView.scrollIndicatorInsets = UIEdgeInsets.zero
         */
    }
    
}

extension PNEditor: Effectable {
    func setEffect(textEffect: TextEffect){
        canvas.textEffect = textEffect
    }
}
