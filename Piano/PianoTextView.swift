//
//  PianoTextView.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class PianoTextView: UITextView {
    
    //lazy var로 만들어서 코어데이터 첫 메모를 fetch하기
//    internal var note: Memo? {
//        didSet {
//            folderView?.setFolders(for: note)
//        }
//    }
    
    private var coverView: UIView?
    
    private lazy var formInputView: FormInputView? = {
        let nib = UINib(nibName: "FormInputView", bundle: nil)
        guard let formInputView = nib.instantiate(withOwner: self, options: nil).first as? FormInputView else { return nil }
        formInputView.delegate = self
        formInputView.setup()
        return formInputView
    }()
    
    //TODO: iOS9 컨스트레인트 사용하는 법 체크해서 적용하기
    private lazy var folderView: FolderView? = {
        let nib = UINib(nibName: "FolderView", bundle: nil)
        guard let folderView = nib.instantiate(withOwner: self, options: nil).first as? FolderView else { return nil }
        folderView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: bounds.width, height: 0))
        folderView.delegate = NoteManager.sharedInstance
        addSubview(folderView)
        return folderView
    }()
    
    //MARK: init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
        setInsets()
        setInputAccessoryView()
        keyboard(listen: true)
    }
    
    deinit {
        keyboard(listen: false)
    }
    
    //MARK:
    public var control = PianoControl()
    
    private func setInsets(){
        textContainer.lineFragmentPadding = 0
        textContainerInset = UIEdgeInsetsMake(10 + PianoGlobal.paletteViewHeight, 10, PianoGlobal.toolBarHeight * 2, 10)
    }
    
    private func setInputAccessoryView(){
        let nib = UINib(nibName: "MRInputAccessoryView", bundle: nil)
        guard let mrInputAccessoryView = nib.instantiate(withOwner: self, options: nil).first as? MRInputAccessoryView else { return }
        mrInputAccessoryView.delegate = self
        inputAccessoryView = mrInputAccessoryView
    }
    
    private func addCoverView(rect: CGRect) {
        removeCoverView()
        let coverView = UIView()
        coverView.backgroundColor = backgroundColor
        coverView.frame = rect
        insertSubview(coverView, belowSubview: control)
        
        self.coverView = coverView
    }
    
    public func attachControl() {
        control.removeFromSuperview()
        let point = CGPoint(x: 0, y: contentOffset.y + contentInset.top)
        var size = bounds.size
        size.height -= (contentInset.top + contentInset.bottom)
        control.frame = CGRect(origin: point, size: size)
        addSubview(control)
    }
    
    public func detachControl() {
        control.removeFromSuperview()
    }
    
    public func removeCoverView(){
        coverView?.removeFromSuperview()
        coverView = nil
    }
    
    //이걸 안해주면 첫줄만 있을 경우 피아노효과가 한 번만에 적용안되는 버그가 있음.
    public func setOffsetForPreventBug(){
        self.contentOffset = contentOffset
    }
    
    private func setAttribute(with result: PianoResult) {
        //TODO: 2는 어떤 줄이 윗 줄에 적용되는 버그에 대한 임시 해결책
        let final = result.final.move(x: -textContainerInset.left, y: -textContainerInset.top + 2)
        let farLeft = result.farLeft.move(x: -textContainerInset.left, y: -textContainerInset.top + 2)
        let farRight = result.farRight.move(x: -textContainerInset.left, y: -textContainerInset.top + 2)
        
        let applyRange = getRangeForApply(farLeft: farLeft, final: final)
        if applyRange.length > 0 {
//            isScrollEnabled = false
            layoutManager.textStorage?.addAttributes(result.applyAttribute, range: applyRange)
//            isScrollEnabled = true
        }
        
        let removeRange = getRangeForRemove(final: final, farRight: farRight)
        if removeRange.length > 0 {
            let mutableAttrText = NSMutableAttributedString(attributedString: attributedText)
            mutableAttrText.addAttributes(result.removeAttribute, range: removeRange)
            attributedText = mutableAttrText
//            isScrollEnabled = false
            layoutManager.textStorage?.addAttributes(result.removeAttribute, range: removeRange)
//            isScrollEnabled = true
        }
        
//        setOffsetForPreventBug()
    }
}

