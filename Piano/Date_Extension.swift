//
//  Date_Extension.swift
//  Piano
//
//  Created by kevin on 2016. 12. 30..
//  Copyright © 2016년 Piano. All rights reserved.
//

import Foundation

extension Date {}

public func <=(lhs: Date, rhs: Date) -> Bool {
    return (lhs.compare(rhs) == .orderedAscending) || (lhs.compare(rhs) == .orderedSame)
}

public func <(lhs: Date, rhs: Date) -> Bool {
    return (lhs.compare(rhs) == .orderedAscending)
}
