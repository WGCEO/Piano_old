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
        return ActivityIndicator.sharedInstace.isAnimating
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
            memo = MemoManager.selectedMemo()
        }
        
        showMemo()
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
    
    // MARR: setup views
    private func showMemo() {
        editor?.attributedText = memo?.attrbutedString
    }
    
    private func createAlertController() {
        /*
         let alert = UIAlertController(title: "AddFolderTitle".localized(withComment: "폴더 생성"), message: "AddFolderMessage".localized(withComment: "폴더의 이름을 적어주세요."), preferredStyle: .alert)
         
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
         */
    }
    
    // MARK: segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        editor.resignFirstResponder()
        
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
        let content = memo?.attrbutedString ?? NSAttributedString()
        MailSender.sendMail(with: content) { [weak self] in
            //self?.editor.makeTappable()
        }
    }
    
    // TODO: 실질적으로 기능은 비슷하므로 sender로 구분하는 것으로 변경 
    @IBAction func tapAlbumButton(_ sender: Any) {
        if !canDoAnotherTask { return }
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .restricted, .denied:
            showPermissionErrorAlert()
        default:
            showImagePicker()
        }
    }
    
    private func showImagePicker() {
        ImagePicker.pickImage { [weak self] (image) in
            self?.addImageToEditor()
        }
    }
    
    private func showPermissionErrorAlert() {
        let alert = UIAlertController.makePermissionErrorAlert()
        
        AppNavigator.present(alert)
    }
    
    private func addImageToEditor() {
        /*
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
         */
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

extension MemoViewController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }
}

extension Memo {
    var attrbutedString: NSAttributedString? {
        guard let data = content as Data? else { return nil }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? NSAttributedString
    }
}
