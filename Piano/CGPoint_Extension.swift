//
//  CGPoint_Extension.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 28..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

extension CGPoint {
    
    mutating func move(x: CGFloat, y: CGFloat) {
        self.x = self.x + x
        self.y = self.y + y
    }
}
