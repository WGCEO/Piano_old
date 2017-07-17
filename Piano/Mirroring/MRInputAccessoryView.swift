//
//  MRInputAccessoryView.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class MRInputAccessoryView: UIView {
    
    @IBOutlet weak var mrScrollView: MRScrollView!
    @IBOutlet weak var accessoryStackView: UIStackView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MRInputAccessoryView.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: keyboard
    @objc func keyboardWillShow(notification: Notification){
        guard let userInfo = notification.userInfo,
            let kbFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            else { return }
        
        //아이패드일경우 스크롤뷰 숨겨야함
        let isBluetoothKB = UIScreen.main.bounds.height != kbFrame.origin.y + kbFrame.height
        
        mrScrollView.isHidden = isBluetoothKB
        accessoryStackView.isHidden = !isBluetoothKB
    }
    
}
