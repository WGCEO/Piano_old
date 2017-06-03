//
//  ActivityIndicator.swift
//  Piano
//
//  Created by dalong on 2017. 6. 2..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

class ActivityIndicator {
    static var sharedInstace = UIActivityIndicatorView()
    
    var canDoAnotherTask: Bool {
        return ActivityIndicator.sharedInstace.isAnimating
    }
    
    // TODO: 현재 뷰 위에 띄우도록 변경
    class func startAnimating() {
        sharedInstace.removeFromSuperview()
        
        ActivityIndicator.sharedInstace.startAnimating()
    }
    
    class func stopAnimating() {
        sharedInstace.removeFromSuperview()
        
        ActivityIndicator.sharedInstace.stopAnimating()
    }
}
