//
//  PianoData.swift
//  Piano
//
//  Created by kevin on 2017. 1. 4..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import CoreData

struct PianoData {
    static let coreDataStack : PianoPersistentContainer = {
        let container = PianoPersistentContainer.sharedInstance
        
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error creating persistent stores: \(error.localizedDescription)")
                fatalError()
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.checkCoreData()
        
        return container
    }()
    
    static func deleteMemosIfPassOneMonth() {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        request.predicate = NSPredicate(format: "isInTrash == true AND date < %@", NSDate(timeIntervalSinceNow: -3600 * 24 * 30))
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
        batchDelete.affectedStores = PianoData.coreDataStack.viewContext.persistentStoreCoordinator?.persistentStores
        batchDelete.resultType = .resultTypeCount
        do {
            let _ = try PianoData.coreDataStack.viewContext.execute(batchDelete) as! NSBatchDeleteResult
//            print("record deleted \(batchResult.result)")
        } catch {
            print("could not delete \(error.localizedDescription)")
        }
    }
    
    static func save() {
        PianoData.coreDataStack.save()
    }
}
