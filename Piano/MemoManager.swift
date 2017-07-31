//
//  MemoManager.swift
//  Piano
//
//  Created by dalong on 2017. 6. 2..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum Storage {
    case iCloud
    case coreData
    case cache
}

enum Interest {
    case memo
    case folder
    case none
}

typealias ChangeType = NSFetchedResultsChangeType

protocol Watchable: class {
    func Interests() -> [Interest]
    func update(at indexPath: IndexPath?, for type: ChangeType)
}

class MemoManager: NSObject {
    internal static let sharedInstance = MemoManager()
    
    internal var watchers: [Watchable] = []
    

//    static var currentMemo: Memo?
    

    
    static var memoes: [Memo] {
        return memoResultsController?.fetchedObjects ?? []
    }
    
    static var memoResultsController: NSFetchedResultsController<Memo>? {
        didSet {
            memoResultsController?.delegate = sharedInstance

            try? memoResultsController?.performFetch()
        }
    }
    
    static var noteResultsController: NSFetchedResultsController<Memo> = {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        request.predicate = NSPredicate(format: "isInTrash == false")
        let context = PianoData.coreDataStack.viewContext
        let dateSort = NSSortDescriptor(key: #keyPath(Memo.date), ascending: false)
        request.sortDescriptors = [dateSort]
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext:context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = sharedInstance
        return controller
    }()
    
    // MARK: read
    class func memo(at indexPath: IndexPath) -> Memo? {
        return memoResultsController?.object(at: indexPath)
    }

    class func sections() -> [NSFetchedResultsSectionInfo]? {
        return memoResultsController?.sections
    }

    class func fetchMemoes() {
        do {
            try memoResultsController?.performFetch()
        } catch {
            print("Error performing fetch \(error.localizedDescription)")
        }
    }
    

    

    
    // MARK: delete
    class func remove(_ memo: Memo, completion: ((Bool, Memo?) -> Void)?) {
        memo.isInTrash = true

        PianoData.save()

        completion?(true, memoes.first)
    }
    
    class func delete(_ memo: Memo, completion: (() -> Void)?) {
        PianoData.coreDataStack.viewContext.delete(memo)
        
        PianoData.save()
        
        completion?()
    }
    // MARK: create
//    class func newMemo() -> Memo {
//        //showAddFolderAlertIfNeeded()
//
//        let memo = Memo(context: PianoData.coreDataStack.viewContext)
//        memo.content = NSKeyedArchiver.archivedData(withRootObject: NSAttributedString())
//        memo.date = Date()
//        memo.folder = currentFolder
//        memo.firstLine = "NewMemo".localized(withComment: "새로운 메모")
//        PianoData.save()
//
//        currentMemo = memo
//
//        fetchMemoes()
//
//        return memo
//    }
    
    class func newFolder(_ name: String) -> Folder {
        let newFolder = Folder(context: PianoData.coreDataStack.viewContext)
        newFolder.name = name
        newFolder.date = NSDate()
        newFolder.memos = []

        PianoData.save()

        return Folder()
    }
    
//    class func showAddFolderAlertIfNeeded() {
//        if currentFolder == nil {
//            let alert = UIAlertController.makeAddFolderAlert({ (name) in
//                currentFolder = newFolder(name)
//            })
//
//            AppNavigator.present(alert)
//        }
//    }
    
    internal lazy var privateMOC: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = PianoData.coreDataStack.viewContext
        return moc
    }()
    
    internal var cache: [NSManagedObjectID: Memo] = [:]
    internal var temporary: [NSManagedObjectID: Memo] = [:]
}

// MARK: save data
extension MemoManager {
    class func save(_ memo: Memo) {
        sharedInstance.privateMOC.perform({
            sharedInstance.cache[memo.objectID] = memo
            
            do {
                // 저장
                try sharedInstance.privateMOC.save()
                PianoData.coreDataStack.viewContext.performAndWait({
                    savePermanently()
                    
                    sharedInstance.cache[memo.objectID] = nil
                })
            } catch {
                print("Failure to save context error: \(error)")
            }
        })
    }
    
    class func savePermanently() {
        do {
            try PianoData.coreDataStack.viewContext.save()
        } catch {
            print("Failure to save context: error: \(error)")
        }
    }
    
    class func saveAllNow() {
        for (id, value) in sharedInstance.temporary {
            do {
                let memo = try PianoData.coreDataStack.viewContext.existingObject(with: id) as! Memo
                let data = NSKeyedArchiver.archivedData(withRootObject: value)
                memo.content = data as NSData
                
            } catch {
                print("Failure to get existingObject: error: \(error)")
            }
        }
        
        sharedInstance.temporary.removeAll()
        
        savePermanently()
    }
}

// MARK: fetchedResultsControllerDelegate
extension MemoManager: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var interest: Interest
        switch anObject {
        case is Memo:
            interest = .memo
        case is Folder:
            interest = .folder
        default:
            interest = .none
        }
        
        for watcher in watchers {
            if watcher.Interests().contains(interest) {
                watcher.update(at: indexPath, for: type)
            }
        }
    }
}


// MARK: for watchers
extension MemoManager {
    class func regist(_ watcher: Watchable) {
        sharedInstance.watchers.append(watcher)
    }
    
    class func remove(_ watcher: Watchable) {
        let watchers = sharedInstance.watchers
        
        sharedInstance.watchers = watchers.filter { return !($0 === watcher) }
    }
}

enum StaticFolderName: Int {
    case A = 0
    case B
    case C
    case D
    case E
    case F
    case G
    
    func string() -> String {
        let note = String(describing: self)
        return "\(note) Note"
    }
}

// MARK: for migration
extension MemoManager {
    
    
    
    
}


