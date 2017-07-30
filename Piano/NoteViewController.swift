//
//  NoteViewController.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import  CoreData

class NoteViewController: UIViewController {
    
    @IBOutlet weak var editor: PianoEditor!
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    lazy private var resultsController: NSFetchedResultsController<Memo> = {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        request.predicate = NSPredicate(format: "isInTrash == false")
        let context = PianoData.coreDataStack.viewContext
        let dateSort = NSSortDescriptor(key: #keyPath(Memo.date), ascending: false)
        request.sortDescriptors = [dateSort]
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext:context, sectionNameKeyPath: nil, cacheName: nil)
//        controller.delegate = self
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editor.delegate = self
        
        //TODO: 나중에 지우기
//        setTempParagraphStyle()
        // 여기까지
        
        MemoManager.migrateVersionTwo()
        
        
//        if let recentlyData = UserDefaults.standard.object(forKey: "recentlyNote") as? Data, let attrText = NSKeyedUnarchiver.unarchiveObject(with: recentlyData) as? NSAttributedString {
//            editor.textView.attributedText = attrText
//        } else {
//            do {
//                try resultsController.performFetch()
//
//                guard let recentlyMemo = resultsController.fetchedObjects?.first,
//                    let data = recentlyMemo.content,
//                    let attrText = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSAttributedString else { return }
//                editor.textView.note = recentlyMemo
//                editor.textView.attributedText = attrText
//            } catch {
//                print("Error performing fetch \(error.localizedDescription)")
//            }
//        }
        
    }
    
    
    
//    private func setTempParagraphStyle(){
//        let mutableString = NSMutableAttributedString(attributedString: editor.textView.attributedText)
//        guard let paragraph = mutableString.attribute(NSAttributedStringKey.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle else { return }
//        let mutableParagraph = NSMutableParagraphStyle()
//        mutableParagraph.setParagraphStyle(paragraph)
//        mutableParagraph.headIndent = 0
//        mutableParagraph.firstLineHeadIndent = 0
//        mutableParagraph.tailIndent = -10
//        mutableParagraph.lineSpacing = 10
//        mutableString.addAttributes([.paragraphStyle : mutableParagraph, .foregroundColor : PianoGlobal.defaultColor], range: NSMakeRange(0, mutableString.length))
//        editor.textView.attributedText = mutableString
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
            let folder = sender as? StaticFolder,
            identifier == "NoteListViewController" {
            let des = segue.destination as! NoteListViewController
            des.selectedFolder = folder
        }
    }
}

extension NoteViewController: Navigatable {
    func moveToNoteListViewController(with folder: StaticFolder) {
        performSegue(withIdentifier: "NoteListViewController", sender: folder)
    }
    
    func moveToPreferenceViewController() {
        //
    }
    
    func moveToNewMemo() {
        //
    }
}



