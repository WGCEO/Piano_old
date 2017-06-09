//
//  AppNavigator.swift
//  Piano
//
//  Created by dalong on 2017. 6. 2..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

class AppNavigator {
    static var currentViewController: UIViewController? {
        let window = UIApplication.shared.keyWindow
        
        if let navigationController = window?.rootViewController as? UINavigationController {
            return navigationController.presentedViewController
        } else {
            return window?.rootViewController
        }
    }
    
    class func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        currentViewController?.present(viewController, animated: animated, completion: completion)
    }
}
