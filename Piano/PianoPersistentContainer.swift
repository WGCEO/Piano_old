//
//  PianoPersistentContainer.swift
//  Piano
//
//  Created by kevin on 2016. 12. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit
import CoreData

class PianoPersistentContainer: NSPersistentContainer {
    
    weak var textView: UITextView?
    weak var memo: Memo?
    
    func saveContext() {
        
        if let textView = self.textView, let memo = self.memo {
            
            if textView.attributedText.length == 0 {
                viewContext.delete(memo)
            } else {
                let data = NSKeyedArchiver.archivedData(withRootObject: textView.attributedText)
                memo.content = data as NSData
                setFirstLineAndImage()
            }
        }
        
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
    
    func setFirstLineAndImage() {
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
            firstLine = "새로운 메모"
        default:
            firstLine = text
        }
        
        memo.firstLine = firstLine
        
        let hasAttachments = attrText.containsAttachments(in: NSMakeRange(0, attrText.length))
        
        guard hasAttachments else {
            memo.imageData = nil
            return
        }
        
        if memo.imageData == nil {
            attrText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, attrText.length), options: []) { (value, range, stop) in
                
                guard let attachment = value as? NSTextAttachment,
                    let image = attachment.image else { return }
                
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
        }
    }
    
}
