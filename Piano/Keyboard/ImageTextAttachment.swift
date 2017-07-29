//
//  ImageTextAttachment.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class ImageTextAttachment: NSTextAttachment {
    let originalImage: UIImage
    
    init(originalImage: UIImage) {
        self.originalImage = originalImage
        super.init(data: nil, ofType: nil)
        
        let ratio = UIScreen.main.bounds.width / originalImage.size.width //textContainer.size.width - 60
        let size = originalImage.size.applying(CGAffineTransform(scaleX: ratio, y: ratio))
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        originalImage.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        image = scaledImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
