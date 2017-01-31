//
//  ThanksToViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 31..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class ThanksToViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func tapBarButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
}
