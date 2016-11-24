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
    
    var kbHeight: CGFloat?
    var cacheCursorPosition: CGPoint = CGPoint(x: 0, y: -10)

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        containerViewHeight.constant = 0
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //registerForKeyboardNotification
        NotificationCenter.default.addObserver(self, selector: #selector(MemoViewController.keyboardWillShow(aNotification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MemoViewController.keyboardWillHide(aNotification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        //unregisterForKeyboardNotification
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(aNotification: Notification){
        adjustViewsByKeyboardState(showKeyboard: true, notification: aNotification)
    }
    
    func keyboardWillHide(aNotification: Notification){
        adjustViewsByKeyboardState(showKeyboard: false, notification: aNotification)
    }
    
    func adjustViewsByKeyboardState(showKeyboard:Bool, notification: Notification){
        
        controlsView.isHidden = showKeyboard
        textAlignControl.isHidden = !showKeyboard
        
        
        //키보드가 올라오거나 내려갈 때 애니메이션 함수
        if let userInfo = notification.userInfo,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        {
            let kbHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
            
            if showKeyboard
            {
                self.kbHeight = kbHeight
            }
            else
            {
                UIView.animate(withDuration: 0.3) { [unowned self] in
                    self.textView.contentInset.top = 0
                    self.textView.contentInset.bottom = 0
                    //textView.contentOffset.y = 0
                }
            }
        }
        
    }

    @IBAction func tapEffectButton(_ sender: Any) {
        showTopView(bool: true)
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
        let cursorDestinationY = screenHeight - (statusBarHeight + navigationbarHeight + currentCursorY + kbHeight)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.textView.contentInset.top = cursorDestinationY
            self?.textView.contentInset.bottom = kbHeight - toolbarHeight
            self?.textView.contentOffset.y = -cursorDestinationY
        }
    }
}
