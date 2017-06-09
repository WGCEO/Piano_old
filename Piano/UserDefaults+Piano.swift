//
//  UserDefaults+Piano.swift
//  Piano
//
//  Created by dalong on 2017. 6. 9..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation

extension UserDefaults {
    static var hasShownTrashAlert: Bool {
        guard UserDefaults.standard.bool(forKey: "hasShownTrashAlert") else {
            UserDefaults.standard.set(true, forKey: "hasShownTrashAlert")
            return false
        }
        return true
    }
}
