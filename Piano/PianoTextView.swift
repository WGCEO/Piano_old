//
//  PianoTextView.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class PianoTextView: UITextView {
    private var memo: Memo?
    
    var isWaitingState: Bool = false
    var isEdited = false
    var mode: TextViewMode = .typing
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: public methods
    public func prepareForReuse() {
        isWaitingState = false
        isEdited = false
        mode = .typing
        clearTextView()
        
        contentOffset = CGPoint.zero
    }
    
    private func clearTextView() {
        textAlignment = .left
        attributedText = nil
        typingAttributes = [NSForegroundColorAttributeName: UIColor.piano,
                             NSUnderlineStyleAttributeName: 0,
                         NSStrikethroughStyleAttributeName: 0,
                            NSBackgroundColorAttributeName: UIColor.clear,
                                       NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)]
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
    
    // MARK: private methods
    private func tappedURL(textPosition: UITextPosition) -> URL? {
        guard let attrSubString = getAttrSubString(textPosition) else { return nil }
        
        let url = attrSubString.attribute(NSLinkAttributeName, at: 0, effectiveRange: nil) as? URL
        return url
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return isWaitingState ? false : true
        }
    }
    
    func makeTappable() {
        isEditable = false
        isSelectable = true
        isWaitingState = false
        mode = .typing
    }
    
    func makeUnableTap() {
        isWaitingState = true
    }
    
    
    func makeEffectable() {
        isEditable = false
        isSelectable = false
        isWaitingState = true
        mode = .effect
    }

    func appearKeyboard(){
        isSelectable = true
        isEditable = true
        becomeFirstResponder()
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
