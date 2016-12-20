//
//  MemoViewController.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit
import CoreData

class MemoViewController: UIViewController {

    @IBOutlet weak var hideKeyboardButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var eraseTextButtonBottom: NSLayoutConstraint!

    @IBOutlet var toolsCollection: [UIBarButtonItem]!

    @IBOutlet var completeToolButton: UIBarButtonItem!

    @IBAction func tapCompleteButton(_ sender: Any) {
        showTopView(bool: false)
        textView.isSelectable = true
        textView.isEditable = true
        textView.canvas.removeFromSuperview()
        textView.mode = .typing
    }

    //앨범에서 이미지를 가져오기 위한 이미지 피커 컨트롤러
    lazy var imagePicker: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.allowsEditing = false
        controller.sourceType = .savedPhotosAlbum
        return controller
    }()
    @IBOutlet weak var label: PianoLabel!
    @IBOutlet weak var textView: PianoTextView!

    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    var memo: Memo?
    var folder: Folder!
    
    var coreDataStack: PianoPersistentContainer!
    lazy var parser = MarkdownParser()
    
//    func saveMemo() {
//        let data = NSKeyedArchiver.archivedData(withRootObject: textView.attributedText)
//        memo.content = data
//        coreDataStack.saveContext()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        navigationController?.delegate = self
        setToolbarItems(toolsCollection, animated: false)
        containerViewHeight.constant = 0
        textView.canvas.delegate = label
        textView.layoutManager.delegate = self
        guard let toolBarHeight = navigationController?.toolbar.bounds.height else { return }
        hideKeyboardButtonBottom.constant = -toolBarHeight
        eraseTextButtonBottom.constant = -toolBarHeight
        
        
        //비동기로 해보고 테스트해볼 것
        
        if let memo = memo {
            let attrText = NSKeyedUnarchiver.unarchiveObject(with: memo.content) as? NSAttributedString
            textView.attributedText = attrText
        } else {
            let memo = Memo(context: coreDataStack.viewContext)
            memo.content = NSKeyedArchiver.archivedData(withRootObject: NSAttributedString())
            memo.date = NSDate()
            memo.folder = self.folder
            self.memo = memo
            textView.becomeFirstResponder()
        }
        
        coreDataStack.textView = textView
        coreDataStack.memo = memo
        
        //파싱이 오래걸리므로 비동기 처리
//        DispatchQueue.global().async { [weak self] in
//            guard let text = self?.textView.text else { return }
//            let attributedText = self?.parser.parseMarkdown(text: text)
//            
//            DispatchQueue.main.async {
//                self?.textView.attributedText = attributedText
//            }
//        }
//        print("텍스트뷰의 스트링은 \(textView.text)")
//        print("텍스트뷰의 어트리뷰트스트링은 \(textView.attributedText)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeTextViewStartFromTop(didAppear: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MemoViewController.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MemoViewController.keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        makeTextViewStartFromTop(didAppear: true)
    }
    
    func makeTextViewStartFromTop(didAppear: Bool) {
        textView.isScrollEnabled = didAppear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    @IBAction func tapHideKeyboardButton(_ sender: Any) {
        textView.resignFirstResponder()
    }

    @IBAction func tapEffectToolButton(_ sender: Any) {
        showTopView(bool: true)
        textView.resignFirstResponder()
        textView.isEditable = false
        textView.isSelectable = false
        textView.mode = .effect
        textView.attachCanvas()
    }
    
    @IBAction func tapTrashButton(_ sender: Any) {
        guard let memo = self.memo else { return }
        
        coreDataStack.performBackgroundTask { (context) in
            memo.isInTrash = true
            do {
                try context.save()
            } catch {
                print("쓰레기 버튼 눌렀는데 에러: \(error)")
            }
        }
        
        
        let _ = navigationController?.popViewController(animated: true)
    }

    
    
    
    
    @IBAction func tapEraseTextButton(_ sender: Any) {
        //현재 커서 왼쪽에 단어 있나 체크, 없으면 리턴하고 있다면 whitespace가 아닌 지 체크 <- 이를 반복해서 whitespace가 아니라면 그다음부터 whitespace인지 체크, whitespace 일 경우의 전 range까지 텍스트 지워버리기.
        
        //커서가 맨 앞에 있으면 탈출
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
    }
    

    func removeSubrange(from: Int) {
        //layoutManager에서 접근을 해야 캐릭터들을 올바르게 지울 수 있음(안그러면 이미지가 다 지워져버림)
        let range = NSMakeRange(from, textView.selectedRange.location - from)
        textView.layoutManager.textStorage?.deleteCharacters(in: range)
        
        textView.selectedRange = NSRange(location: from, length: 0)
    }
    
    func keyboardWillShow(notification: Notification){
        textView.isHardwareKeyboardConnected = false
        
        guard let userInfo = notification.userInfo,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue,
            let toolBarHeight = navigationController?.toolbar.bounds.height else { return }
        let kbHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        
        UIView.animate(withDuration: duration) { [weak self] in
            //TODO: change literal constant
            let bottom = kbHeight - toolBarHeight
            self?.textView.contentInset = UIEdgeInsetsMake(0, 0, bottom, 0)
            self?.eraseTextButtonBottom.constant = bottom
            self?.hideKeyboardButtonBottom.constant = bottom
            self?.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: Notification){
        textView.isHardwareKeyboardConnected = true
        resetTextViewInset(notification: notification)
    }
    
    func resetTextViewInset(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue,
            let toolBarHeight = navigationController?.toolbar.bounds.height else { return }
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            self?.eraseTextButtonBottom.constant = -toolBarHeight
            self?.hideKeyboardButtonBottom.constant = -toolBarHeight
            self?.view.layoutIfNeeded()
        }
    }
    
    func showTopView(bool: Bool) {
        self.navigationController?.setNavigationBarHidden(bool, animated: true)
        completeToolButton.width = UIScreen.main.bounds.width
        let items = bool ? [completeToolButton] : toolsCollection
        setToolbarItems(items, animated: true)
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.containerViewHeight.constant = bool ? 120 : 0
            self.textViewTop.constant = bool ? 100 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func tapAlbumToolButton(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
}

extension MemoViewController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }
}

