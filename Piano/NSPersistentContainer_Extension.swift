//
//  NSPersistentContainer_Extension.swift
//  Piano
//
//  Created by kevin on 2016. 12. 15..
//  Copyright © 2016년 Piano. All rights reserved.
//

import CoreData
import UIKit

extension NSPersistentContainer {
    
    func checkCoreData() {
        do {
            let preferenceRequest: NSFetchRequest<Preference> = Preference.fetchRequest()
            let preferenceCount = try viewContext.count(for: preferenceRequest)
            if preferenceCount == 0 {
                let preference = Preference(context: viewContext)
                preference.isFirstLaunching = true
                preference.isPaidUser = true
            
            } else {
                guard let preference = try viewContext.fetch(preferenceRequest).first else { return }
                preference.isFirstLaunching = false
                preference.isPaidUser = true
            }
            
            
            let folderRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
            let folderCount = try viewContext.count(for: folderRequest)
            if folderCount == 0 {
                let pianoFolder = Folder(context: viewContext)
                pianoFolder.name = "Piano"
                pianoFolder.date = NSDate()
                
                let memo = Memo(context: viewContext)
                
                let content =  NSAttributedString(string: "PianoTutorial".localized(withComment: "피아노 튜토리얼 내용"), attributes: [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body), NSForegroundColorAttributeName : UIColor.piano])
                
                let data = NSKeyedArchiver.archivedData(withRootObject: content)
                
                memo.firstLine = content.string.trimmingCharacters(in: CharacterSet.newlines)
                memo.content = data as NSData
                memo.date = NSDate()
                memo.folder = pianoFolder
                
                pianoFolder.memos = [memo]
            }
            
            try viewContext.save()
        } catch {
            print("Error importing preference: \(error.localizedDescription)")
        }
    }
    
    func save() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
}
