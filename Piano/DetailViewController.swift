//
//  DetailViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 20..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var memo: Memo? {
        didSet {
            updateTextView(memo: memo)
        }
    }
    @IBOutlet var accessoryView: UIStackView!
    @IBOutlet weak var label: PianoLabel!
    @IBOutlet weak var textView: PianoTextView!
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    @IBOutlet weak var colorEffectButton: EffectButton!
    @IBOutlet weak var sizeEffectButton: EffectButton!
    @IBOutlet weak var lineEffectButton: EffectButton!
    
    //앨범에서 이미지를 가져오기 위한 이미지 피커 컨트롤러
    lazy var imagePicker: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.allowsEditing = false
        controller.sourceType = .savedPhotosAlbum
        return controller
    }()
    
    func updateTextView(memo: Memo?) {
        guard let textView = self.textView else { return }
        
        if let memo = memo {
            DispatchQueue.global().async {
                let attrText = NSKeyedUnarchiver.unarchiveObject(with: memo.content) as? NSAttributedString
                DispatchQueue.main.async { [unowned self] in
                    textView.attributedText = attrText
                    PianoData.coreDataStack.textView = textView
                    PianoData.coreDataStack.memo = memo
                    
                    //새 메모이면 키보드 올리고 새 메모가 아니면 키보드 내리기
                    if textView.attributedText.size().width != 0 {
                        textView.resignFirstResponder()
                    } else {
                        self.resetTextViewAttribute()
                        textView.becomeFirstResponder()
                    }
                }
            }
        } else {
            resetTextViewAttribute()
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.inputAccessoryView = accessoryView
        textView.canvas.delegate = label
        textView.layoutManager.delegate = self
        
        setEffectButton()
        setFontAwesomeIcon()
        
        accessoryView.frame.size.height = navigationController!.toolbar.frame.height
        
        
        //viewDidLoad() 에서 memo == nil 일 때는 아이패드에서 맨 처음 실행했을 경우에만이므로 이때에는 최상위의 폴더에서 최상위 메모를 선택하게 함
        if let memo = memo {
            updateTextView(memo: memo)
        } else {
            let nav = splitViewController?.viewControllers.first as! UINavigationController
            let masterViewController = nav.topViewController as! MasterViewController
            let memoListViewController = masterViewController.childViewControllers.last as! MemoListViewController
            memoListViewController.selectTableViewCell(with: IndexPath(row: 0, section: 0))
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) {[unowned self] (_) in
            if self.textView.mode != .typing {
                self.textView.attachCanvas()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        textView.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TextEffect" {
            let selectedButton = sender as! EffectButton
            let des = segue.destination as! SelectEffectViewController
            des.selectedButton = selectedButton
        }
    }
    
    func showTopView(bool: Bool) {
        navigationController?.setNavigationBarHidden(bool, animated: true)
        navigationController?.setToolbarHidden(bool, animated: true)
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.textViewTop.constant = bool ? 100 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("뷰 나타난당")
    }
    
    func resetTextViewAttribute(){
        textView.attributedText = NSAttributedString()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.textColor = UIColor.black
    }
    
    func keyboardWillShow(notification: Notification){
        accessoryView.isHidden = false
        textView.isHardwareKeyboardConnected = false
        
        guard let userInfo = notification.userInfo,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return }
        let kbHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        
        UIView.animate(withDuration: duration) { [weak self] in
            //TODO: change literal constant
            self?.textView.contentInset = UIEdgeInsetsMake(0, 0, kbHeight, 0)
            self?.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: Notification){
        accessoryView.isHidden = true
        textView.isHardwareKeyboardConnected = true
        
        guard let userInfo = notification.userInfo,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return }
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            self?.view.layoutIfNeeded()
        }
    }
    
    func removeSubrange(from: Int) {
        //layoutManager에서 접근을 해야 캐릭터들을 올바르게 지울 수 있음(안그러면 이미지가 다 지워져버림)
        let range = NSMakeRange(from, textView.selectedRange.location - from)
        textView.layoutManager.textStorage?.deleteCharacters(in: range)
        textView.selectedRange = NSRange(location: from, length: 0)
    }
    
    func setEffectButton() {
        //TODO: 여기에 코어데이터에 저장되어 있는 속성 값 대입해 넣기
        colorEffectButton.textEffect = .color(.red)
        sizeEffectButton.textEffect = .title(.title3)
        lineEffectButton.textEffect = .line(.strikethrough)
        
        colorEffectButton.textView = textView
        sizeEffectButton.textView = textView
        lineEffectButton.textView = textView
    }
    
    func setFontAwesomeIcon(){
        
        colorEffectButton.setTitle("\u{f031}", for: .normal)
        sizeEffectButton.setTitle("\u{f1dc}", for: .normal)
        lineEffectButton.setTitle("\u{f0cc}", for: .normal)
    }
    
    @IBAction func tapFinishEffectButton(_ sender: EffectButton) {
        showTopView(bool: false)
        textView.isSelectable = true
        textView.isEditable = true
        textView.canvas.removeFromSuperview()
        textView.mode = .typing
    }

    @IBAction func tapColorEffectButton(_ sender: EffectButton) {
        if colorEffectButton.isSelected {
            //기존에 이미 선택되어 있다면 효과 선택화면 띄워주기
            performSegue(withIdentifier: "TextEffect", sender: sender)
        }
        
        textView.canvas.textEffect = sender.textEffect
        
        colorEffectButton.isSelected = true
        sizeEffectButton.isSelected = false
        lineEffectButton.isSelected = false
    }
    
    @IBAction func tapSizeEffectButton(_ sender: EffectButton) {
        if sizeEffectButton.isSelected {
            //기존에 이미 선택되어 있다면 크기 선택화면 띄워주기
            performSegue(withIdentifier: "TextEffect", sender: sender)
        }
        
        textView.canvas.textEffect = sender.textEffect
        
        colorEffectButton.isSelected = false
        sizeEffectButton.isSelected = true
        lineEffectButton.isSelected = false
    }

    @IBAction func tapLineEffectButton(_ sender: EffectButton) {
        if lineEffectButton.isSelected {
            //기존에 이미 선택되어 있다면 라인 선택화면 띄워주기
            performSegue(withIdentifier: "TextEffect", sender: sender)
        }
        
        textView.canvas.textEffect = sender.textEffect
        colorEffectButton.isSelected = false
        sizeEffectButton.isSelected = false
        lineEffectButton.isSelected = true
    }
    
    @IBAction func tapTrashButton(_ sender: Any) {
        //기존 memo 코어데이터에서 isInTrash = true로 바꿔버리기
        memo?.isInTrash = true
        PianoData.save()
        
        //데이터 소스에 nil 대입하면 알아서 초기화됨.
        memo = nil
    }
    
    @IBAction func tapEffectButton(_ sender: Any) {
        showTopView(bool: true)
        textView.resignFirstResponder()
        textView.isEditable = false
        textView.isSelectable = false
        textView.mode = .effect
        textView.attachCanvas()
    }
    
    func addNewMemo() {
        let nav = splitViewController?.viewControllers.first as! UINavigationController
        let masterViewController = nav.topViewController as! MasterViewController
        masterViewController.addNewMemo()
    }
    
    @IBAction func tapComposeButton(_ sender: Any) {
        addNewMemo()
    }
    
    @IBAction func tapEraseButton(_ sender: Any) {
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
    
    @IBAction func tapAlbumButton(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func tapAlbumButton2(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func tapKeyboardHideButton(_ sender: Any) {
        textView.resignFirstResponder()
    }
    
    
}

extension DetailViewController: MemoListViewControllerDelegate {
    func memoListViewController(_ controller: MemoListViewController, send memo: Memo) {
        
        
        //기존에 메모 프로퍼티가 있다면 메모 내용을 코어데이터에 저장시키기
        if let oldMemo = self.memo,
            let textView = self.textView {
            
            guard oldMemo != memo else { return }
            
            if textView.attributedText.size().width == 0 {
                PianoData.coreDataStack.viewContext.delete(oldMemo)
            } else {
                let data = NSKeyedArchiver.archivedData(withRootObject: textView.attributedText)
                oldMemo.content = data
                let text = textView.text.trimmingCharacters(in: CharacterSet.newlines)
                oldMemo.firstLine = text.characters.count != 0 ? text : "새로운 메모"
            }
            PianoData.save()
        }
        
        self.memo = memo
        
    }
}

extension DetailViewController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 5
    }
}

