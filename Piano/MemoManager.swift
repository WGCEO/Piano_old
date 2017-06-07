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

class MemoManager {
    lazy var privateMOC: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = PianoData.coreDataStack.viewContext
        return moc
    }()
    
    static var cache: [String:Memo] = [:]
    
    // MARK: public methods
    class func getMemo(at index: Int, in folder: String = "") -> Memo? {
        // 임시
        return Memo()
    }
    
    // for cache?
    class func getMemo(key: String) -> Memo? {
        
        return cache[key]
    }
    
    class func selectedMemo() -> Memo? {
        // 임시
        return Memo()
    }
    
    // MARK: alert
    func showAddGroupAlertViewController() {
        /*
        let alert = UIAlertController(title: "AddFolderTitle".localized(withComment: "폴더 생성"), message: "AddFolderMessage".localized(withComment: "폴더의 이름을 적어주세요."), preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel".localized(withComment: "취소"), style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "Create".localized(withComment: "생성"), style: .default) { [unowned self](action) in
            guard let text = alert.textFields?.first?.text else { return }
            let context = PianoData.coreDataStack.viewContext
            do {
                let newFolder = Folder(context: context)
                newFolder.name = text
                newFolder.date = NSDate()
                newFolder.memos = []
                
                try context.save()
                
                guard let masterViewController = self.delegate as? MasterViewController else { return }
                masterViewController.fetchFolderResultsController()
                masterViewController.selectSpecificFolder(selectedFolder: newFolder)
            } catch {
                print("Error importing folders: \(error.localizedDescription)")
            }
        }
        
        ok.isEnabled = false
        alert.addAction(cancel)
        alert.addAction(ok)
        
        alert.addTextField { (textField) in
            textField.placeholder = "FolderName".localized(withComment: "폴더이름")
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        }
        
        present(alert, animated: true, completion: nil)
        */
    }
    
    func textChanged(sender: AnyObject) {
        let tf = sender as! UITextField
        var resp : UIResponder! = tf
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[1].isEnabled = (tf.text != "")
    }
    
    func moveMemoToTrash() {
        /*
         //현재 메모 존재 안하면 리턴
         guard canDoAnotherTask() else { return }
         guard let unwrapMemo = memo else { return }
         
         
         //존재하면 휴지통에 넣기
         unwrapMemo.isInTrash = true
         PianoData.save()
         
         //마스터 뷰 컨트롤러에 현재 폴더의 첫번째 메모가 있는 지 체크 (없으면 닐 대입)
         
         
         guard let unwrapFirstMemo = masterViewController?.memoResultsController.fetchedObjects?.first
         else {
         self.memo = nil
         return }
         self.memo = unwrapFirstMemo
         delegate?.detailViewController(self, addMemo: unwrapFirstMemo)
         */
    }
    
    
    func addNewMemo() {
        /*
         guard let unwrapFolder = masterViewController?.folder else {
         showAddGroupAlertViewController()
         return
         }
         
         let memo = Memo(context: PianoData.coreDataStack.viewContext)
         memo.content = NSKeyedArchiver.archivedData(withRootObject: NSAttributedString()) as NSData
         memo.date = NSDate()
         memo.folder = unwrapFolder
         memo.firstLine = "NewMemo".localized(withComment: "새로운 메모")
         PianoData.save()
         
         delegate?.detailViewController(self, addMemo: memo)
         self.memo = memo
         */
    }

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
