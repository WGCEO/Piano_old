//
//  FolderView.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 20..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

protocol FolderChangeable: class {
    func changeFolder(to: Folder)
}

class FolderView: UIView {
    
    weak var delegate: FolderChangeable?
    
    @IBAction func tapFolderButton(_ sender: Any) {
    }
    
}
