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
                memo.content = data as NSData
                setFirstLine()
            }
        }
        
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
    
    func setFirstLine() {
        guard let memo = self.memo, let textView = self.textView else { return }
        
        let text = textView.text.trimmingCharacters(in: .symbols).trimmingCharacters(in: .newlines)
        let firstLine: String
        switch text {
        case let x where x.characters.count > 50:
            firstLine = x.substring(to: x.index(x.startIndex, offsetBy: 50))
        case let x where x.characters.count == 0:
            //이미지만 있는 경우에도 해당됨
            firstLine = "새로운 메모"
        default:
            firstLine = text
        }
        
        memo.firstLine = firstLine
    }
    
}
