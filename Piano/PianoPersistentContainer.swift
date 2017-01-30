//
//  PianoPersistentContainer.swift
//  Piano
//
//  Created by kevin on 2016. 12. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit
import CoreData

class PianoPersistentContainer: NSPersistentContainer {
    
    weak var detailViewController: DetailViewController?
    
    func saveDisplayMemo() {
        detailViewController?.saveCoreDataIfNeed()
    }
}
