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

@objc class PNEditor: UIView {
    var textView: PianoTextView!
    var canvas = PianoControl()
    
    var delayAttrDic: [NSManagedObjectID : NSAttributedString] = [:]
    
    public var memo: Memo? {
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
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRect.zero)
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
    
    // MARK: public methods
    func appearKeyboardIfNeeded() {
        textView.isWaitingState = false
        
        //TODO: 코드 리펙토링제대로하기
        //textView.isWaitingState = false
        //appearKeyboardIfNeeded()
        //appearKeyboardIfNeeded = { }
    }
    
    func prepareToEditing() { // from detailVC.viewWillTransition
        if textView.mode != .typing {
            attachCanvas()
        }
    }
    
    // MARK: palette view
    func showTopView(bool: Bool) {
        /*
         guard let textViewTop = self.textViewTop, let topView = self.topView else { return }
         if bool {
         textView.makeEffectable()
         } else {
         textView.makeTappable()
         }
         
         //탑 뷰의 현재 상태와 반대될 때에만 아래의 뷰 애니메이션 코드 실행
         guard bool == topView.isHidden else { return }
         
         topView.isHidden = bool ? false : true
         navigationController?.setNavigationBarHidden(bool, animated: true)
         navigationController?.setToolbarHidden(bool, animated: true)
         UIView.animate(withDuration: 0.3) { [unowned self] in
         self.textView.contentInset.bottom = bool ? 50 : 0
         textViewTop.constant = bool ? 100 : 0
         self.view.layoutIfNeeded()
         }
         */
    }
    
    // MARK: textView
    func setTextView(with memo: Memo?) {
        /*
         guard let editor = editor else { return }
         unwrapTextView.isEdited = false
         
         //스크롤 이상하게 되는 것 방지
         unwrapTextView.contentOffset = CGPoint.zero
         
         guard let unwrapNewMemo = memo else {
         resetTextViewAttribute()
         return }
         
         let haveTextInDelayAttrDic = delayAttrDic.contains { [unowned self](key, value) -> Bool in
         if unwrapNewMemo.objectID == key {
         unwrapTextView.attributedText = value
         let selectedRange = NSMakeRange(unwrapTextView.attributedText.length, 0)
         unwrapTextView.selectedRange = selectedRange
         if unwrapTextView.attributedText.length == 0 {
         self.resetTextViewAttribute()
         if self.isVisible {
         unwrapTextView.appearKeyboard()
         } else {
         self.appearKeyboardIfNeeded = { unwrapTextView.appearKeyboard() }
         }
         }
         
         return true
         } else {
         return false
         }
         }
         
         guard !haveTextInDelayAttrDic else { return }
         
         let attrText = NSKeyedUnarchiver.unarchiveObject(with: unwrapNewMemo.content! as Data) as? NSAttributedString
         PianoData.coreDataStack.viewContext.performAndWait({
         unwrapTextView.attributedText = attrText
         let selectedRange = NSMakeRange(unwrapTextView.attributedText.length, 0)
         unwrapTextView.selectedRange = selectedRange
         
         if unwrapTextView.attributedText.length == 0 {
         self.resetTextViewAttribute()
         if self.isVisible {
         unwrapTextView.appearKeyboard()
         } else {
         self.appearKeyboardIfNeeded = { unwrapTextView.appearKeyboard() }
         }
         }
         })
         */
    }
    
    
    func resetTextViewAttribute(){
        /*
         guard let unwrapTextView = textView else { return }
         unwrapTextView.textAlignment = .left
         let attrText = NSAttributedString()
         unwrapTextView.attributedText = attrText
         unwrapTextView.typingAttributes = [NSForegroundColorAttributeName: UIColor.piano,
         NSUnderlineStyleAttributeName : 0,
         NSStrikethroughStyleAttributeName: 0,
         NSBackgroundColorAttributeName : UIColor.clear,
         NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body)
         ]
         */
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
    
    func setTextViewEditedState() {
        //textView.isEdited = true
        //memo?.date = NSDate()
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


