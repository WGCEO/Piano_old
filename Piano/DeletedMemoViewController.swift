//
//  DeletedMemoViewController.swift
//  Piano
//
//  Created by kevin on 2016. 12. 22..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class DeletedMemoViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var memo: Memo?
    var folder: Folder!
    var coreDataStack: PianoPersistentContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.layoutManager.delegate = self
        
        if let memo = self.memo {
            DispatchQueue.global().async { [unowned self] in
                let attrText = NSKeyedUnarchiver.unarchiveObject(with: memo.content) as? NSAttributedString
                DispatchQueue.main.async { [unowned self] in
                    self.textView.attributedText = attrText
                }
            }
        }
    }
}

extension DeletedMemoViewController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }
}

extension DeletedMemoViewController: UITextViewDelegate {
    
}
