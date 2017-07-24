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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editor.delegate = self
        
        //TODO: 나중에 지우기
        setTempParagraphStyle()
        // 여기까지

        
    }
    
    
    
    private func setTempParagraphStyle(){
        let mutableString = NSMutableAttributedString(attributedString: editor.textView.attributedText)
        guard let paragraph = mutableString.attribute(NSAttributedStringKey.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle else { return }
        let mutableParagraph = NSMutableParagraphStyle()
        mutableParagraph.setParagraphStyle(paragraph)
        mutableParagraph.headIndent = 30
        mutableParagraph.firstLineHeadIndent = 30
        mutableParagraph.tailIndent = -15
        mutableParagraph.lineSpacing = 10
        mutableString.addAttributes([.paragraphStyle : mutableParagraph, .foregroundColor : PianoGlobal.defaultColor], range: NSMakeRange(0, mutableString.length))
        editor.textView.attributedText = mutableString
    }
    
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



