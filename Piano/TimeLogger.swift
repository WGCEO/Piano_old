//
//  TimeLogger.swift
//  Piano
//
//  Created by dalong on 2017. 8. 6..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation

class TimeLogger {
    public static let sharedInstance = TimeLogger()
    
    private var starts: [AnyHashable: TimeInterval] = [:]
    private var ends: [AnyHashable: TimeInterval] = [:]
    
    public func start(with key: AnyHashable) {
        starts[key] = TimeInterval(Date().timeIntervalSince1970)
    }
    
    public func end(with key: AnyHashable) -> TimeInterval{
        ends[key] = TimeInterval(Date().timeIntervalSince1970)
        
        return interval(with: key)
    }
    
    public func interval(with key: AnyHashable) -> TimeInterval {
        guard let start = starts[key],
            let end = ends[key] else { return -1 }
        
        let intervalTime = (end - start)
        
        return intervalTime
    }
}
