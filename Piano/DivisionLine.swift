//
//  DivisionLine.swift
//  Piano
//
//  Created by dalong on 2017. 7. 26..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    class func makeDivisionLine(with size: CGSize) -> UIImage {
        let color = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.15)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let rectangle = CGRect(x: 0, y: round(size.height/2), width: size.width, height: 1)
        
        color.setFill()
        UIRectFill(rectangle)
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if let image = image {
            return image
        }
        
        return UIImage()
    }
}
