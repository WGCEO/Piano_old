//
//  FolderView.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 20..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

protocol FolderChangeable: class {
    func changeFolder(to: Int)
}

class FolderView: UIView {
    
    weak var delegate: FolderChangeable?
    @IBOutlet var folderButtons: [UIButton]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    
    
    internal func setFolders(with num: Int){
        
        for button in folderButtons {
            UIView.animate(withDuration: PianoGlobal.duration, animations: {
                button.backgroundColor = num != button.tag ? .white : .black
            })
            
            button.isUserInteractionEnabled = num != button.tag ? false : true
        }
    }
    
    @IBAction func tapFolderButton(_ sender: UIButton) {
        var didAppearAllFolder = true
        for button in folderButtons {
            if !button.isUserInteractionEnabled {
                didAppearAllFolder = false
                break
            }
        }
        
        if didAppearAllFolder {
            //폴더를 합치는 경우
            for button in folderButtons {
                UIView.animate(withDuration: PianoGlobal.duration, animations: {
                    button.backgroundColor = button != sender ? .white : .black
                })
                
                button.isUserInteractionEnabled = button != sender ? false : true
                
                if button == sender {
                    for i in 0...6 {
                        if button.tag == i {
                            delegate?.changeFolder(to: i)
                        }
                    }
                }
            }
        } else {
            //폴더를 퍼뜨리는 경우
            for button in folderButtons {
                UIView.animate(withDuration: PianoGlobal.duration, animations: {
                    button.backgroundColor = .black
                })
                
                button.isUserInteractionEnabled = true
            }
        }
    }
    
}
