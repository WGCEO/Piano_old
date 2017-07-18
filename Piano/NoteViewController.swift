//
//  NoteViewController.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet var formInputView: FormInputView!
    @IBOutlet var mrInputAccessoryView: MRInputAccessoryView!
    @IBOutlet weak var editor: PianoEditor!
    @IBOutlet weak var bottomViewBottom: NSLayoutConstraint!
    @IBOutlet weak var completeButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var topViewTop: NSLayoutConstraint!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setChildViews()
        
        //TODO: 나중에 지우기
        setTempParagraphStyle()
        // 여기까지
    }
    
    private func setChildViews(){
        editor.textView.inputAccessoryView = mrInputAccessoryView
        formInputView.delegate = editor.textView
        editor.textView.delegate = self
        //아래 코드 안 넣으면 버그 생김
        editor.textView.contentOffset.y = -64
    }
    
    private func setTempParagraphStyle(){
        let mutableString = NSMutableAttributedString(attributedString: editor.textView.attributedText)
        guard let paragraph = mutableString.attribute(NSAttributedStringKey.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle else { return }
        let mutableParagraph = NSMutableParagraphStyle()
        mutableParagraph.setParagraphStyle(paragraph)
        mutableParagraph.headIndent = 30
        mutableParagraph.firstLineHeadIndent = 30
        mutableParagraph.tailIndent = -30
        mutableParagraph.lineSpacing = 10
        mutableString.addAttributes([.paragraphStyle : mutableParagraph, .foregroundColor : PianoGlobal.defaultColor], range: NSMakeRange(0, mutableString.length))
        editor.textView.attributedText = mutableString
    }
    
    @IBAction func tapPlusButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        editor.textView.inputView = sender.isSelected ? formInputView : nil
        editor.textView.reloadInputViews()
    }
    
    @IBAction func tapFolderSpecificationButton(_ sender: Any) {
        //폴더가 한개도 없다면 얼럿을 띄우기
        
        //폴더가 있다면 모달로 이동
    }
    @IBAction func tapPianoButton(_ sender: Any) {
        animate(for: PianoMode.on)
        editor.animate(for: PianoMode.on)
    }
    
    
    @IBAction func tapCompleteButton(_ sender: UIButton) {
        
        animate(for: PianoMode.off)
        editor.animate(for: PianoMode.off)
    }
    
    @IBAction func tapImagePicker(_ sender: UIButton){
        
    }
    
    private func animate(for mode: PianoMode) {
        let (topViewTop, bottomViewBottom, completeButtonBottom) = animateValues(for: mode)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.topViewTop.constant = topViewTop
            self?.bottomViewBottom.constant = bottomViewBottom
            self?.completeButtonBottom.constant = completeButtonBottom
            self?.view.layoutIfNeeded()
        }
    }
    
    private func animateValues(for mode: PianoMode) -> (CGFloat, CGFloat, CGFloat) {
        let topViewTop: CGFloat
        let bottomViewBottom: CGFloat
        let completeButtonBottom: CGFloat
        switch mode {
        case .on:
            topViewTop = -64
            bottomViewBottom = -44
            completeButtonBottom = 0
        case .off:
            topViewTop = 0
            bottomViewBottom = 0
            completeButtonBottom = -44
        }
        return (topViewTop, bottomViewBottom, completeButtonBottom)
    }
    
    @IBAction func tapListButton(_ sender: Any) {
        let firstFolder = MemoManager.staticFolders.first
        performSegue(withIdentifier: "NoteListViewController", sender: firstFolder)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
            let folder = sender as? StaticFolder,
            identifier == "NoteListViewController" {
            let des = segue.destination as! NoteListViewController
            des.selectedFolder = folder
        }
    }
}


// MARK: UITextViewDelegate
extension NoteViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        mrInputAccessoryView.mrScrollView.showMirroring(from: textView)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        mrInputAccessoryView.mrScrollView.showMirroring(from: textView)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let textView = scrollView as? PianoTextView, !textView.isEditable else { return }
        textView.attachControl()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let textView = scrollView as? PianoTextView, !textView.isEditable, !decelerate else { return }
        textView.attachControl()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let textView = scrollView as? PianoTextView, !textView.isEditable else { return }
        textView.detachControl()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        moveTopView(from: scrollView)
        
    }
    
    private func moveTopView(from scrollView: UIScrollView){
        guard let textView = scrollView as? PianoTextView, textView.isEditable else { return }
        let offsetY = scrollView.contentOffset.y
        if (offsetY <= -PianoGlobal.navigationBarHeight) {
            topViewTop.constant = 0
        } else if (offsetY <= 0) {
            let value = -(PianoGlobal.navigationBarHeight+offsetY)
            topViewTop.constant = value
        } else {
            topViewTop.constant = -PianoGlobal.navigationBarHeight
        }
    }
    
    /*
     internal func textViewDidChange(_ textView: UITextView) {
     guard let textView = textView as? PianoTextView else { return }
     
     textView.chainElements()
     textView.detectIndent()
     
     textChangedHandler?(textView.attributedText)
     }
     
     func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
     guard let textView = textView as? PianoTextView else { return true}
     
     return textView.addElementIfNeeded(text as NSString, in: range)
     }
     */
}
