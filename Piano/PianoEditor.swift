//
//  PianoEditor.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

enum PianoMode: Int {
    case on = 0
    case off
}

protocol Navigatable: class {
    func moveToNoteListViewController(with folderNum: Int)
    func moveToPreferenceViewController()
    func moveToNewMemo()
}

class PianoEditor: UIView {
    
    // MARK: property
    @IBOutlet weak var textView: PianoTextView!
    @IBOutlet weak var pianoView: PianoView!
    @IBOutlet var topButtons: [UIButton]!
    @IBOutlet weak var palleteViewTop: NSLayoutConstraint!
    @IBOutlet weak var completeButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var controlPanelBottom: NSLayoutConstraint!
    
    weak var delegate: Navigatable?
    
    // MARK: init
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        movePalleteViewsOff()
    }
    
    //MARK: Public
    @IBAction func tapPalleteButton(_ sender: UIButton) {
        setPianoViewAttributeStyle(by: sender)
        changeAlpha(for: sender)
    }
    
    @IBAction func tapCompleteButton(_ sender: UIButton){
        animate(for: PianoMode.off)
    }
    
    @IBAction func tapPianoButton(_ sender: UIButton){
        animate(for: PianoMode.on)
    }
    
    @IBAction func tapListButton(_ sender: UIButton){
        //TODO: first 폴더가 아닌 가지고 있는 메모의 스테틱 폴더 넘버로 폴더 찾아 넘겨주기
        delegate?.moveToNoteListViewController(with: 0)
    }
    
    @IBAction func tapSettingButton(_ sender: UIButton){
        ActivityIndicator.startAnimating()
        
        DocumentRenderer.render(type: .pdf, with: textView) { (pdfURL: URL?) in
            ActivityIndicator.stopAnimating()
            
            guard let url = pdfURL else { return }
            
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            AppNavigator.present(activityViewController)
        }
    }
    
    
    public func animate(for mode: PianoMode) {
        let (palleteViewTop, completeButtonBottom, controlPanelBottom, completion) = animateValues(for: mode)
        
        UIView.animate(withDuration: PianoGlobal.duration, animations: { [weak self] in
            self?.palleteViewTop.constant = palleteViewTop
            self?.completeButtonBottom.constant = completeButtonBottom
            self?.controlPanelBottom.constant = controlPanelBottom
            self?.layoutIfNeeded()
        }) { (_) in
            completion()
        }
    }
    
    //MARK: Private
    
    private func movePalleteViewsOff(){
        palleteViewTop.constant = -100
        completeButtonBottom.constant = -44
    }
    
    private func setup() {
        textView.control.pianoable = pianoView
        textView.control.effectable = textView
        textView.delegate = self
    }
    
    private func setPianoViewAttributeStyle(by button: UIButton) {
        guard let style = PianoAttributeStyle(rawValue: button.tag) else { return }
        pianoView.attributeStyle = style
    }
    
    private func changeAlpha(for selectedButton: UIButton){
        for button in topButtons {
            UIView.animate(withDuration: PianoGlobal.duration, animations: {
                if button == selectedButton {
                    button.alpha = PianoGlobal.opacity
                } else {
                    button.alpha = PianoGlobal.transparent
                }
            })
        }
    }
    
    private func animateValues(for mode: PianoMode) -> (CGFloat, CGFloat, CGFloat, completion: () -> Void) {
        let palleteViewTop: CGFloat
        let completeButtonBottom: CGFloat
        let controlPanelBottom: CGFloat
        let completion: () -> Void
        
        switch mode {
        case .on:
            palleteViewTop = 0
            completeButtonBottom = 0
            controlPanelBottom = -45
            completion = { [weak self] in
                self?.textView.isEditable = false
                self?.textView.isSelectable = false
                self?.textView.attachControl()
                self?.textView.setOffsetForPreventBug()
            }
        case .off:
            palleteViewTop = -100
            completeButtonBottom = -44
            controlPanelBottom = 7
            completion = { [weak self] in
                self?.textView.isEditable = true
                self?.textView.isSelectable = true
                self?.textView.detachControl()
            }
        }
        return (palleteViewTop, completeButtonBottom, controlPanelBottom, completion)
    }
}

// MARK: UITextViewDelegate
extension PianoEditor : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        showMirroring(textView)
    }
    
    private func showMirroring(_ textView: UITextView) {
        guard let pianoTextView = textView as? PianoTextView, let inputAccessoryView = pianoTextView.inputAccessoryView as? MRInputAccessoryView else { return }
        inputAccessoryView.mrScrollView.showMirroring(from: textView)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        showMirroring(textView)
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
    
//    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        <#code#>
//    }
    
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//
//
//        //TODO: 문단을 먼저 추출하고 돌려야함
//
//
//        let paragraphRange = (textView.text as NSString).paragraphRange(for: textView.selectedRange)
//        textView.attributedText.enumerateAttribute(.attachment, in: paragraphRange, options: []) { (value, range, stop) in
//            if textView.selectedRange.location <= range.location {
//                textView.insertText("\n\n")
//                textView.selectedRange.location -= 2
//            } else {
//                textView.insertText("\n")
//                //                    textView.selectedRange.location += 1
//            }
//
//            stop.pointee = true
//        }
//
//
//
//
//        return true
//    }
//
    
     internal func textViewDidChange(_ textView: UITextView) {
     guard let textView = textView as? PianoTextView else { return }
     
//     textView.chainElements()
//     textView.detectIndent()
     
//     textChangedHandler?(textView.attributedText)
     }
     
//     func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//     guard let textView = textView as? PianoTextView else { return true}
//
//     return textView.addElementIfNeeded(text as NSString, in: range)
//     }
 
}
