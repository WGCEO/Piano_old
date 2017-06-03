//
//  AppNavigator.swift
//  Piano
//
//  Created by dalong on 2017. 6. 2..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

class AppNavigator {
    static var currentViewController: UIViewController?
    
    class func presentImagePicker() {
        
    }
    
    /*
    class func presentPermissionErrorAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "CantOpenAlbumTitle".localized(withComment: "앨범 열 수 없음"), message: "CantOpenAlbumMessage".localized(withComment: "설정으로 이동하여 앨범에 체크해주세요."), preferredStyle: .alert)
            let openSettingsAction = UIAlertAction(title: "Setting".localized(withComment: "설정"), style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            })
            let dismissAction = UIAlertAction(title: "Cancel".localized(withComment: "취소"), style: .cancel, handler: nil)
            alert.addAction(openSettingsAction)
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    */
    
    
    
    /*
    func showTrashInfoAlert(completion: @escaping () -> Void) {
        let trashAlert = UIAlertController(title: "DeleteMemo".localized(withComment: "노트 삭제"), message: "YouCanRecoverNoteFromSetting".localized(withComment: "세팅에서 복구할 수 있습니다"), preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK".localized(withComment: "확인"), style: .cancel) { (action) in
            completion()
        }
        trashAlert.addAction(cancel)
        present(trashAlert, animated: true, completion: nil)
    }
    
    func hasShownTrashAlert() -> Bool {
        guard UserDefaults.standard.bool(forKey: "hasShownTrashAlert") else {
            UserDefaults.standard.set(true, forKey: "hasShownTrashAlert")
            return false
        }
        return true
    }
    */
}
