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
    
    //TODO: 이거 해결해야함 코드 더러움
    var iskeyboardAlbumButtonTouched: Bool = false
    
    var memo: Memo? {
        willSet {
            startLoading()
            //우선 이미지에 nil 대입하기
            firstImage = nil
            textView?.resignFirstResponder()
            saveCoreDataIfNeed()
        }
        didSet {
            showTopView(bool: false)
            textView?.canvas.removeFromSuperview()
            guard memo != oldValue else {
                textView?.isEdited = false
                stopLoading()
                return
            }
    
            self.setTextView(with: self.memo)
            DispatchQueue.main.async { [unowned self] in
                self.stopLoading()
                guard let textView = self.textView else { return }
                textView.contentOffset = CGPoint.zero
            }
        }
    }
    
    func startLoading() {
        guard let indicator = activityIndicator else { return }
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    func stopLoading() {
        guard let indicator = activityIndicator else { return }
        indicator.stopAnimating()
    }
    
    func canDoAnotherTask() -> Bool{
        
        if let indicator = activityIndicator, indicator.isAnimating {
            return false
        }
        return true
    }
    
    func setTextView(with memo: Memo?) {
        guard let unwrapTextView = textView else { return }
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
        
        let attrText = NSKeyedUnarchiver.unarchiveObject(with: unwrapNewMemo.content as! Data) as? NSAttributedString
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
      
    }
    
    
    func saveCoreDataIfNeed(){
        guard let unwrapTextView = textView,
            let unwrapOldMemo = memo,
            unwrapTextView.isEdited else { return }
        
        if unwrapTextView.attributedText.length != 0 {
            let copyAttrText = unwrapTextView.attributedText.copy() as! NSAttributedString
            
            privateMOC.perform({ [unowned self] in
                self.delayAttrDic[unwrapOldMemo.objectID] = copyAttrText
                let data = NSKeyedArchiver.archivedData(withRootObject: copyAttrText)
                unwrapOldMemo.content = data as NSData
                do {
                    try self.privateMOC.save()
                    PianoData.coreDataStack.viewContext.performAndWait({
                        do {
                            try PianoData.coreDataStack.viewContext.save()
                            //지연 큐에서 제거해버리기
                            self.delayAttrDic[unwrapOldMemo.objectID] = nil
                        } catch {
                            print("Failure to save context: error: \(error)")
                        }
                    })
                } catch {
                    print("Failture to save context error: \(error)")
                }
            })

        } else {
            PianoData.coreDataStack.viewContext.delete(unwrapOldMemo)
            PianoData.save()
        }
    }
    
    func saveCoreDataWhenExit(isTerminal: Bool) {
        
        if let unwrapTextView = textView,
            let unwrapOldMemo = memo,
            unwrapTextView.isEdited {
            
            if unwrapTextView.attributedText.length != 0 {
                //지금 있는 것도 대기열에 넣기
                delayAttrDic[unwrapOldMemo.objectID] = unwrapTextView.attributedText
            } else {
                if isTerminal {
                    PianoData.coreDataStack.viewContext.delete(unwrapOldMemo)
                }
            }
        }
        
        //대기열에 있는 모든 것들 순차적으로 저장
        for (id, value) in delayAttrDic {
            do {
                let memo = try PianoData.coreDataStack.viewContext.existingObject(with: id) as! Memo
                let data = NSKeyedArchiver.archivedData(withRootObject: value)
                memo.content = data as NSData
                
            } catch {
                print(error)
            }
        }
        //다 저장했으면 지우기
        delayAttrDic.removeAll()
        
        do {
            try PianoData.coreDataStack.viewContext.save()
        } catch {
            print(error)
        }
    }
    
    //TODO: 다음 업데이트때 이거 수정해야함 위의 함수와 유사함
    func saveCoreDataIfIphone(){
        guard let unwrapTextView = textView, let unwrapOldMemo = memo else { return }
        
        if unwrapTextView.attributedText.length == 0 {
            PianoData.coreDataStack.viewContext.delete(unwrapOldMemo)
            PianoData.save()
        }
    }
    
    weak var delegate: DetailViewControllerDelegate?
    @IBOutlet weak var topView: UIStackView!
    @IBOutlet var accessoryView: UIStackView!
    @IBOutlet weak var label: PianoLabel!
    @IBOutlet weak var textView: PianoTextView!
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    @IBOutlet weak var colorEffectButton: EffectButton!
    @IBOutlet weak var sizeEffectButton: EffectButton!
    @IBOutlet weak var lineEffectButton: EffectButton!
    var isAfterViewDidAppear: Bool = false
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var composeBarButton: UIBarButtonItem!
    var firstImage : UIImage?
    
    
    //앨범에서 이미지를 가져오기 위한 이미지 피커 컨트롤러
    lazy var imagePicker: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.allowsEditing = false
        controller.sourceType = .photoLibrary
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO: 업데이트할 때 이 참조 지우기
        textView.detailViewController = self
        
        textView.inputAccessoryView = accessoryView
        textView.canvas.delegate = label
        textView.layoutManager.delegate = self
        
        setEffectButton()
        setFontAwesomeIcon()
        
        accessoryView.frame.size.height = navigationController!.toolbar.frame.height
        
        PianoData.coreDataStack.detailViewController = self
        
        
        //viewDidLoad() 에서 memo == nil 일 때는 아이패드에서 맨 처음 실행했을 경우에만이므로 이때에는 최상위의 폴더에서 최상위 메모를 선택하게 함
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
    }
    

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) {[unowned self] (_) in
            guard let textView = self.textView else { return }
            if textView.mode != .typing {
                textView.attachCanvas()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.keyboardDidHide(notification:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardDidHide, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TextEffect" {
            let selectedButton = sender as! EffectButton
            let des = segue.destination as! SelectEffectViewController
            des.selectedButton = selectedButton
        }
    }
    
    func showTopView(bool: Bool) {
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //TODO: 코드 리펙토링제대로하기
        textView.isWaitingState = false
        appearKeyboardIfNeeded()
        appearKeyboardIfNeeded = { }
    }
    
    func resetTextViewAttribute(){
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
    }
    
    func keyboardWillShow(notification: Notification){
        textView.isWaitingState = true
        
        guard let userInfo = notification.userInfo,
            let kbFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
            let height = navigationController?.toolbar.bounds.height else { return }
        
        
       //kbFrame의 y좌표가 실제로 키보드의 위치임 따라서 화면 높이에서 프레임 y를 뺸 게 바텀이면 됨!
        let inset = UIEdgeInsetsMake(0, 0, UIScreen.main.bounds.height - kbFrame.origin.y - height, 0)
        textView.contentInset = inset
        textView.scrollIndicatorInsets = inset
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    func keyboardDidHide(notification: Notification) {
        textView.makeTappable()
    }
    
    func keyboardWillHide(notification: Notification){
        textView.makeUnableTap()
        
        textView.contentInset = UIEdgeInsets.zero
        textView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func removeSubrange(from: Int) {
        //layoutManager에서 접근을 해야 캐릭터들을 올바르게 지울 수 있음(안그러면 이미지가 다 지워져버림)
        let range = NSMakeRange(from, textView.selectedRange.location - from)
        textView.layoutManager.textStorage?.deleteCharacters(in: range)
        textView.selectedRange = NSRange(location: from, length: 0)
    }
    
    func setEffectButton() {
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
    
    func setTextViewEditedState() {
        textView.isEdited = true
        memo?.date = NSDate()
    }
    
    @IBAction func tapFinishEffectButton(_ sender: EffectButton) {
        tapFinishEffect()
        setTextViewEditedState()
    }
    
    func tapFinishEffect() {
        showTopView(bool: false)
        textView.canvas.removeFromSuperview()
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
    
    func returnEmailStringBase64EncodedImage(image:UIImage) -> String {
        let imgData = UIImagePNGRepresentation(image)!
        let dataString = imgData.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
        return dataString
    }
    
    func parseToHTMLString(from: NSAttributedString) -> String {
        let attr = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
        do {
            let data = try from.data(from: NSMakeRange(0, from.length), documentAttributes: attr)
            guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else { return ""}
            return htmlString
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
    
    @IBAction func tapSendEmail(_ sender: Any) {
        guard canDoAnotherTask() else { return }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        DispatchQueue.main.async { [unowned self] in
            guard let attrText = self.textView.attributedText else { return }
            let mail:MFMailComposeViewController = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            let mutableAttrText = NSMutableAttributedString(attributedString: attrText)
            
            attrText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, attrText.length), options: []) { (value, range, stop) in
                
                guard let attachment = value as? NSTextAttachment,
                    let image = attachment.image,
                    let data = UIImagePNGRepresentation(image) else { return }
                
                mail.addAttachmentData(data, mimeType: "image/png", fileName: "piano\(range.location).png")
                mutableAttrText.replaceCharacters(in: range, with: NSAttributedString(string: "\n"))
            }
            
            attrText.enumerateAttribute(NSFontAttributeName, in: NSMakeRange(0, attrText.length), options: []) { (value, range, stop) in
                guard let font = value as? UIFont else { return }
                
                let newFont = font.withSize(font.pointSize - 4)
                mutableAttrText.addAttributes([NSFontAttributeName : newFont], range: range)
            }
            
            mail.setMessageBody(self.parseToHTMLString(from: mutableAttrText), isHTML:true)
            
            if MFMailComposeViewController.canSendMail() {
                self.present(mail, animated: true, completion:nil)
            } else {
                self.showSendMailErrorAlert()
            }
            
            self.activityIndicator.stopAnimating()
            self.textView.makeTappable()
        }
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "EmailErrorTitle".localized(withComment: "메일을 보낼 수 없습니다."), message: "CheckDeviceOrInternet".localized(withComment: "디바이스 혹은 인터넷 상태를 확인해주세요"), preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK".localized(withComment: "확인"), style: .cancel, handler: nil)
        sendMailErrorAlert.addAction(cancel)
        present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
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
    
    func moveMemoToTrash() {
        //현재 메모 존재 안하면 리턴
        guard canDoAnotherTask() else { return }
        guard let unwrapMemo = memo else { return }
        
        
        //존재하면 휴지통에 넣기
        unwrapMemo.isInTrash = true
        PianoData.save()
        
        //마스터 뷰 컨트롤러에 현재 폴더의 첫번째 메모가 있는 지 체크 (없으면 닐 대입)
        
        
        guard let unwrapFirstMemo = masterViewController?.memoResultsController.fetchedObjects?.first
            else {
                self.memo = nil
                return }
        self.memo = unwrapFirstMemo
        delegate?.detailViewController(self, addMemo: unwrapFirstMemo)
    }
    
    @IBAction func tapTrashButton(_ sender: Any) {
        
        //존재하면 우선 팝업 보여줬는지 체크하고 안보여줬다면 팝업보여주기
        if hasShownTrashAlert() {
            moveMemoToTrash()
        } else {
            showTrashInfoAlert { [unowned self] in
                self.moveMemoToTrash()
            }
        }
        
        
    }
    
    
    
    @IBAction func tapEffectButton(_ sender: Any) {
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
    }
    
    func textChanged(sender: AnyObject) {
        let tf = sender as! UITextField
        var resp : UIResponder! = tf
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[1].isEnabled = (tf.text != "")
    }
    
    func showAddGroupAlertViewController() {
        let alert = UIAlertController(title: "AddFolderTitle".localized(withComment: "폴더 생성"), message: "AddFolderMessage".localized(withComment: "폴더의 이름을 적어주세요."), preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel".localized(withComment: "취소"), style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "Create".localized(withComment: "생성"), style: .default) { [unowned self](action) in
            guard let text = alert.textFields?.first?.text else { return }
            let context = PianoData.coreDataStack.viewContext
            do {
                let newFolder = Folder(context: context)
                newFolder.name = text
                newFolder.date = NSDate()
                newFolder.memos = []
                
                try context.save()
                
                guard let masterViewController = self.delegate as? MasterViewController else { return }
                masterViewController.fetchFolderResultsController()
                masterViewController.selectSpecificFolder(selectedFolder: newFolder)
            } catch {
                print("Error importing folders: \(error.localizedDescription)")
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
        
        present(alert, animated: true, completion: nil)
    }
    
    func addNewMemo() {
        
        guard let unwrapFolder = masterViewController?.folder else {
            showAddGroupAlertViewController()
            return
        }
        
        let memo = Memo(context: PianoData.coreDataStack.viewContext)
        memo.content = NSKeyedArchiver.archivedData(withRootObject: NSAttributedString()) as NSData
        memo.date = NSDate()
        memo.folder = unwrapFolder
        memo.firstLine = "NewMemo".localized(withComment: "새로운 메모")
        PianoData.save()
        
        delegate?.detailViewController(self, addMemo: memo)
        self.memo = memo
    }
    
    @IBAction func tapComposeButton(_ sender: Any) {
        guard canDoAnotherTask() else { return }
        let item = sender as! UIBarButtonItem
        item.isEnabled = false
        
        let deadline = DispatchTime.now() + .milliseconds(50)
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            self?.addNewMemo()
            item.isEnabled = true
        }
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
        
        setTextViewEditedState()
        updateCellInfo()
    }
    
    
    @IBAction func tapAlbumButton(_ sender: Any) {
        guard canDoAnotherTask() else { return }
        guard let _ = masterViewController?.folder else {
            showAddGroupAlertViewController()
            return
        }
        showImagePicker()
        iskeyboardAlbumButtonTouched = false
    }
    
    @IBAction func tapAlbumButton2(_ sender: Any) {
        guard canDoAnotherTask() else { return }
        guard let _ = masterViewController?.folder else {
            showAddGroupAlertViewController()
            return
        }
        textView.resignFirstResponder()
        showImagePicker()
        iskeyboardAlbumButtonTouched = true
    }
    
    func showImagePicker() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .restricted, .denied:
            presentPermissionErrorAlert()
        default:
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapKeyboardHideButton(_ sender: Any) {
        guard canDoAnotherTask() else { return }
        textView.resignFirstResponder()
    }
    
    func presentPermissionErrorAlert() {
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
    
}

extension DetailViewController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }
}

extension DetailViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard memo != nil else {
            addNewMemo()
            return
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        setTextViewEditedState()
        updateCellInfo()
    }
    
    //첫번째 이미지 캐싱해놓고, 첫번째 attachment 이미지와 캐싱한 이미지가 다를 경우에만 실행
    func updateCellInfo() {
        guard let memo = self.memo,
            let textView = self.textView,
            let attrText = textView.attributedText else { return }
        
        let text = textView.text.trimmingCharacters(in: .symbols).trimmingCharacters(in: .newlines)
        let firstLine: String
        switch text {
        case let x where x.characters.count > 50:
            firstLine = x.substring(to: x.index(x.startIndex, offsetBy: 50))
        case let x where x.characters.count == 0:
            //이미지만 있는 경우에도 해당됨
            firstLine = "NewMemo".localized(withComment: "새로운 메모")
        default:
            firstLine = text
        }
        
        memo.firstLine = firstLine
        
        let hasAttachments = attrText.containsAttachments(in: NSMakeRange(0, attrText.length))
        
        guard hasAttachments else {
            memo.imageData = nil
            return
        }
        
        attrText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, attrText.length), options: []) { (value, range, stop) in
            
            guard let attachment = value as? NSTextAttachment,
                let image = attachment.image else { return }
            
            guard firstImage != image else {
                stop.pointee = true
                return
            }
            
            firstImage = image
            
            let oldWidth = image.size.width;
            
            //I'm subtracting 10px to make the image display nicely, accounting
            //for the padding inside the textView
            let ratio = 60 / oldWidth;
            
            let size = image.size.applying(CGAffineTransform(scaleX: ratio, y: ratio))
            UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
            image.draw(in: CGRect(origin: CGPoint.zero, size: size))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let scaledImage = scaledImage, let data = UIImagePNGRepresentation(scaledImage) {
                memo.imageData = data as NSData
                stop.pointee = true
            }
            
        }
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
        var selectedRange = iskeyboardAlbumButtonTouched ? textView.selectedRange : NSMakeRange(textView.attributedText.length, 0)
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            if memo == nil {
                addNewMemo()
            }
            
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
            let spaceString = NSAttributedString(string: "\n", attributes: [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body)])
            
            attributedString.insert(attrStringWithImage, at: selectedRange.location)
            attributedString.insert(spaceString, at: selectedRange.location + 1)
            attributedString.addAttributes([NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)], range: NSMakeRange(selectedRange.location, 2))
            textView.attributedText = attributedString
            selectedRange.location += 2
        }
        updateCellInfo()
        setTextViewEditedState()
        textView.makeTappable()
        textView.selectedRange = selectedRange
        dismiss(animated: true, completion: nil)
        
        
        if iskeyboardAlbumButtonTouched {
            textView.appearKeyboard()
            iskeyboardAlbumButtonTouched = false
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.textView.scrollRangeToVisible(NSMakeRange(self.textView.selectedRange.location + 3, 0))
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        textView.makeTappable()
        dismiss(animated: true, completion: nil)
        
        
        if iskeyboardAlbumButtonTouched {
            textView.appearKeyboard()
            iskeyboardAlbumButtonTouched = false
        }
    }

}


extension DetailViewController: MFMailComposeViewControllerDelegate {
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
