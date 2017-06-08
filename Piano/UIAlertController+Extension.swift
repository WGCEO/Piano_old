//
//  UIAlertController+Extension.swift
//  Piano
//
//  Created by dalong on 2017. 6. 8..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    public class func makeAddFolderAlert(_ handler: ((String) -> Void)?) -> UIAlertController {
        let title = "AddFolderTitle".localized(withComment: "폴더 생성")
        let message = "AddFolderMessage".localized(withComment: "폴더의 이름을 적어주세요.")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel".localized(withComment: "취소"), style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "Create".localized(withComment: "생성"), style: .default) { (action) in
            if let text = alert.textFields?.first?.text {
                handler?(text)
            }
        }
        
        ok.isEnabled = false
        alert.addAction(cancel)
        alert.addAction(ok)
        
        alert.addTextField { (textField) in
            textField.placeholder = "FolderName".localized(withComment: "폴더이름")
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        }

        return alert
    }
    
    internal class func textChanged(sender: AnyObject) {
        let tf = sender as! UITextField
        var resp : UIResponder! = tf
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[1].isEnabled = (tf.text != "")
    }
}
