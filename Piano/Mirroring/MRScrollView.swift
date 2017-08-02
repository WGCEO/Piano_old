//
//  MRScrollView.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class MRScrollView: UIScrollView {
    
    weak private var textView: UITextView?
    @IBOutlet weak private var mrLabel: UILabel!
    @IBOutlet weak private var mrCursorView: UIView!
    private var isTapped: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setContentInset()
    }
    
    public func showMirroring(from textView: UITextView){
        
        //1. 탭 중이거나, 숨겨져있을 때(하드웨어 키보드 연결)엔 미러링 보여주지 말기
        guard !isTapped, !isHidden else { return }
        
        //2. 텍스트뷰 참조
        if self.textView == nil {
            self.textView = textView
        }
        
        //3. paragraph스타일 기본값으로 설정하고, 폰트크기는 레이블에 맞추고 레이블에 텍스트 세팅
        let paragraphRange = (textView.text as NSString).paragraphRange(for: textView.selectedRange)
        
        let attrText = getAttrTextForMirroring(from: textView, inRange: paragraphRange)
        setAttrText(attrText)
        
        //4. 다음 두개를 세팅: 1) scrollOffsetX    2) 미러링 커서 위치
        let frontRange = NSMakeRange(0, textView.selectedRange.location - paragraphRange.location)
        
        let frontWidth = attrText.attributedSubstring(from: frontRange).size().width
        
        setScrollOffset(by: frontWidth)
        setCursorViewLocation(by: frontWidth)
 
 
    }
    
    private func getAttrTextForMirroring(from textView: UITextView, inRange range: NSRange) -> NSAttributedString {
        let attrText = textView.attributedText.attributedSubstring(from: range)
        
        let mutableAttrText = NSMutableAttributedString(attributedString: attrText)
        let mutableAttrTextRange = NSMakeRange(0, mutableAttrText.length)
        
        if mutableAttrText.length != 0 {
//            attrText.enumerateAttribute(NSAttributedStringKey.attachment, in: mutableAttrTextRange, options: [], using: { (value, range, stop) in
//                guard value is ImageTextAttachment else { return }
//                mutableAttrText = NSMutableAttributedString(string: " ")
//                mutableAttrTextRange = NSMakeRange(0, mutableAttrText.length)
//                stop.pointee = true
//            })
            
            let font = UIFont.systemFont(ofSize: PianoGlobal.mirrorFont)
            mutableAttrText.addAttributes([NSAttributedStringKey.font : font,
                                           NSAttributedStringKey.paragraphStyle : NSParagraphStyle()],
                                          range: mutableAttrTextRange)
        }
        
        return mutableAttrText
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        //1. 터치한 글자의 인덱스를 가져옴, 못가져오면 리턴
        let touch = sender.location(in: self)
        guard let glyphIndex = mrLabel.getGlyphIndex(from: touch),
            let textView = self.textView,
            let attrText = mrLabel.attributedText,
            attrText.length != 0
            else { return }
        
        //2. 미러링 커서 위치 지정. 만약 미러링된 글자들보다 왼쪽에 터치한 경우, 커서를 가장 왼쪽으로 이동
        let cursorIndex = touch.x < 0 ? glyphIndex : glyphIndex + 1
        let frontAttrText = attrText.attributedSubstring(from: NSMakeRange(0, cursorIndex))
        let frontAttrTextWidth = frontAttrText.size().width
        
        //3. 미러링 커서 위치 지정
        setCursorViewLocation(by: frontAttrTextWidth)
        
        //4. 텍스트뷰의 selectedRange 세팅
        setTextViewSelectedRange(textView: textView, byFrontText: frontAttrText.string, byCursorIndex: cursorIndex)
    }
    
    private func setContentInset(){
        //미러링 내 커서가 항상 가운데에 오게 하기 위해 미리 인셋값을 줌.
        self.contentInset.right = UIScreen.main.bounds.width / 2
        //키보드내릴때 인셋값 지정안하면 오프셋이 0으로 되는 버그가 있어서 아래 코드 삽입, 앞 영역 터치도 됨
        self.contentInset.left = UIScreen.main.bounds.width / 2
    }
    
    private func setAttrText( _ attrText: NSAttributedString) {
        mrLabel.attributedText = attrText
        self.layoutIfNeeded()
    }
    
    private func setScrollOffset(by frontWidth: CGFloat){
        let halfScreenWidth = UIScreen.main.bounds.width / 2
        let relativeCursorX = frontWidth - contentOffset.x
        
        if relativeCursorX > halfScreenWidth || relativeCursorX < 0 {
            //커서가 화면 중앙보다 오른쪽에 위치해 있을 때만 스크롤 오프셋 값 조정해, 커서 고정
            self.contentOffset.x = frontWidth - halfScreenWidth
        }
    }
    
    private func setCursorViewLocation(by frontWidth: CGFloat){
        mrCursorView.frame.origin.x = frontWidth
    }
    
    private func setTextViewSelectedRange(textView: UITextView, byFrontText text: String, byCursorIndex index: Int) {
        isTapped = true
        let range = (textView.text as NSString).paragraphRange(for: textView.selectedRange)
        
        if let character = text.characters.last, character == "\n" {
            textView.selectedRange.location = range.location + index - 1
        } else {
            textView.selectedRange.location = range.location + index
        }
        isTapped = false
    }
    
}
