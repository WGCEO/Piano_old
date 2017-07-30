//
//  ImageTextAttachment.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class ImageTextAttachment: NSTextAttachment {
    
    var imageHashValue : Int?
    
//    override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
//        <#code#>
//    }
    
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        
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
