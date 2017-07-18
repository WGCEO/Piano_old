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
    
    
    
    
//    func mirgrateVersionTwo() {
//        do {
//            let preferenceRequest: NSFetchRequest<Preference> = Preference.fetchRequest()
//            let preferenceCount = try viewContext.count(for: preferenceRequest)
//            
//            //아예 맨처음
//            if preferenceCount == 0 {
//                let preference = Preference(context: viewContext)
//                preference.version = 2
//            
//            } else {
//                guard let preference = try viewContext.fetch(preferenceRequest).first else { return }
//                
//                if preference.version != 2 {
//                    //여기서 마이그레이션 진행
//                    print("여기서 마이그레이션 진행")
//                    migrateFolders()
//                    preference.version = 2
//                }
//            }
//            
//        
//            
//            
//            let folderRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
//            let folderCount = try viewContext.count(for: folderRequest)
//            if folderCount == 0 {
//                let pianoFolder = Folder(context: viewContext)
//                pianoFolder.name = "Piano"
//                pianoFolder.date = Date()
//                
//                let memo = Memo(context: viewContext)
//                
//                let content =  NSAttributedString(string: "PianoTutorial".localized(withComment: "피아노 튜토리얼 내용"), attributes: [NSAttributedStringKey.font : UIFont.preferredFont(forTextStyle: .body), NSAttributedStringKey.foregroundColor : UIColor.piano])
//                
//                let data = NSKeyedArchiver.archivedData(withRootObject: content)
//                
//                memo.firstLine = content.string.trimmingCharacters(in: CharacterSet.newlines)
//                memo.content = data
//                memo.date = Date()
//                memo.folder = pianoFolder
//                
//                pianoFolder.memos = [memo]
//            }
//            
//            try viewContext.save()
//        } catch {
//            print("Error importing preference: \(error.localizedDescription)")
//        }
//    }
//    
//    private func migrateFolders(){
//        do {
//            let folderRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
//            let folderCount = try viewContext.count(for: folderRequest)
//            
//            if folderCount != 0 {
//                
//            }
//            
//        } catch {
//            
//        }
//        
//        
//    }
    
    func save() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
}
