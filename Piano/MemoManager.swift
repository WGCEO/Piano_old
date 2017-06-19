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
    private static let sharedInstance = MemoManager()
    
    internal var watchers: [Watchable] = []
    
    static var currentFolder: Folder? {
        didSet {
            let request: NSFetchRequest<Memo> = Memo.fetchRequest()
            request.predicate = NSPredicate(format: "isInTrash == false AND folder = %@", currentFolder ?? " ")
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Memo.date), ascending: false)]
            
            let context = PianoData.coreDataStack.viewContext
            
            memoResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext:context, sectionNameKeyPath: nil, cacheName: nil)
        }
    }
    static var currentMemo: Memo?
    
    static var folders: [Folder] {
        if folderResultsController.fetchedObjects == nil {
            do {
                try folderResultsController.performFetch()
            } catch {
                print("Error performing fetch \(error.localizedDescription)")
            }
        }
        
        return folderResultsController.fetchedObjects ?? []
    }
    
    static var memoes: [Memo] {
        return memoResultsController?.fetchedObjects ?? []
    }
    
    static var folderResultsController: NSFetchedResultsController<Folder> = {
        let context = PianoData.coreDataStack.viewContext
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        let dateSort = NSSortDescriptor(key: #keyPath(Folder.date), ascending: true)
        request.sortDescriptors = [dateSort]
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext:context,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }()
    
    static var memoResultsController: NSFetchedResultsController<Memo>? {
        didSet {
            memoResultsController?.delegate = sharedInstance
            
            try? memoResultsController?.performFetch()
        }
    }

    static var cache: [String:Memo] = [:]
    
    // MARK: public methods
    class func regist(_ watcher: Watchable) {
        sharedInstance.watchers.append(watcher)
    }
    
    class func remove(_ watcher: Watchable) {
        let watchers = sharedInstance.watchers
        
        sharedInstance.watchers = watchers.filter { return !($0 === watcher) }
    }
    
    class func getMemo(at index: Int, in folder: Folder? = nil) -> Memo? {
        // 임시
        return Memo()
    }
    
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
    
    class func fetchFolders() {
        do {
            try folderResultsController.performFetch()
        } catch {
            print("Error performing fetch \(error.localizedDescription)")
        }
    }
    
    // for cache?
    class func getMemo(key: String) -> Memo? {
        
        return cache[key]
    }
    
    class func selectedMemo() -> Memo? {
        // 임시
        return Memo()
    }
    
    
    class func remove(_ memo: Memo, completion: ((Bool, Memo?) -> Void)?) {
        memo.isInTrash = true
        
        PianoData.save()
        
        let first = getMemo(at: 0, in: memo.folder)
        
        completion?(true, first)
    }
    
    
    class func newMemo() -> Memo {
        //showAddFolderAlertIfNeeded()
        
        let memo = Memo(context: PianoData.coreDataStack.viewContext)
        memo.content = NSKeyedArchiver.archivedData(withRootObject: NSAttributedString()) as NSData
        memo.date = NSDate()
        memo.folder = currentFolder
        memo.firstLine = "NewMemo".localized(withComment: "새로운 메모")
        PianoData.save()
         
        currentMemo = memo
        
        fetchMemoes()
        
        return memo
    }
    
    class func newFolder(_ name: String) -> Folder {
        let newFolder = Folder(context: PianoData.coreDataStack.viewContext)
        newFolder.name = name
        newFolder.date = NSDate()
        newFolder.memos = []
        
        PianoData.save()

        return Folder()
    }
    
    class func showAddFolderAlertIfNeeded() {
        if currentFolder == nil {
            let alert = UIAlertController.makeAddFolderAlert({ (name) in
                currentFolder = newFolder(name)
            })
            
            AppNavigator.present(alert)
        }
    }
    
    
    /*
     lazy var privateMOC: NSManagedObjectContext = {
     let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
     moc.parent = PianoData.coreDataStack.viewContext
     return moc
     }()
     */
    
    class func saveCoreDataIfNeeded(){
        /*
         guard let unwrapTextView = textView,
         let unwrapOldMemo = memo,
         unwrapTextView.isEdited else { return }
         
         if unwrapTextView.attributedText.length != 0 {
         let copyAttrText = unwrapTextView.attributedText.copy() as! NSAttributedString
         
         privateMOC.perform({ [unowned self] in
         self.delayAttrDic[unwrapOldMemo.objectID] = copyAttrText
         let data = NSKeyedArchiver.archivedData(withRootObject: copyAttrText)
         unwrapOldMemo.content = data as NSData
         do {
         try self.privateMOC.save()
         PianoData.coreDataStack.viewContext.performAndWait({
         do {
         try PianoData.coreDataStack.viewContext.save()
         //지연 큐에서 제거해버리기
         self.delayAttrDic[unwrapOldMemo.objectID] = nil
         } catch {
         print("Failure to save context: error: \(error)")
         }
         })
         } catch {
         print("Failture to save context error: \(error)")
         }
         })
         
         } else {
         PianoData.coreDataStack.viewContext.delete(unwrapOldMemo)
         PianoData.save()
         }
         */
    }
    
    class func saveCoreDataWhenExit(isTerminal: Bool) {
        /*
         if let unwrapTextView = textView,
         let unwrapOldMemo = memo,
         unwrapTextView.isEdited {
         
         if unwrapTextView.attributedText.length != 0 {
         //지금 있는 것도 대기열에 넣기
         delayAttrDic[unwrapOldMemo.objectID] = unwrapTextView.attributedText
         } else {
         if isTerminal {
         PianoData.coreDataStack.viewContext.delete(unwrapOldMemo)
         }
         }
         }
         
         //대기열에 있는 모든 것들 순차적으로 저장
         for (id, value) in delayAttrDic {
         do {
         let memo = try PianoData.coreDataStack.viewContext.existingObject(with: id) as! Memo
         let data = NSKeyedArchiver.archivedData(withRootObject: value)
         memo.content = data as NSData
         
         } catch {
         print(error)
         }
         }
         //다 저장했으면 지우기
         delayAttrDic.removeAll()
         
         do {
         try PianoData.coreDataStack.viewContext.save()
         } catch {
         print(error)
         }
         */
    }
    
    //TODO: 다음 업데이트때 이거 수정해야함 위의 함수와 유사함
    class func saveCoreDataIfIphone(){
        /*
         guard let unwrapTextView = textView, let unwrapOldMemo = memo else { return }
         
         if unwrapTextView.attributedText.length == 0 {
         PianoData.coreDataStack.viewContext.delete(unwrapOldMemo)
         PianoData.save()
         }
         */
    }
}

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

