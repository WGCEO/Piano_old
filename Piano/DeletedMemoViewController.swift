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
    var coreDataStack: PianoPersistentContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.layoutManager.delegate = self
        textView.textContainerInset = UIEdgeInsetsMake(20, 20, 0, 20)
        
        if let memo = self.memo {
            DispatchQueue.global().async { [unowned self] in
                let attrText = NSKeyedUnarchiver.unarchiveObject(with: memo.content) as? NSAttributedString
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
    
    @IBAction func tapRestoreBarButton(_ sender: Any) {
        guard let memo = self.memo else { return }
        coreDataStack.performBackgroundTask { (context) in
            memo.isInTrash = false
            memo.date = Date()
            do {
                try context.save()
            } catch {
                print("쓰레기 버튼 눌렀는데 에러: \(error)")
            }
        }
        let _ = navigationController?.popViewController(animated: true)
    }
    
}

extension DeletedMemoViewController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }
}

extension DeletedMemoViewController: UITextViewDelegate {
    
}
