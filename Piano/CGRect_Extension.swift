//
//  CGRect_Extension.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

extension CGRect {
    
    mutating func move(x: CGFloat, y: CGFloat) {
        self.origin.x += x
        self.origin.y += y
    }
}
