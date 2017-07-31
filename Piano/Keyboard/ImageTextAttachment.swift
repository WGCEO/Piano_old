//
//  ImageTextAttachment.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit


//이미지를 다시 그려야하는 지 여부:  bound와 비교
//어떻게 이미지를 다시 그려줄 건지 : options

class ImageAttachment: NSTextAttachment {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(image: UIImage) {
        super.init(data: nil, ofType: nil)
        
        let ratio = PianoGlobal.imageWidth / image.size.width
        if ratio < 1 {
            let size = image.size.applying(CGAffineTransform(scaleX: ratio, y: ratio))
            UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
            image.draw(in: CGRect(origin: CGPoint.zero, size: size))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.image = scaledImage
        } else {
            self.image = image
        }
    }
    
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        var scalingFactor: CGFloat = 1.0
        
        if let image = self.image {
            let imageSize: CGSize = image.size
            if lineFrag.width - (PianoGlobal.indent * 2) < imageSize.width {
                scalingFactor = (lineFrag.width - (PianoGlobal.indent * 2)) / imageSize.width
            }
            let rect = CGRect(x: PianoGlobal.indent, y: 0, width: imageSize.width * scalingFactor, height: imageSize.height * scalingFactor)
            return rect
        } else {
            return CGRect.zero
        }

        
    }
}
