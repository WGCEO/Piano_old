//
//  ImageTextAttachment.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

enum TextAttachmentOption {
    case flexibleWidth
    case flexibleHeight
    case fixedHeight
}

class ImageTextAttachment: NSTextAttachment {
    
    var imageHashValue : Int?
    var options: [TextAttachmentOption] = [.flexibleWidth]
    let bound = UIScreen.main.bounds
    override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        
        if bound.width != UIScreen.main.bounds.width {
            //다르면 코어데이터에서 이미지를 가져와서 함1. 이미지에 대입하고, 2. 동시에 이미지를 리턴해야함
            print("다르면 코어데이터에서 이미지를 가져와서 함1. 이미지에 대입하고, 2. 동시에 이미지를 리턴해야함")
            return nil
        } else {
            return super.image(forBounds: imageBounds, textContainer: textContainer, characterIndex: charIndex)
        }
    }
    
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        print("attachmentBounds")
        if options.contains(.flexibleHeight) {
            
        }
        let width: CGFloat = lineFrag.size.width
        var scalingFactor: CGFloat = 1.0
        
        if let img = self.image {
            
            let imageSize:CGSize  = img.size
            
            if (width < imageSize.width) {
                scalingFactor = width / imageSize.width;
            }
            let rect = CGRect(x: 0, y: 0, width: imageSize.width * scalingFactor, height: imageSize.height * scalingFactor)
            return rect;
        } else {
            let rect = CGRect(x: 0, y: 0, width: width, height: width)
            return rect;
        }
    }
}