extension PianoTextView {
    private func keyboard(listen: Bool){
        if listen {
            NotificationCenter.default.addObserver(self, selector: #selector(PianoTextView.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(PianoTextView.keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(PianoTextView.keyboardDidHide(notification:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
            
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc internal func keyboardWillShow(notification: Notification){
        
        guard let userInfo = notification.userInfo,
            let kbFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            else { return }
        
        let bottom = UIScreen.main.bounds.height - kbFrame.origin.y + 50
        contentInset.bottom = bottom
        scrollIndicatorInsets.bottom = bottom
        scrollRangeToVisible(selectedRange)
        
        setFormInputView(height: kbFrame.size.height - 44)
    }
    
    @objc internal func keyboardWillHide(notification: Notification){
        contentInset = UIEdgeInsets.zero
        scrollIndicatorInsets = contentInset
        setOffsetForPreventBug()
        
    }
    
    @objc internal func keyboardDidHide(notification: Notification){
        setOffsetForPreventBug()
        formInputView?.reset()
    }
    
    private func setFormInputView(height: CGFloat){
        formInputView?.frame.size.height = height
    }
}

extension PianoTextView: Effectable {
    
    func preparePiano(from point: CGPoint) -> (() -> PianoViewData) {
        return { [weak self] in
            guard let strongSelf = self
                else {
                    return PianoViewData(rect: CGRect.zero, labelInfos: [])
            }
            
            let relativePoint = point.move(x: 0, y: strongSelf.contentOffset.y + strongSelf.contentInset.top - strongSelf.textContainerInset.top)
            
            let index = strongSelf.layoutManager.glyphIndex(for: relativePoint, in: strongSelf.textContainer)
            var range = NSRange()
            var rect = strongSelf.layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &range)
            rect.origin.y += strongSelf.textContainerInset.top
            //TODO: cover뷰 추가하는 코드. 코드 위치 리펙토링 대상
            strongSelf.addCoverView(rect: rect)
            // effectable 스크롤 안되도록 고정
            strongSelf.isUserInteractionEnabled = false
            //여기까지
            
            let attrText = strongSelf.attributedText.attributedSubstring(from: range).resetParagraphStyle()
            
            var labelInfos: [(label: UILabel, center: CGPoint, frame: CGRect, font: UIFont)] = []
            for (index, character) in attrText.string.enumerated() {
                let pointX = strongSelf.layoutManager.location(forGlyphAt: range.location + index).x
                
                let label = UILabel()
                let attrCharaceter = NSAttributedString(string: String(character), attributes: attrText.attributes(at: index, effectiveRange: nil))
                label.attributedText = attrCharaceter
                label.sizeToFit()
                label.frame.origin.x = pointX + strongSelf.textContainerInset.left + strongSelf.contentInset.left
                label.frame.origin.y = rect.origin.y - strongSelf.contentOffset.y
                labelInfos.append((label: label, center: label.center, frame: label.frame, font: label.font))
            }
            return PianoViewData(rect: rect, labelInfos: labelInfos)
        }
    }
    
    func endPiano(with result: PianoResult) {
        setAttribute(with: result)
        removeCoverView()
        isUserInteractionEnabled = true
    }
}

extension PianoTextView: Insertable {
    func insertDivision() {
        addDivisionLine()
    }
    
    func insert(form: UIImage) {
        //
        
    }
    
    func insert(image: UIImage?) {
        guard let image = image else { return }
        
        let attachment = ImageAttachment(image: image)
        let imageAttrString = NSAttributedString(attachment: attachment)
        let imageMutableAttrString = NSMutableAttributedString(attributedString: imageAttrString)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        
        let font = UIFont.systemFont(ofSize: PianoGlobal.fontSize)
        let fontColor = PianoGlobal.defaultColor
        
        imageMutableAttrString.addAttributes([.paragraphStyle : paragraphStyle,
                                              .font: font,
                                              .foregroundColor : fontColor], range: NSMakeRange(0, imageMutableAttrString.length))

        let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)
        mutableAttrString.insert(imageMutableAttrString, at: selectedRange.location)
        attributedText = mutableAttrString
        
        typingAttributes = [NSAttributedStringKey.paragraphStyle.rawValue : paragraphStyle,
                            NSAttributedStringKey.font.rawValue: font,
                            NSAttributedStringKey.foregroundColor.rawValue : fontColor]
    }
    
    
    func temporateCode(){
//        let a4Width: CGFloat = 535.2
//        let ratio = a4Width / unwrapImage.size.width
//        let size = unwrapImage.size.applying(CGAffineTransform(scaleX: ratio, y: ratio))
//        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
//        unwrapImage.draw(in: CGRect(origin: CGPoint.zero, size: size))
//        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
    }
}

extension PianoTextView : KeyboardControllable {
    func resignKeyboard() {
        resignFirstResponder()

    }
    
    func switchKeyboard(to: KeyboardState) {
        inputView = to != .normal ? formInputView : nil
        reloadInputViews()
    }
}
