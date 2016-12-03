//
//  CGPoint_Extension.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 28..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

extension CGPoint {
    
    func move(x: CGFloat, y: CGFloat) -> CGPoint{
        return CGPoint(x: self.x + x, y: self.y + y)
    }
}
