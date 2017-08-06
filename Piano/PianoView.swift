//
//  PianoView.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 17..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class PianoView: UIView {
    
    //MARK: Public
    public var attributeStyle = PianoAttributeStyle.color
    
    //MARK: Private
    private var cosPeriod_half: CGFloat = 70 //이거 Designable
    private var cosMaxHeight: CGFloat = 35  //이것도 Designable
    
    private var totalFrame: Int = 0
    private var currentFrame: Int = 0
    private var progress: CGFloat = 0.0
    
    private var currentTouchX: CGFloat?
    private var leftEndTouchX: CGFloat?
    private var rightEndTouchX: CGFloat?
    private var animating: Bool = false
    
    //Test flag
    private let fontChange: Bool = true
    
    private var pianoData: PianoViewData?
    
    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(
            target: self,
            selector: #selector(PianoView.displayFrameTick))
        displayLink.add(
            to: RunLoop.current,
            forMode: RunLoopMode.commonModes)
        return displayLink
    }()
    
    @objc private func displayFrameTick() {
        if displayLink.duration > 0.0 && totalFrame == 0 {
            let frameRate = displayLink.duration
            totalFrame = Int(PianoGlobal.duration / frameRate) + 1
        }
        currentFrame += 1
        if currentFrame <= totalFrame {
            progress += 1.0 / CGFloat(totalFrame)
        } else {
            displayLink(on: false)
        }
    }
    
    private func updateCoordinateXs(with pointX: CGFloat) {
        leftEndTouchX = leftEndTouchX ?? pointX
        rightEndTouchX = rightEndTouchX ?? pointX
        currentTouchX = pointX
        
        if pointX < leftEndTouchX!{
            leftEndTouchX = pointX
        }
        
        if pointX > rightEndTouchX! {
            rightEndTouchX = pointX
        }
    }
    
    private func updateLabels(to touchX: CGFloat){
        guard let data = pianoData else { return }
        backgroundColor = UIColor.white.withAlphaComponent(progress * 0.9)
        for labelInfo in data.labelInfos {
            applyAttrToLabel(by: touchX, in: labelInfo)
            moveLabel(by: touchX, in: labelInfo)
        }
    }
    
    private func applyAttrToLabel(by touchX: CGFloat, in labelInfo: (label: UILabel, center: CGPoint, frame: CGRect, font: UIFont)){
        guard let leftTouchX = leftEndTouchX,
            let rightTouchX = rightEndTouchX else { return }
        
        guard let attrText = labelInfo.label.attributedText else { return }
        let labelRightEdge = labelInfo.frame.origin.x + labelInfo.frame.width
        let labelLeftEdge = labelInfo.frame.origin.x
        
        let applyAttribute = touchX > labelRightEdge && leftTouchX < labelRightEdge
        let removeAttribute = touchX < labelLeftEdge && rightTouchX > labelLeftEdge
        
        if applyAttribute {
            let attr = attributeStyle.attr()
            
            let mutableAttrText = NSMutableAttributedString(attributedString: attrText)
            mutableAttrText.addAttributes(attr, range: NSMakeRange(0, mutableAttrText.length))
            labelInfo.label.attributedText = mutableAttrText
            
        } else if removeAttribute {
            
            let mutableAttrText = NSMutableAttributedString(attributedString: attrText)
            mutableAttrText.addAttributes(attributeStyle.removeAttr(), range: NSMakeRange(0, mutableAttrText.length))
            labelInfo.label.attributedText = mutableAttrText
        }
        
        if let size = labelInfo.label.attributedText?.size() {
            labelInfo.label.frame.size = size
        }
        
        
    }
    
    private func moveLabel(by touchX: CGFloat, in labelInfo: (label: UILabel, center: CGPoint, frame: CGRect, font: UIFont)){
        let distance = abs(touchX - labelInfo.center.x)
        
        if distance < cosPeriod_half {
            let y = cosMaxHeight * (cos(CGFloat.pi * distance / cosPeriod_half ) + 1) * progress
            
            labelInfo.label.frame.origin.y = labelInfo.frame.origin.y - y
            
            if fontChange {
                //issue: 폰트 크기 크게, 소숫점 폰트 사이즈이면 렉 심해서 반올림함
                let largeFontSize = round(labelInfo.font.pointSize + y / 4)
                labelInfo.label.font = labelInfo.font.withSize(largeFontSize)
                
                //폰트 중앙 고정
                labelInfo.label.center.x = labelInfo.center.x
                
                if let size = labelInfo.label.attributedText?.size() {
                    labelInfo.label.frame.size = size
                }
            }
            
            if !(touchX > labelInfo.frame.origin.x && touchX < labelInfo.frame.origin.x + labelInfo.frame.size.width){
                //TODO: distance = 0일수록 알파값 0.3에 가까워지게 하기
                labelInfo.label.alpha = distance / cosPeriod_half + PianoGlobal.transparent
            } else {
                labelInfo.label.alpha = PianoGlobal.opacity
            }
        } else {
            //폰트 크기 고정
            if fontChange {
                labelInfo.label.font = labelInfo.font
            }
            
            //프레임 원복
            labelInfo.label.center = labelInfo.center
            labelInfo.label.frame = labelInfo.frame
            
            //알파값 세팅
            labelInfo.label.alpha = PianoGlobal.opacity
        }
    }
    
    private func attachLabels(){
        guard let data = pianoData else { return }
        for labelInfo in data.labelInfos {
            addSubview(labelInfo.label)
        }
    }
    
    private func displayLink(on: Bool) {
        displayLink.isPaused = !on
    }
    
    private func set(pianoData: PianoViewData) {
        self.pianoData = pianoData
    }
    
    private func animateToOriginalPosition(completion: @escaping CaptivateResult) {
        guard let data = pianoData else { return }
        animating = true
        
        UIView.animate(withDuration: PianoGlobal.duration, animations: { [weak self] in
            guard let strongSelf = self else { return }
            self?.backgroundColor = UIColor.white.withAlphaComponent(0)
            for labelInfo in data.labelInfos {
                
                if strongSelf.fontChange {
                    let ratioWidth = labelInfo.frame.width / labelInfo.label.frame.width
                    let ratioHeight = labelInfo.frame.height / labelInfo.label.frame.height
                    labelInfo.label.transform = CGAffineTransform(scaleX: ratioWidth, y: ratioHeight)
                    
                }
                labelInfo.label.center = labelInfo.center
                labelInfo.label.alpha = PianoGlobal.opacity
            }
            }, completion: { [weak self](_) in
                if let result = self?.transformResultForEffectable() {
                    completion(result)
                }
                
                self?.resetPianoViewState()
        })
    }
    
    private func resetPianoViewState(){
        guard let data = pianoData else { return }
        
        for labelInfo in data.labelInfos {
            labelInfo.label.removeFromSuperview()
        }
        
        pianoData = nil
        currentFrame = 0
        totalFrame = 0
        progress = 0
        leftEndTouchX = nil
        rightEndTouchX = nil
        animating = false
    }
    
    private func transformResultForEffectable() -> PianoResult? {
        guard let data = pianoData,
            let touchX = currentTouchX,
            let leftTouchX = leftEndTouchX,
            let rightTouchX = rightEndTouchX
            else { return nil }
        
        let y = data.rect.origin.y
        let final = CGPoint(x: touchX, y: y)
        let farLeft = CGPoint(x: leftTouchX, y: y)
        let farRight = CGPoint(x: rightTouchX, y: y)
        let result = PianoResult(final: final, farLeft: farLeft, farRight: farRight, applyAttribute: attributeStyle.attr(), removeAttribute: attributeStyle.removeAttr())
        return result
    }
}

extension PianoView: Pianoable {
    func preparePiano(with dataTrigger: PianoViewDataTrigger) {
        guard !animating else { return }
        if pianoData == nil {
            set(pianoData: dataTrigger())
            attachLabels()
            displayLink(on: true)
        }
    }
    
    func playPiano(previousX: CGFloat, currentX: CGFloat) {
        guard !animating else { return }
        updateCoordinateXs(with: currentX)
        updateLabels(to: currentX)
    }
    
    func endPiano(completion: @escaping CaptivateResult) {
        animateToOriginalPosition(completion: completion)
    }
}

