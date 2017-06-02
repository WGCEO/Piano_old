//
//  MemoManager.swift
//  Piano
//
//  Created by dalong on 2017. 6. 2..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation

class MemoManager {
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
