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
    
    weak var textView: UITextView?
    weak var memo: Memo?
    
    func saveContext() {
        
        if let textview = self.textView, let memo = self.memo {
            let data = NSKeyedArchiver.archivedData(withRootObject: textview.attributedText)
            memo.content = data
        }
        
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }

}
