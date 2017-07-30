//
//  FolderView.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 20..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

protocol FolderChangeable: class {
    func changeFolder(to: StaticFolder)
}

class FolderView: UIView {
    
    weak var delegate: FolderChangeable?
    @IBOutlet var folderButtons: [UIButton]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    internal func setFolders(for note: Memo?){
        guard let staticFolder = note?.staticFolder else { return }
        
        for button in folderButtons {
            UIView.animate(withDuration: PianoGlobal.duration, animations: {
                button.backgroundColor = staticFolder.order != button.tag ? .white : .black
            })
            
            button.isUserInteractionEnabled = staticFolder.order != button.tag ? false : true
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
                    for staticFolder in MemoManager.staticFolders {
                        if button.tag == staticFolder.order {
                            delegate?.changeFolder(to: staticFolder)
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
