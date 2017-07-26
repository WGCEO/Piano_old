//
//  NoteViewController.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//
import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet weak var editor: PianoEditor!
    @IBOutlet weak var bottomViewBottom: NSLayoutConstraint!
    @IBOutlet weak var completeButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var topViewTop: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func tapFolderSpecificationButton(_ sender: Any) {
        //폴더가 한개도 없다면 얼럿을 띄우기
        
        //폴더가 있다면 모달로 이동
    }
    
    @IBAction func tapPianoButton(_ sender: UIButton) {
        
        animate(for: PianoMode.on)
        editor.animate(for: PianoMode.on)
    }
    
    @IBAction func tapCompleteButton(_ sender: UIButton) {
        
        animate(for: PianoMode.off)
        editor.animate(for: PianoMode.off)
    }
    
    @IBAction func tapImagePicker(_ sender: UIButton){
        
    }
    
    @IBAction func tapShareButton(_ sender: Any) {
        guard let htmlString = editor.textView.attributedText.parseToHTMLString() else { return }
        
        let renderer = DocumentRenderer()
        let pdfDocument = renderer.render(type: .pdf, with: editor.textView)
        
        let activityViewController = UIActivityViewController(activityItems: [pdfDocument], applicationActivities: nil)
        AppNavigator.present(activityViewController)
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
}
