//
//  SettingDetailViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 26..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class SettingDetailViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    var dataSource: (UIImage, String)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = dataSource.0
        textView.text = dataSource.1

    }

}
