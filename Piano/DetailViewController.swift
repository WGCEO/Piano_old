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
import CoreData

protocol DetailViewControllerDelegate: class {
    func detailViewController(_ controller: DetailViewController, addMemo: Memo)
}

class DetailViewController: UIViewController {
    
    lazy var privateMOC: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = PianoData.coreDataStack.viewContext
        return moc
    }()
    
    var masterViewController: MasterViewController? {
        get {
            guard let masterViewController = delegate as? MasterViewController else { return nil }
            return masterViewController
        }
    }
    
    var delayAttrDic: [NSManagedObjectID : NSAttributedString] = [:]
    var waitingAttr: NSAttributedString?
    
    var appearKeyboardIfNeeded: () -> Void = { }
    
    weak var delegate: DetailViewControllerDelegate?
    
    @IBOutlet weak var editor: PNEditor!

    
    //TODO: 이거 해결해야함 코드 더러움
    var iskeyboardAlbumButtonTouched: Bool = false
    
    var canDoAnotherTask: Bool {
        return ActivityIndicator.sharedInstace.isAnimating
    }

    
    
    
    
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO: 업데이트할 때 이 참조 지우기
        //textView.detailViewController = self
        
        /*
        textView.inputAccessoryView = accessoryView
        textView.canvas.delegate = label
        textView.layoutManager.delegate = self
        */

        //accessoryView.frame.size.height = navigationController!.toolbar.frame.height
        
        PianoData.coreDataStack.detailViewController = self
        
        
        //viewDidLoad() 에서 memo == nil 일 때는 아이패드에서 맨 처음 실행했을 경우에만이므로 이때에는 최상위의 폴더에서 최상위 메모를 선택하게 함
        /*
        if let memo = memo {
            setTextView(with: memo)
        } else {
            //아이패드인 경우로 해당 폴더의 첫번째 메모를 가져와야함
            guard let masterViewController = delegate as? MasterViewController else { return }
            if masterViewController.hasMemoInCurrentFolder() {
                masterViewController.selectTableViewCell(with: IndexPath(row: 0, section: 0))
            } else {
                self.memo = nil
            }
        }
        textView.contentOffset = CGPoint.zero
        */
    }
    

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        /*
        coordinator.animate(alongsideTransition: nil) {[unowned self] (_) in
            
            guard let textView = self.textView else { return }
            if textView.mode != .typing {
                textView.attachCanvas()
            }
 
        }
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TextEffect" {
            let selectedButton = sender as! EffectButton
            let des = segue.destination as! SelectEffectViewController
            des.selectedButton = selectedButton
        }
    }
    
    func showTopView(bool: Bool) {
        /*
        guard let textViewTop = self.textViewTop, let topView = self.topView else { return }
        if bool {
            textView.makeEffectable()
        } else {
            textView.makeTappable()
        }
        
        //탑 뷰의 현재 상태와 반대될 때에만 아래의 뷰 애니메이션 코드 실행
        guard bool == topView.isHidden else { return }
        
        topView.isHidden = bool ? false : true
        navigationController?.setNavigationBarHidden(bool, animated: true)
        navigationController?.setToolbarHidden(bool, animated: true)
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.textView.contentInset.bottom = bool ? 50 : 0
            textViewTop.constant = bool ? 100 : 0
            self.view.layoutIfNeeded()
        }
        */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //TODO: 코드 리펙토링제대로하기
        //textView.isWaitingState = false
        appearKeyboardIfNeeded()
        appearKeyboardIfNeeded = { }
    }
    
    
    
    // MARK: memo
    
    func setTextView(with memo: Memo?) {
        /*
         guard let editor = editor else { return }
         unwrapTextView.isEdited = false
         
         //스크롤 이상하게 되는 것 방지
         unwrapTextView.contentOffset = CGPoint.zero
         
         guard let unwrapNewMemo = memo else {
         resetTextViewAttribute()
         return }
         
         let haveTextInDelayAttrDic = delayAttrDic.contains { [unowned self](key, value) -> Bool in
         if unwrapNewMemo.objectID == key {
         unwrapTextView.attributedText = value
         let selectedRange = NSMakeRange(unwrapTextView.attributedText.length, 0)
         unwrapTextView.selectedRange = selectedRange
         if unwrapTextView.attributedText.length == 0 {
         self.resetTextViewAttribute()
         if self.isVisible {
         unwrapTextView.appearKeyboard()
         } else {
         self.appearKeyboardIfNeeded = { unwrapTextView.appearKeyboard() }
         }
         }
         
         return true
         } else {
         return false
         }
         }
         
         guard !haveTextInDelayAttrDic else { return }
         
         let attrText = NSKeyedUnarchiver.unarchiveObject(with: unwrapNewMemo.content! as Data) as? NSAttributedString
         PianoData.coreDataStack.viewContext.performAndWait({
         unwrapTextView.attributedText = attrText
         let selectedRange = NSMakeRange(unwrapTextView.attributedText.length, 0)
         unwrapTextView.selectedRange = selectedRange
         
         if unwrapTextView.attributedText.length == 0 {
         self.resetTextViewAttribute()
         if self.isVisible {
         unwrapTextView.appearKeyboard()
         } else {
         self.appearKeyboardIfNeeded = { unwrapTextView.appearKeyboard() }
         }
         }
         })
         */
    }
    
    func saveData(isTerminal: Bool) {
        MemoManager.saveCoreDataWhenExit(isTerminal: isTerminal)
    }
    
    func resetTextViewAttribute(){
        /*
        guard let unwrapTextView = textView else { return }
        unwrapTextView.textAlignment = .left
        let attrText = NSAttributedString()
        unwrapTextView.attributedText = attrText
        unwrapTextView.typingAttributes = [NSForegroundColorAttributeName: UIColor.piano,
                                           NSUnderlineStyleAttributeName : 0,
                                           NSStrikethroughStyleAttributeName: 0,
                                           NSBackgroundColorAttributeName : UIColor.clear,
                                           NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body)
        ]
        */
    }    
    // MARK: edit text?
    func removeSubrange(from: Int) {
        //layoutManager에서 접근을 해야 캐릭터들을 올바르게 지울 수 있음(안그러면 이미지가 다 지워져버림)
        /*
        let range = NSMakeRange(from, textView.selectedRange.location - from)
        textView.layoutManager.textStorage?.deleteCharacters(in: range)
        textView.selectedRange = NSRange(location: from, length: 0)
        */
    }
    
    func setTextViewEditedState() {
        //textView.isEdited = true
        //memo?.date = NSDate()
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
    
    
    @IBAction func tapAlbumButton(_ sender: Any) {
        if !canDoAnotherTask { return }
        
        guard let _ = masterViewController?.folder else {
            //showAddGroupAlertViewController()
            return
        }
        
        showImagePicker()
        
        iskeyboardAlbumButtonTouched = false
    }
    
    @IBAction func tapAlbumButton2(_ sender: Any) {
        if !canDoAnotherTask { return }
        
        guard let _ = masterViewController?.folder else {
            //showAddGroupAlertViewController()
            return
        }
        editor.resignFirstResponder()
        
        showImagePicker()
        
        iskeyboardAlbumButtonTouched = true
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

