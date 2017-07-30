//
//  NoteManager.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 30..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import CoreData

class NoteManager {
    static let sharedInstance = NoteManager()
    
    lazy var currentNote: Memo? = {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        request.predicate = NSPredicate(format: "isInTrash == true")
        request.fetchLimit = 1
        let context = PianoData.coreDataStack.viewContext
        let dateSort = NSSortDescriptor(key: #keyPath(Memo.date), ascending: false)
        request.sortDescriptors = [dateSort]
        do {
            let note = try context.fetch(request)
            return note.first
        } catch {
            print("에러")
            return nil
        }
    }()
}

extension NoteManager: FolderChangeable {
    func changeFolder(to: Int) {
        NoteManager.sharedInstance.currentNote?.priority = Int16(to)
    }

}
