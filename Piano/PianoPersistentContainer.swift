//
//  PianoPersistentContainer.swift
//  Piano
//
//  Created by kevin on 2016. 12. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit
import CoreData

class PianoPersistentContainer: NSPersistentContainer {
    
    weak var detailViewController: DetailViewController?
    
    func saveWhenAppWillBeTerminal() {
        detailViewController?.saveData(isTerminal: true)
    }
    
    func saveWhenAppGoToBackground() {
        detailViewController?.saveData(isTerminal: false)
    }
    
    func makeKeyboardHide(){
        //detailViewController?.editor?.makeTappable()
        //detailViewController?.editor?.becomeFirstResponder()
        //detailViewController?.editor?.resignFirstResponder()
        
        DispatchQueue.main.async { [weak self] in
            self?.detailViewController?.tapFinishEffect()
        }
    }
}
