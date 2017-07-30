//
//  LicenseViewController.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 19..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class LicenseViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func back(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }
}
