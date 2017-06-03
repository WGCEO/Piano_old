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
    
    convenience init(frame: CGRect, memo: Memo) {
        self.init(frame: frame)
        
        self.memo = memo
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PNEditor.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PNEditor.keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PNEditor.keyboardDidHide(notification:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configure() {
        let textView = PianoTextView(frame: frame)
        
        textView.textContainerInset = UIEdgeInsetsMake(20, 25, 0, 25)
        textView.linkTextAttributes = [NSUnderlineStyleAttributeName: 1]
        textView.allowsEditingTextAttributes = true
        
        canvas.textView = textView
        
        self.textView = textView
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


