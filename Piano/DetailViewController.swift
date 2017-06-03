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

class DetailViewController: UIViewController {
    @IBOutlet weak var editor: PNEditor!

    private var canDoAnotherTask: Bool {
        return ActivityIndicator.sharedInstace.isAnimating
    }

    var memo: Memo? {
        didSet {
            editor.memo = memo
        }
    }
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if memo != nil {
            memo = MemoManager.selectedMemo()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // TODO: 어떤 경우에 Needed되는지 확인
        editor.appearKeyboardIfNeeded()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) {[weak self] (_) in
            self?.editor.prepareToEditing()
        }
    }
    
    // MARK: segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TextEffect" {
            let selectedButton = sender as! EffectButton
            let des = segue.destination as! SelectEffectViewController
            des.selectedButton = selectedButton
        }
    }
    
    // MARK: button touch events
    @IBAction func tapTrashButton(_ sender: Any) {
        //존재하면 우선 팝업 보여줬는지 체크하고 안보여줬다면 팝업보여주기
        /*
        if hasShownTrashAlert() {
            moveMemoToTrash()
        } else {
            showTrashInfoAlert { [unowned self] in
                self.moveMemoToTrash()
            }
        }
        */
    }
    
    @IBAction func tapEffectButton(_ sender: Any) {
        /*
        guard canDoAnotherTask() else { return }
        setTextViewEditedState()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
         DispatchQueue.main.async { [unowned self] in
         self.textView.sizeToFit()
         self.showTopView(bool: true)
         self.textView.attachCanvas()
         self.activityIndicator.stopAnimating()
         }
         */
    }

    @IBAction func tapSendEmail(_ sender: Any) {
        //sendMail()
    }
    
    // TODO: 실질적으로 기능은 비슷하므로 sender로 구분하는 것으로 변경 
    @IBAction func tapAlbumButton(_ sender: Any) {
        if !canDoAnotherTask { return }
        
        /*
        guard let _ = masterViewController?.folder else {
            showAddGroupAlertViewController()
            return
        }
        */
        
        editor.resignFirstResponder()
        
        showImagePicker()
    }
    
    private func showImagePicker() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .restricted, .denied:
            //showAlert()
            break
        default:
            AppNavigator.presentImagePicker()
        }
    }
    
    @IBAction func tapComposeButton(_ sender: Any) {
        if !canDoAnotherTask { return }
        
        let item = sender as! UIBarButtonItem
        item.isEnabled = false
        
        let deadline = DispatchTime.now() + .milliseconds(50)
        DispatchQueue.main.asyncAfter(deadline: deadline) { //[weak self] in
            //self?.addNewMemo()
            item.isEnabled = true
        }
    }
    
    @IBAction func tapEraseButton(_ sender: Any) {
        //현재 커서 왼쪽에 단어 있나 체크, 없으면 리턴하고 있다면 whitespace가 아닌 지 체크 <- 이를 반복해서 whitespace가 아니라면 그다음부터 whitespace인지 체크, whitespace 일 경우의 전 range까지 텍스트 지워버리기.
        
        //커서가 맨 앞에 있으면 탈출
        /*
        guard textView.selectedRange.location != 0 else { return }
        
        let beginning: UITextPosition = textView.beginningOfDocument
        var offset = textView.selectedRange.location
        var findWord = false
        
        while true {
            guard offset != 0 else {
                removeSubrange(from: offset)
                break
            }
            
            guard let start = textView.position(from: beginning, offset: offset - 1),
                let end = textView.position(from: beginning, offset: offset),
                let textRange = textView.textRange(from: start, to: end),
                let text = textView.text(in: textRange) else { return }
            
            let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
            let range = text.rangeOfCharacter(from: whitespacesAndNewlines)
            
            guard range != nil else { //단어가 있다는 말
                findWord = true
                offset -= 1
                continue
            }
            
            //whitespace발견!
            if findWord {
                removeSubrange(from: offset)
                break
            } else {
                offset -= 1
            }
        }
        
        setTextViewEditedState()
        updateCellInfo()
        */
    }
    
    @IBAction func tapKeyboardHideButton(_ sender: Any) {
        if canDoAnotherTask {
            editor.resignFirstResponder()
        }
    }
}

extension DetailViewController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }
}

