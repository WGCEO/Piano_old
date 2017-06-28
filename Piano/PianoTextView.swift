//
//  PianoTextView.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

protocol PianoTextViewDelegate {
    func textViewDidChange(_ textView: PianoTextView)
}

class PianoTextView: UITextView {
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
        return (isWaitingState == false)
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        textAlignment = .left
        attributedText = nil
        typingAttributes = [NSForegroundColorAttributeName: UIColor.piano,
                             NSUnderlineStyleAttributeName: 0,
                         NSStrikethroughStyleAttributeName: 0,
                            NSBackgroundColorAttributeName: UIColor.clear,
                                       NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)]
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
        updateCellInfo()
    }
    
    func removeSubrange(from: Int) {
        let range = NSMakeRange(from, selectedRange.location - from)
        layoutManager.textStorage?.deleteCharacters(in: range)
        selectedRange = NSRange(location: from, length: 0)
    }
    
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
        
        //detailViewController?.updateCellInfo() memo를 활용
        
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
            
            appearKeyboard()
        }
    }
    
    //첫번째 이미지 캐싱해놓고, 첫번째 attachment 이미지와 캐싱한 이미지가 다를 경우에만 실행
    func updateCellInfo() {
        let memo = MemoManager.currentMemo
        
        memo?.firstLine = getFirstLineText()
        
        let hasAttachments = attributedText.containsAttachments(in: NSMakeRange(0, attributedText.length))
        guard hasAttachments else {
            memo?.imageData = nil
            return
        }
        
        attributedText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, attributedText.length), options: []) { (value, range, stop) in
            guard let attachment = value as? NSTextAttachment,
                let image = attachment.image else { return }
            
            /*
            guard firstImage != image else {
                stop.pointee = true
                return
            }
            
            firstImage = image
            */
            
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
                memo?.imageData = data as NSData
                stop.pointee = true
            }
            
        }
    }
    
    // MARK: private methods
    private func tappedURL(textPosition: UITextPosition) -> URL? {
        guard let attrSubString = getAttrSubString(textPosition) else { return nil }
        
        let url = attrSubString.attribute(NSLinkAttributeName, at: 0, effectiveRange: nil) as? URL
        return url
    }
    
    private func getFirstLineText() -> String {
        let trim = self.text.trimmingCharacters(in: .symbols).trimmingCharacters(in: .newlines)
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


extension PianoTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        isEdited = true
        updateCellInfo()
    }
}

extension PianoTextView: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }
}

fileprivate extension UITextView {
    func getAttrSubString(_ textPosition: UITextPosition) -> NSAttributedString? {
        guard let position = position(from: textPosition, offset: 1),
            let range = textRange(from: textPosition, to: position) else { return nil }
        
        let startOffset = offset(from: beginningOfDocument, to: range.start)
        let endOffset = offset(from: beginningOfDocument, to: range.end)
        let offsetRange = NSMakeRange(startOffset, endOffset - startOffset)
        
        return attributedText.attributedSubstring(from: offsetRange)
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
