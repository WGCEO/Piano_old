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
    
    @objc func textChanged(sender: AnyObject) {
        let tf = sender as! UITextField
        var resp : UIResponder! = tf
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[1].isEnabled = (tf.text != "")
    }
    
    public class func makePermissionErrorAlert() -> UIAlertController {
        let title = "CantOpenAlbumTitle".localized(withComment: "앨범 열 수 없음")
        let message = "CantOpenAlbumMessage".localized(withComment: "설정으로 이동하여 앨범에 체크해주세요.")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let openSettingsAction = UIAlertAction(title: "Setting".localized(withComment: "설정"), style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        })
        let dismissAction = UIAlertAction(title: "Cancel".localized(withComment: "취소"), style: .cancel, handler: nil)
        
        alert.addAction(openSettingsAction)
        alert.addAction(dismissAction)
        
        return alert
    }
    
    public class func makeTrashInfoAlert(_ completion: (() -> Void)?) -> UIAlertController {
        let title = "DeleteMemo".localized(withComment: "노트 삭제")
        let message = "YouCanRecoverNoteFromSetting".localized(withComment: "세팅에서 복구할 수 있습니다")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancel = UIAlertAction(title: "OK".localized(withComment: "확인"), style: .cancel) { (action) in
            completion?()
        }
        alert.addAction(cancel)
        
        return alert
    }
}
