//
//  PianoTextView.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

fileprivate let lineSpacing: CGFloat = 8.0

class PianoTextView: UITextView {
    internal var coverView: UIView?
    
    internal(set) var isEdited = false {
        didSet {
            if isEdited == true {
                editDate = NSDate()
            }
        }
    }
    var editDate: NSDate?
    
    var isWaitingState: Bool = false
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PianoTextView.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: public methods
    public func prepareForReuse() {
        isWaitingState = false
        isEdited = false
        clearText()
        
        contentOffset = CGPoint.zero
        
        resignFirstResponder()
    }
    
    public func makeTappable() {
        isEditable = false
        isSelectable = true
        isWaitingState = false
    }
    
    public func makeUnableTap() {
        isWaitingState = true
    }
    
    public func makeEffectable() {
        isEditable = false
        isSelectable = false
        isWaitingState = true
    }
    
    public func appearKeyboard(){
        isSelectable = true
        isEditable = true
        becomeFirstResponder()
    }
    
    private func clearText() {
        //textAlignment = .left
        attributedText = nil
        typingAttributes = [NSForegroundColorAttributeName: UIColor.piano,
                             NSUnderlineStyleAttributeName: 0,
                         NSStrikethroughStyleAttributeName: 0,
                            NSBackgroundColorAttributeName: UIColor.clear,
                                       NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)]
    }
    
    public func didEdited() {
        isEdited = true
    }
    
    public func cover(_ rect: CGRect) {
        uncover()
        
        let coverView = UIView()
        coverView.backgroundColor = UIColor.white
        
        let left = textContainerInset.left + textContainer.lineFragmentPadding
        let top = textContainerInset.top
        coverView.frame = rect.offsetBy(dx: left, dy: top)
        
        addSubview(coverView)
        
        self.coverView = coverView
    }
    
    public func uncover() {
        coverView?.removeFromSuperview()
        coverView = nil
    }
    
    public func addImage(_ image: UIImage) {
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        let range = selectedRange
        
        let ratio = (textContainer.size.width - 10) / image.size.width
        guard let scaledImage = image.scaledImage(ratio: ratio) else { return }
        
        attributedString.insertImage(scaledImage, in: range)
        
        attributedText = attributedString
        
        didUpdateText(in: range)
    }

    /* To Remove
    public func eraseCurrentLine() {
        guard selectedRange.location != 0 else { return }
        
        let beginning: UITextPosition = beginningOfDocument
        var offset = selectedRange.location
        
        while true {
            if offset == 0 {
                removeSubrange(from: offset)
                break
            }
            
            guard let start = position(from: beginning, offset: offset - 1),
                let end = position(from: beginning, offset: offset),
                let textRange = textRange(from: start, to: end),
                let text = text(in: textRange) else { return }
            
            let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
            let range = text.rangeOfCharacter(from: whitespacesAndNewlines)
            
            if range == nil {
                removeSubrange(from: offset-1)
                break
            }
            
            offset -= 1
        }
        
        isEdited = true
        textChangedHandler?(attributedText)
    }
    
    private func removeSubrange(from: Int) {
        let range = NSMakeRange(from, selectedRange.location - from)
        layoutManager.textStorage?.deleteCharacters(in: range)
        selectedRange = NSRange(location: from, length: 0)
     }
     */
    
    // MARK: - private methods
    private func didUpdateText(in range: NSRange) {
        selectedRange =
            NSMakeRange(range.location+2, range.length)
        appearKeyboard()
        makeTappable()
        
        DispatchQueue.main.async { [weak self] in
            if let location = self?.selectedRange.location {
                self?.scrollRangeToVisible(NSMakeRange(location + 3, 0))
            }
        }
     }
    
    private func tappedURL(textPosition: UITextPosition) -> URL? {
        guard let attrSubString = getAttrSubString(textPosition) else { return nil }
        
        return attrSubString.attribute(NSLinkAttributeName, at: 0, effectiveRange: nil) as? URL
    }
    
    private func getAttrSubString(_ textPosition: UITextPosition) -> NSAttributedString? {
        guard let position = position(from: textPosition, offset: 1),
            let range = textRange(from: textPosition, to: position) else { return nil }
        
        let startOffset = offset(from: beginningOfDocument, to: range.start)
        let endOffset = offset(from: beginningOfDocument, to: range.end)
        let offsetRange = NSMakeRange(startOffset, endOffset - startOffset)
        
        return attributedText.attributedSubstring(from: offsetRange)
    }
    
    // MARK: UIResponder
    override func paste(_ sender: Any?) {
        super.paste(sender)
        
        attributedText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, attributedText.length), options: []) { (value, range, stop) in
            guard let attachment = value as? NSTextAttachment else { return }
            
            if let regularFile = attachment.fileWrapper?.regularFileContents,
                let image = UIImage(data: regularFile) {
                let oldWidth = image.size.width
                let ratio = (textContainer.size.width - 10) / oldWidth
                let size = image.size.applying(CGAffineTransform(scaleX: ratio, y: ratio))
                UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
                image.draw(in: CGRect(origin: CGPoint.zero, size: size))
                let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                attachment.bounds.size = size
                attachment.image = scaledImage
            }
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.scrollRangeToVisible(self.selectedRange)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        
        let location = firstTouch.location(in: self)
        
        guard let textPosition = closestPosition(to: location) else {
            appearKeyboard()
            return
        }
        
        let textLocation = offset(from: beginningOfDocument, to: textPosition)
        
        selectedRange = NSMakeRange(textLocation, 0)
        
        
        if let attr = textStyling(at: textPosition, in: .forward), let url = attr[NSLinkAttributeName] as? URL {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        if let url = tappedURL(textPosition: textPosition) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            appearKeyboard()
        }
    }
}


