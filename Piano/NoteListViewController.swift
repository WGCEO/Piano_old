//
//  NoteListViewController.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import CoreData

class NoteListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var folderButtons: [UIButton]!
    
    var selectedFolder: StaticFolder?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let folder = selectedFolder else { return }
        for button in folderButtons {
            
            if button.tag == folder.order {
                button.sendActions(for: .touchUpInside)
                break
            }
        }
        
    }
    
    @IBAction func touchUpFolder(_ sender: UIButton) {
        animateFolderButtons(sender)
        
    }
    
    private func animateFolderButtons(_ sender: UIButton){
        for button in folderButtons {
            if sender != button {
                UIView.animate(withDuration: 0.2, animations: {
                    button.backgroundColor = .white
                    button.setTitleColor(.black, for: .normal)
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    button.backgroundColor = .black
                    button.setTitleColor(.white, for: .normal)
                })
            }
        }
    }
    
    
}

//extension NoteListViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        //
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        //
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        // 1. 핀 2. 일주일간 3.일주일이후
//        return 3
//    }
//
//}
//
//extension NoteListViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }
//}