extension DetailViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard memo != nil else {
            //TODO: 메모 생성하기
            addNewMemo()
            return
        }
    }
    
    
    //TextViewDidChange는 지우는 erase버튼이 실행될 때 호출이 되지 않아 이 코드에서 코어데이터에 메모를 삽입하게 함
    func textViewDidChangeSelection(_ textView: UITextView) {
        //TODO: 이걸 해야 아이패드에서 메모 리스트가 실시간 갱신됨, 이것때문에 느린지 체크하기 -> 아이패드에서만 이 기능 사용할 수 있도록 만들기
        
        guard let memo = self.memo else { return }
        let text = textView.text.trimmingCharacters(in: CharacterSet.newlines)
        if text.characters.count != 0 {
            memo.firstLine = textView.text.trimmingCharacters(in: CharacterSet.newlines)
        } else {
            memo.firstLine = "새로운 메모"
        }
    }
    
    //TODO: 이거 여기다가 넣는게 진정 맞을까..?? 비용문제..
    func textViewDidChange(_ textView: UITextView) {
        guard let memo = memo else { return }
        memo.date = Date()
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

extension DetailViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
            attributedString.insert(attrStringWithImage, at: textView.selectedRange.location)
            textView.attributedText = attributedString;
            textView.font = UIFont.preferredFont(forTextStyle: .body)
        }
        dismiss(animated: true, completion: nil)
    }

}