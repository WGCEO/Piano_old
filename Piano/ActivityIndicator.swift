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
    static var sharedIndicator: UIActivityIndicatorView = {
        let mainScreen = UIScreen.main.bounds
        let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        activityIndicatorView.center = CGPoint(x: mainScreen.midX, y: mainScreen.midY)
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.hidesWhenStopped = true
        
        UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
        
        return activityIndicatorView
    }()
    
    var canDoAnotherTask: Bool {
        return ActivityIndicator.sharedIndicator.isAnimating
    }
    
    public class func startAnimating() {
        if sharedIndicator.isAnimating {
            return
        }
        
        UIApplication.shared.keyWindow?.bringSubview(toFront: sharedIndicator)
        
        let mainScreen = UIScreen.main.bounds
        sharedIndicator.center = CGPoint(x: mainScreen.midX, y: mainScreen.midY)
        sharedIndicator.activityIndicatorViewStyle = .gray
        
        sharedIndicator.startAnimating()
    }
    
    public class func stopAnimating() {
        sharedIndicator.stopAnimating()
    }
}
