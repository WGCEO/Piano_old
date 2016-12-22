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
    func importFolders() {
        performBackgroundTask { (context) in
            let request: NSFetchRequest<Folder> = Folder.fetchRequest()
            do {
                if try context.count(for: request) == 0 {
                    
                    let pianoFolder = Folder(context: context)
                    pianoFolder.name = "Piano"
                    pianoFolder.date = NSDate()
                    
                    let memo = Memo(context: context)

                    let content =  NSAttributedString(string: "Piano는 (우아한) 타이핑과 빠른 편집을 동시에 원하는 당신을 위해 제작되었습니다. Piano는 기존의 메모 앱들이 가지고 있는 모든 기능을 효율적으로 발전시킨 완전히 새로운 혁신의 시작입니다. 이 아름다운 메모 앱으로 직관적인 타이핑과 (모바일에서의 가장 빠른 편집)을 경험하세요.당신은 메모를 하며 Piano를 연주하는 느낌을 받을 수 있습니다. 키보드는 건반이 되고 생각은 멜로디가 됩니다. 음악이 흐르듯 자연스럽게 당신의 생각이 텍스트로 옮겨집니다.한눈에 들어오는 텍스트와 최소한의 터치로 당신의 소중한 눈과 손 끝에 행복한 경험을 선물하세요. 푹신한 소파에 파묻혀 흘러가는 생각을 관찰하듯 당신의 타이핑이 놀랍도록 편안해집니다.", attributes: [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body)])
                    
                    let data = NSKeyedArchiver.archivedData(withRootObject: content)
                    
                
                    memo.firstLine = content.string.trimmingCharacters(in: CharacterSet.newlines)
                    memo.content = data
                    memo.date = Date()
                    memo.folder = pianoFolder
                    
                    pianoFolder.memos = [memo]
                    
                    try context.save()
                }
            } catch {
                print("Error importing folders: \(error.localizedDescription)")
            }
        }
    }
}
