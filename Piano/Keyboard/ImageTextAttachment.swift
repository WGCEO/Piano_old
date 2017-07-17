//
//  ImageTextAttachment.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class ImageTextAttachment: NSTextAttachment {
    let localIdentifier: String
    
    init(localIdentifier: String) {
        self.localIdentifier = localIdentifier
        super.init(data: nil, ofType: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
