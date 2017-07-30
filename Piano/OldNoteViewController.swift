//
//  OldNoteViewController.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 20..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class OldNoteViewController: UIViewController {

    public var memo: Memo?
    public var coreDataStack: PianoPersistentContainer!
    @IBOutlet weak var textView: UITextView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.textContainerInset = UIEdgeInsetsMake(20, 10, 80, 10)
        
        if let memo = self.memo {
            DispatchQueue.global().async { [unowned self] in
                let attrText = NSKeyedUnarchiver.unarchiveObject(with: memo.content! as Data) as? NSAttributedString
                DispatchQueue.main.async { [unowned self] in
                    self.textView.attributedText = attrText
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeTextViewStartFromTop(didAppear: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        makeTextViewStartFromTop(didAppear: true)
    }
    
    func makeTextViewStartFromTop(didAppear: Bool) {
        textView.isScrollEnabled = didAppear
    }
    
    @IBAction func back(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func moveToTrash(_ sender: Any) {
        guard let memo = self.memo else { return }
        memo.isInTrash = true
        PianoData.save()
        let _ = navigationController?.popViewController(animated: true)
    }
    

}
