//
//  DetailViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 20..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import Photos
import MessageUI

class MemoViewController: UIViewController {
    @IBOutlet weak var editor: PNEditor!

    private var canDoAnotherTask: Bool {
        return ActivityIndicator.isAnimating
    }

    var memo: Memo? {
        didSet {
            showMemo()
        }
    }
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if memo == nil {
            // TODO: iPad일 경우 첫 번째 메모를 가져와야 함 -> Master에서 하는 것이 좋을 듯
            memo = MemoManager.memoes.first
        }
        
        showMemo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // TODO: 어떤 경우에 Needed되는지 확인
        editor.appearKeyboardIfNeeded()
        editor.editMode = .typing
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        saveMemoIfNeeded()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) {[weak self] (_) in
            self?.editor.editMode = .typing
        }
    }
    
    // MARR: memo
    private func showMemo() {
        // TODO: CoreData와 연동이 되게끔
        editor?.attributedText = memo?.attrbutedString ?? NSAttributedString()
    }
    
    private func saveMemoIfNeeded() {
        guard let memo = memo else { return }
        
        guard editor?.attributedText.length != 0 else {
            MemoManager.remove(memo, completion: nil)
            return
        }
        
        guard editor?.isEdited == true else {
            return
        }
        
        // TODO: copy
        guard let copy = editor?.attributedText.copy() else { return }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: copy)
        memo.content = data as NSData
        
        MemoManager.save(memo)
    }
    
    // MARK: move memo to trash
    @IBAction func tapTrashButton(_ sender: Any) {
        if UserDefaults.hasShownTrashAlert {
            showTrashInfoAlert { [weak self] in
                self?.removeMemo()
            }
        } else {
            removeMemo()
        }
    }

    private func showTrashInfoAlert(_ completion: (() -> Void)?) {
        let alert = UIAlertController.makeTrashInfoAlert(completion)
        
        AppNavigator.present(alert)
    }
    
    private func removeMemo() {
        if let memo = memo {
            MemoManager.remove(memo) { [weak self] (isSuccess, memo) in
                if isSuccess {
                    self?.memo = memo
                }
            }
        }
    }
    
    // MARK: show effect buttons
    @IBAction func tapEffectButton(_ sender: Any) {
        editor.editMode = .effect
        editor.sizeToFit()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.setToolbarHidden(true, animated: true)
    }

    @IBAction func tapCompleteButton(_ sendder: Any) {
        editor.editMode = .typing
        editor.sizeToFit()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    @IBAction func tapSendEmail(_ sender: Any) {
        let content = memo?.attrbutedString ?? NSAttributedString()
        MailSender.sendMail(with: content) {
            //self?.editor.makeTappable()
        }
    }
    
    // MARK: pick images
    @IBAction func tapAlbumButton(_ sender: Any) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .restricted, .denied:
            showPermissionErrorAlert()
        default:
            showImagePicker()
        }
    }
    
    private func showImagePicker() {
        ImagePicker.show { [weak self] (image) in
            if let image = image {
                self?.editor?.addImage(image)
            }
        }
    }
    
    private func showPermissionErrorAlert() {
        let alert = UIAlertController.makePermissionErrorAlert()
        
        AppNavigator.present(alert)
    }
    
    // MARK: compose
    @IBAction func tapComposeButton(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
 
        let deadline = DispatchTime.now() + .milliseconds(50)
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            self?.memo = MemoManager.newMemo()
            
            sender.isEnabled = true
        }
    }
    
    @IBAction func tapEraseButton(_ sender: Any) {
        editor?.eraseCurrentLine()
    }
    
    @IBAction func tapKeyboardHideButton(_ sender: Any) {
        if canDoAnotherTask {
            editor.resignFirstResponder()
        }
    }
}


extension Memo {
    var attrbutedString: NSAttributedString? {
        guard let data = content as Data? else { return nil }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? NSAttributedString
    }
}
