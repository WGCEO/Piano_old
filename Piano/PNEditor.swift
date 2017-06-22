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
    internal var canvas = PianoControl()
    private var images: [UIImage] = []
    
    // MARK: public methods
    public func addImage(_ image: UIImage) {
        textView.addImage(image)
    }
    
    // MARK: views
    lazy var eraseTextView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
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
        let paletteView = PaletteView(frame: CGRect.zero)
        
        addSubview(paletteView)
        paletteView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(100)
        }
        
        self.paletteView = paletteView
    }
    
    // MARK: public methods
    func appearKeyboardIfNeeded() {
        textView.isWaitingState = false
        
        //TODO: 코드 리펙토링제대로하기
        //textView.isWaitingState = false
        //appearKeyboardIfNeeded()
        //appearKeyboardIfNeeded = { }
    }
    
    func prepareToEditing() {
        /*
        if textView.mode != .typing {
            attachCanvas()
        }
        */
    }
    
    func prepare(_ editMode: EditMode) {
        switch editMode {
        case .effect:
            showPaletteView()
            attachCanvas()
            //setTextViewEditedState()
        case .typing:
            hidePaletteView()
            detachCanvas()
            //setTextViewEditedState()
        case .none:
            textView.isEditable = false
        }
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
    
    
    private func animateTextView() {
        let navigationController = AppNavigator.currentNavigationController
        let isHidden = !(paletteView.isHidden)
        
        navigationController?.setNavigationBarHidden(!isHidden, animated: true)
        navigationController?.setToolbarHidden(!isHidden, animated: true)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.textView.contentInset.bottom = isHidden ? 50 : 0
            self?.textView.topConstraint?.constant = isHidden ? 100 : 0
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
    
    func detachCanvas() {
        canvas.removeFromSuperview()
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
    
    // MARK: private methods
    private func prepareToReuse() {
        images.removeAll()
        textView.prepareForReuse()
        canvas.removeFromSuperview()
    }
}


extension PNEditor: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        /*
         guard memo != nil else {
         addNewMemo()
         return
         }
         */
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //setTextViewEditedState()
        updateCellInfo()
    }
    
    //첫번째 이미지 캐싱해놓고, 첫번째 attachment 이미지와 캐싱한 이미지가 다를 경우에만 실행
    func updateCellInfo() {
        /*
         guard let memo = self.memo,
         let textView = self.textView,
         let attrText = textView.attributedText else { return }
         
         let text = textView.text.trimmingCharacters(in: .symbols).trimmingCharacters(in: .newlines)
         let firstLine: String
         switch text {
         case let x where x.characters.count > 50:
         firstLine = x.substring(to: x.index(x.startIndex, offsetBy: 50))
         case let x where x.characters.count == 0:
         //이미지만 있는 경우에도 해당됨
         firstLine = "NewMemo".localized(withComment: "새로운 메모")
         default:
         firstLine = text
         }
         
         memo.firstLine = firstLine
         
         let hasAttachments = attrText.containsAttachments(in: NSMakeRange(0, attrText.length))
         
         guard hasAttachments else {
         memo.imageData = nil
         return
         }
         
         attrText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, attrText.length), options: []) { (value, range, stop) in
         
         guard let attachment = value as? NSTextAttachment,
         let image = attachment.image else { return }
         
         guard firstImage != image else {
         stop.pointee = true
         return
         }
         
         firstImage = image
         
         let oldWidth = image.size.width;
         
         //I'm subtracting 10px to make the image display nicely, accounting
         //for the padding inside the textView
         let ratio = 60 / oldWidth;
         
         let size = image.size.applying(CGAffineTransform(scaleX: ratio, y: ratio))
         UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
         image.draw(in: CGRect(origin: CGPoint.zero, size: size))
         let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         if let scaledImage = scaledImage, let data = UIImagePNGRepresentation(scaledImage) {
         memo.imageData = data as NSData
         stop.pointee = true
         }
         
         }
         */
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        /*
         if textView.mode != .typing {
         textView.attachCanvas()
         }
         */
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        /*
         if textView.mode != .typing {
         textView.attachCanvas()
         }
         */
    }
}

extension PNEditor: Effectable {
    func setEffect(textEffect: TextEffect){
        canvas.textEffect = textEffect
    }
}

fileprivate extension PianoTextView {
    var topConstraint: NSLayoutConstraint? {
        for constraint in constraints {
            if constraint.firstAttribute == .top {
                return constraint
            }
        }
        
        return nil
    }
}
