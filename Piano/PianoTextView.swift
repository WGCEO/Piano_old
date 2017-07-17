//
//  PianoTextView.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class PianoTextView: UITextView {
    private var coverView: UIView?
    
    //MARK: init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setValuesForText()
        keyboard(listen: true)
    }
    
    deinit {
        keyboard(listen: false)
    }
    
    //MARK:
    public var control = PianoControl()
    
    private func setValuesForText(){
        textContainer.lineFragmentPadding = 0
        textContainerInset = UIEdgeInsetsMake(10, 10, 0, 10)
        contentInset = UIEdgeInsetsMake(PianoGlobal.navigationBarHeight,
                                        0,
                                        PianoGlobal.toolBarHeight,
                                        0)
    }
    
    private func keyboard(listen: Bool){
        if listen {
            NotificationCenter.default.addObserver(self, selector: #selector(PianoTextView.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(PianoTextView.keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
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
        let final = result.final.move(x: -textContainerInset.left, y: 0)
        let farLeft = result.farLeft.move(x: -textContainerInset.left, y: 0)
        let farRight = result.farRight.move(x: -textContainerInset.left, y: 0)
        
        let applyRange = getRangeForApply(farLeft: farLeft, final: final)
        if applyRange.length > 0 {
            
            layoutManager.textStorage?.addAttributes(result.applyAttribute, range: applyRange)
        }
        
        let removeRange = getRangeForRemove(final: final, farRight: farRight)
        if removeRange.length > 0 {
            let mutableAttrText = NSMutableAttributedString(attributedString: attributedText)
            mutableAttrText.addAttributes(result.removeAttribute, range: removeRange)
            attributedText = mutableAttrText
            layoutManager.textStorage?.addAttributes(result.removeAttribute, range: removeRange)
        }
        
        setOffsetForPreventBug()
    }
}

extension PianoTextView {
    @objc internal func keyboardWillShow(notification: Notification){
        
        guard let userInfo = notification.userInfo,
            let kbFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            else { return }
        
        let bottom = UIScreen.main.bounds.height - kbFrame.origin.y + 50
        contentInset.bottom = bottom
        scrollIndicatorInsets.bottom = bottom
        scrollRangeToVisible(selectedRange)
    }
    
    @objc internal func keyboardWillHide(notification: Notification){
        contentInset.bottom = PianoGlobal.toolBarHeight
        scrollIndicatorInsets.bottom = PianoGlobal.toolBarHeight
        setOffsetForPreventBug()
    }
}

extension PianoTextView: Effectable {
    
    func preparePiano(from point: CGPoint) -> (() -> PianoViewData) {
        return { [weak self] in
            guard let strongSelf = self
                else {
                    return PianoViewData(rect: CGRect.zero, labelInfos: [])
            }
            
            let relativePoint = point.move(x: 0, y: strongSelf.contentOffset.y + strongSelf.contentInset.top + strongSelf.textContainerInset.top)
            
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
    func insert(form: UIImage) {
        //
    }
    
    func insert(image: UIImage, localIdentifier: String) {
        
        let attachment = ImageTextAttachment(localIdentifier: localIdentifier)
        attachment.image = resizeToFitIndent(image: image)
        let attrString = NSAttributedString(attachment: attachment)
        let enterAttrText = NSMutableAttributedString(string: "\n")
        
        let mutableAttrText = NSMutableAttributedString(attributedString: enterAttrText)
        mutableAttrText.append(attrString)
        mutableAttrText.append(enterAttrText)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 30
        paragraphStyle.headIndent = 30
        paragraphStyle.tailIndent = -30
        paragraphStyle.lineSpacing = 10
        
        let font = UIFont.systemFont(ofSize: PianoGlobal.fontSize)
        let fontColor = PianoGlobal.defaultColor
        
        mutableAttrText.addAttributes([.paragraphStyle : paragraphStyle,
                                       .font : font,
                                       .foregroundColor : fontColor],
                                      range: NSMakeRange(1, mutableAttrText.length - 1))
        
        let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)
        mutableAttrString.insert(mutableAttrText, at: selectedRange.location)
        attributedText = mutableAttrString
    }
    
    func resizeToFitIndent(image: UIImage) -> UIImage? {
        let imageWidth = image.size.width
        let ratio = (textContainer.size.width - 60) / imageWidth;
        
        let size = image.size.applying(CGAffineTransform(scaleX: ratio, y: ratio))
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}
