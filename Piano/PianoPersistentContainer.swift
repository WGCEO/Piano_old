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
        
        if let textView = self.textView, let memo = self.memo {
            
            if textView.attributedText.length == 0 {
                viewContext.delete(memo)
            } else {
                let data = NSKeyedArchiver.archivedData(withRootObject: textView.attributedText)
                memo.content = data
                memo.firstLine = textView.text.trimmingCharacters(in: CharacterSet.newlines)
            }
        }
        
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
    
}
