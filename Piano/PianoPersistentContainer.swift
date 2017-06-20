//
//  PianoPersistentContainer.swift
//  Piano
//
//  Created by kevin on 2016. 12. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit
import CoreData

protocol memoEditable: class {
    func save()
}

class PianoPersistentContainer: NSPersistentContainer {
    static public let sharedInstance = PianoPersistentContainer(name: "PianoModel")
    
    public weak var memoEditor: memoEditable?
    
    public func saveWhenAppWillBeTerminal() {
        memoEditor?.save()
    }
    
    public func saveWhenAppGoToBackground() {
        memoEditor?.save()
        
        MemoManager.saveAllNow()
    }
    
    public func makeKeyboardHide(){
        //detailViewController?.editor?.makeTappable()
        //detailViewController?.editor?.becomeFirstResponder()
        //detailViewController?.editor?.resignFirstResponder()
        
        DispatchQueue.main.async { //[weak self] in
            //self?.detailViewController?.tapFinishEffect()
        }
    }
}
