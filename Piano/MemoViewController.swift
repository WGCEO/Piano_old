//
//  MemoViewController.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class MemoViewController: UIViewController {

    
    @IBOutlet weak var textView: PianoTextView!
    @IBOutlet weak var textAlignControl: UISegmentedControl!
    @IBOutlet weak var controlsView: UIStackView!
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var hideKeyboardButton: UIButton!

    @IBOutlet weak var eraseTextButton: UIButton!

    @IBOutlet weak var eraseTextButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var hideKeyboardButtonBottom: NSLayoutConstraint!
    var kbHeight: CGFloat?
    var cacheCursorPosition: CGPoint = CGPoint(x: 0, y: -10)

    
    override func viewDidLoad() {
        super.viewDidLoad()

        containerViewHeight.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MemoViewController.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MemoViewController.keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    @IBAction func tapEffectButton(_ sender: Any) {
        showTopView(bool: true)
    }
    
    @IBAction func tapHideKeyboardButton(_ sender: Any) {
        textView.resignFirstResponder()
    }
    
    @IBAction func tapEraseTextButton(_ sender: Any) {
        //현재 커서 왼쪽에 단어 있나 체크, 없으면 리턴하고 있다면 whitespace가 아닌 지 체크 <- 이를 반복해서 whitespace가 아니라면 그다음부터 whitespace인지 체크, whitespace 일 경우의 전 range까지 텍스트 지워버리기.
        
        //
        let beginning: UITextPosition = textView.beginningOfDocument
        var offset = textView.selectedRange.location
        var findWord = false
        
        while true {
            
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
//                guard let start = textView.position(from: beginning, offset: offset),
//                    let end = textView.position(from: beginning, offset: textView.selectedRange.location),
//                    let textRange = textView.textRange(from: start, to: end) else { return }
                    //textView.replace(textRange, withText: "")
                
                let start = textView.text.index(textView.text.startIndex, offsetBy: offset)
                let end = textView.text.index(textView.text.startIndex, offsetBy: textView.selectedRange.location - 1)
                textView.text.removeSubrange(start...end)
                break
            } else {
                offset -= 1
            }
            
        }
    }
    
    func keyboardWillShow(notification: Notification){
        guard let userInfo = notification.userInfo,
            let toolbarHeight = navigationController?.toolbar.frame.height else { return }
        cacheCursorPosition = CGPoint(x: 0, y: -10)
        controlsView.isHidden = true
        textAlignControl.isHidden = false
        hideKeyboardButton.isHidden = false
        eraseTextButton.isHidden = false
        let kbHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        self.kbHeight = kbHeight
        self.hideKeyboardButtonBottom.constant = kbHeight - toolbarHeight
        self.eraseTextButtonBottom.constant = kbHeight - toolbarHeight
    }
    
    func keyboardWillHide(notification: Notification){
        guard let userInfo = notification.userInfo,
           let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return }
        controlsView.isHidden = false
        textAlignControl.isHidden = true
        hideKeyboardButton.isHidden = true
        eraseTextButton.isHidden = true
        UIView.animate(withDuration: duration) { [weak self] in
            self?.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    func showTopView(bool: Bool) {
        self.navigationController?.setNavigationBarHidden(bool, animated: true)
        self.navigationController?.setToolbarHidden(bool, animated: true)
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.containerViewHeight.constant = bool ? 100 : 0
            self.textViewTop.constant = bool ? 100 : 0
            self.view.layoutIfNeeded()
        }
    }
}


extension MemoViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard let nowCursorPosition = textView.selectedTextRange?.end else { return } 
        let cursorPosition = textView.caretRect(for: nowCursorPosition).origin

        if shouldMoveCursor(from: cursorPosition) {
            moveCursor(from: cursorPosition)
        }
    }
    
    //현재 커서가 키보드에 붙어있는 지 아닌 지 체크
    func shouldMoveCursor(from: CGPoint) -> Bool{
        return from.y != cacheCursorPosition.y ? true : false
    }
    
    //커서를 이동시키는 메서드
    func moveCursor(from: CGPoint) {
        guard let kbHeight = kbHeight,
            let navigationbarHeight = navigationController?.navigationBar.frame.height,
            let toolbarHeight = navigationController?.toolbar.frame.height
            else { return }
        let screenHeight = UIScreen.main.bounds.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        cacheCursorPosition = from
        let currentCursorY = cacheCursorPosition.y
        let textInsetTop = textView.textContainerInset.top
        let cursorDestinationY = screenHeight - (statusBarHeight + navigationbarHeight + currentCursorY + kbHeight + textInsetTop)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.textView.contentInset.top = cursorDestinationY
            self?.textView.contentInset.bottom = kbHeight - toolbarHeight
            self?.textView.contentOffset.y = -cursorDestinationY
        }
    }
}