// MARK: keyboard
extension PianoTextView {
    internal func keyboardWillShow(notification: Notification){
        isWaitingState = true
        
        guard let userInfo = notification.userInfo,
            let kbFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
            let height = AppNavigator.currentNavigationController?.toolbar.bounds.height else { return }
        
        
        //kbFrame의 y좌표가 실제로 키보드의 위치임 따라서 화면 높이에서 프레임 y를 뺸 게 바텀이면 됨!
        let inset = UIEdgeInsetsMake(0, 0, UIScreen.main.bounds.height - kbFrame.origin.y - height, 0)
        contentInset = inset
        scrollIndicatorInsets = inset
        scrollRangeToVisible(selectedRange)
    }
}

extension PianoTextView: NSLayoutManagerDelegate {
    
    // MARK: - Handling Line Fragments
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return lineSpacing
    }
}

public extension NSAttributedString {
    var firstLine: String {
        let trim = string.trimmingCharacters(in: .symbols).trimmingCharacters(in: .newlines)
        switch trim {
        case let x where x.characters.count > 50:
            return x.substring(to: x.index(x.startIndex, offsetBy: 50))
        case let x where x.characters.count == 0:
            //이미지만 있는 경우에도 해당됨
            return "NewMemo".localized(withComment: "새로운 메모")
        default:
            return trim
        }
    }
}

fileprivate extension NSMutableAttributedString {
    func insertImage(_ image: UIImage, in range: NSRange) {
        let textAttachment = NSTextAttachment()
        textAttachment.image = image
        
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        let spaceString = NSAttributedString(string: "\n", attributes: [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body)])
        
        insert(attrStringWithImage, at: range.location)
        insert(spaceString, at: range.location + 1)
        addAttributes([NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)], range: NSMakeRange(range.location, 2))
    }
}

fileprivate extension UIImage {
    func scaledImage(ratio: CGFloat) -> UIImage? {
        let size = self.size.applying(CGAffineTransform(scaleX: ratio, y: ratio))
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
