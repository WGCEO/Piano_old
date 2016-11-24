//
//  ISReusableView.swift
//  iamschool
//
//  Created by 김찬기 on 2016. 7. 7..
//  Copyright © 2016년 iamcompany. All rights reserved.
//

import UIKit

protocol Reusable {}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
