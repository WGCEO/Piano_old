//
//  UIViewController_Extension.swift
//  Piano
//
//  Created by kevin on 2017. 1. 29..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var isVisible: Bool {
        get {
            return self.isViewLoaded && self.view.window != nil
        }
    }
}