extension MemoViewController: UITextViewDelegate {
 
    //TextViewDidChange는 지우는 erase버튼이 실행될 때 호출이 되지 않아 이 코드에서 코어데이터에 메모를 삽입하게 함
    func textViewDidChangeSelection(_ textView: UITextView) {
        //이걸 해야 아이패드에서 메모 리스트가 실시간 갱신됨, 이것때문에 느린지 체크하기 -> 아이패드에서만 이 기능 사용할 수 있도록 만들기
        guard let memo = self.memo else { return }
        memo.firstLine = textView.text.trimmingCharacters(in: CharacterSet.newlines)
    }
    
    //이거 여기다가 넣는게 진정 맞을까..?? 비용문제..
    func textViewDidChange(_ textView: UITextView) {
        guard let memo = memo else { return }
        memo.date = NSDate()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if textView.mode != .typing {
            textView.attachCanvas()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if textView.mode != .typing {
            textView.attachCanvas()
        }
    }
}

extension MemoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //여기서 selectedRange에다가 NSTextAttachment로 붙여 넣어야 함 물론 이미지 크기 조절해서!
            var attributedString :NSMutableAttributedString!
            attributedString = NSMutableAttributedString(attributedString:textView.attributedText)
            
            let oldWidth = pickedImage.size.width;
            
            //I'm subtracting 10px to make the image display nicely, accounting
            //for the padding inside the textView
            let ratio = (textView.textContainer.size.width - 10) / oldWidth;
            
            let size = pickedImage.size.applying(CGAffineTransform(scaleX: ratio, y: ratio))
            UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
            pickedImage.draw(in: CGRect(origin: CGPoint.zero, size: size))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let textAttachment = NSTextAttachment()
            textAttachment.image = scaledImage
            let attrStringWithImage = NSAttributedString(attachment: textAttachment)
            //
            attributedString.append(attrStringWithImage)
            let newLine = NSAttributedString(string: " \n", attributes: [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body)])
            attributedString.append(newLine)
            textView.attributedText = attributedString;
            textView.font = UIFont.preferredFont(forTextStyle: .body)
        }
        dismiss(animated: true, completion: nil)
    }
}

extension MemoViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let memo = self.memo else { return }
        let data = NSKeyedArchiver.archivedData(withRootObject: self.textView.attributedText)
        memo.content = data
        memo.firstLine = self.textView.text.trimmingCharacters(in: CharacterSet.newlines)
    }

}
