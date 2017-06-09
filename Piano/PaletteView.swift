//
//  PaletteView.swift
//  Piano
//
//  Created by dalong on 2017. 6. 2..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

enum TextEffect {
    case color(UIColor)
    case title(UIFontTextStyle)
    case line(LineFamily)
}

protocol effectShowable: class {
    func setEffect(textEffect: TextEffect)
}

class PaletteView: UIView {
    @IBOutlet weak var colorEffectButton: EffectButton!
    @IBOutlet weak var sizeEffectButton: EffectButton!
    @IBOutlet weak var lineEffectButton: EffectButton!
    
    weak var delegate: effectShowable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        // setTextEffect
        colorEffectButton.textEffect = .color(.red)
        sizeEffectButton.textEffect = .title(.title3)
        lineEffectButton.textEffect = .line(.strikethrough)
        
        // setTitle: setFontAwesomeIcon
        colorEffectButton.setTitle("\u{f031}", for: .normal)
        sizeEffectButton.setTitle("\u{f1dc}", for: .normal)
        lineEffectButton.setTitle("\u{f0cc}", for: .normal)
    }
    
    private func didSelectButton(button: EffectButton) {
        delegate?.setEffect(textEffect: button.textEffect)
        /*
        switch button.textEffect {
        case .color(let x):
            self.setTitleColor(x, for: .selected)
            self.setTitleColor(x.withAlphaComponent(0.3), for: .normal)
        case .line(let x):
            self.setTitle(x != .strikethrough ?  "\u{f0cd}" : "\u{f0cc}", for: .selected)
            self.setTitle(x != .strikethrough ?  "\u{f0cd}" : "\u{f0cc}", for: .normal)
        case .title(let x):
            let font = UIFont.preferredFont(forTextStyle: x)
            let size = font.pointSize + CGFloat(6)
            titleLabel?.font = titleLabel?.font.withSize(size)
        }
        */
    }
    
    // MAKR: touch events - 추후 기능 업데이트 예정(Tab&Drag&Up)
    @IBAction func tapFinishEffectButton(_ sender: EffectButton) {
        tapFinishEffect()
        //setTextViewEditedState()
    }
    
    func tapFinishEffect() {
        //showTopView(bool: false)
        //textView.canvas.removeFromSuperview()
    }
    
    @IBAction func tapColorEffectButton(_ sender: EffectButton) {
        if colorEffectButton.isSelected {
            //기존에 이미 선택되어 있다면 효과 선택화면 띄워주기
            //performSegue(withIdentifier: "TextEffect", sender: sender)
        }
        
        //textView.canvas.textEffect = sender.textEffect
        
        colorEffectButton.isSelected = true
        sizeEffectButton.isSelected = false
        lineEffectButton.isSelected = false
    }
    
    @IBAction func tapSizeEffectButton(_ sender: EffectButton) {
        if sizeEffectButton.isSelected {
            //기존에 이미 선택되어 있다면 크기 선택화면 띄워주기
            //performSegue(withIdentifier: "TextEffect", sender: sender)
        }
        
        //textView.canvas.textEffect = sender.textEffect
        
        colorEffectButton.isSelected = false
        sizeEffectButton.isSelected = true
        lineEffectButton.isSelected = false
    }
    
    @IBAction func tapLineEffectButton(_ sender: EffectButton) {
        if lineEffectButton.isSelected {
            //기존에 이미 선택되어 있다면 라인 선택화면 띄워주기
            //performSegue(withIdentifier: "TextEffect", sender: sender)
        }
        
        //textView.canvas.textEffect = sender.textEffect
        colorEffectButton.isSelected = false
        sizeEffectButton.isSelected = false
        lineEffectButton.isSelected = true
    }
}

class EffectButton: UIButton {
    var textEffect: TextEffect = .color(.red)
}
