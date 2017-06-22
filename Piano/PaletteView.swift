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

protocol Effectable: class {
    func setEffect(textEffect: TextEffect)
}

class PaletteView: UIView {
    private var effectButtons: [EffectButton] = [] {
        willSet {
            removeButtons()
        } didSet {
            addButtons()
        }
    }
    
    weak var effector: Effectable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    convenience init(effectButtons: [EffectButton]) {
        self.init(frame: CGRect.zero)
        
        self.effectButtons = effectButtons
    }
    
    convenience init(frame: CGRect, effectButtons: [EffectButton]) {
        self.init(frame: frame)
        
        self.effectButtons = effectButtons
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: public
    public func setEffectButton(_ effectButtons: [EffectButton]) {
        self.effectButtons = effectButtons
    }
    
    // MARK: private
    private func configure() {
        setupEffectButtons()
        backgroundColor = PianoColor.lightGray
    }
    
    private func removeButtons() {
        for effectButton in effectButtons {
            effectButton.removeFromSuperview()
        }
    }
    
    private func addButtons() {
        for effectButton in effectButtons {
            addSubview(effectButton)
        }
        
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        let width = bounds.width/CGFloat(effectButtons.count)
        let height = bounds.height
        
        for (index, effectButton) in effectButtons.enumerated() {
            effectButton.frame = CGRect(x: width*CGFloat(index), y: 0.0, width: width, height: height)
            
        }
    }
    
    private func changeTitle(of button: EffectButton) {
        switch button.textEffect {
        case .color(let x):
            button.setTitleColor(x, for: .selected)
            button.setTitleColor(x.withAlphaComponent(0.3), for: .normal)
        case .line(let x):
            button.setTitle(x != .strikethrough ?  "\u{f0cd}" : "\u{f0cc}", for: .selected)
            button.setTitle(x != .strikethrough ?  "\u{f0cd}" : "\u{f0cc}", for: .normal)
        case .title(let x):
            let font = UIFont.preferredFont(forTextStyle: x)
            let size = font.pointSize + CGFloat(6)
            button.titleLabel?.font = button.titleLabel?.font.withSize(size)
        }
    }
    
    private func showSelectView(of selectedButton: EffectButton) {
        if selectedButton.isSelected == true {
            //AppNavigator.present("TextEffecSelectView")
        }
        
        for effectButton in effectButtons {
            if effectButton == selectedButton {
                effectButton.isSelected = true
            } else {
                effectButton.isSelected = false
            }
        }
    }

    // MARK: view configure
    private func setupEffectButtons() {
        var effectButtons: [EffectButton] = []
        
        let colorEffectButton = EffectButton()
        colorEffectButton.textEffect = .color(.red)
        colorEffectButton.setTitle("\u{f031}", for: .normal)
        colorEffectButton.setTitleColor(PianoColor.red, for: .normal)
        colorEffectButton.setTitleColor(PianoColor.red, for: .selected)
        colorEffectButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 20)
        colorEffectButton.addTarget(self, action: #selector(didSelectButton(button:)), for: .touchUpInside)
        effectButtons.append(colorEffectButton)
        
        let sizeEffectButton = EffectButton()
        sizeEffectButton.textEffect = .title(.title3)
        sizeEffectButton.setTitle("\u{f1dc}", for: .normal)
        sizeEffectButton.setTitleColor(UIColor.lightGray, for: .normal)
        sizeEffectButton.setTitleColor(PianoColor.darkGray, for: .selected)
        sizeEffectButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 26)
        sizeEffectButton.addTarget(self, action: #selector(didSelectButton(button:)), for: .touchUpInside)
        effectButtons.append(sizeEffectButton)
        
        let lineEffectButton = EffectButton()
        lineEffectButton.textEffect = .line(.strikethrough)
        lineEffectButton.setTitle("\u{f0cc}", for: .normal)
        lineEffectButton.setTitleColor(UIColor.lightGray, for: .normal)
        lineEffectButton.setTitleColor(PianoColor.darkGray, for: .selected)
        lineEffectButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 20)
        lineEffectButton.addTarget(self, action: #selector(didSelectButton(button:)), for: .touchUpInside)
        effectButtons.append(lineEffectButton)
        
        self.effectButtons = effectButtons
    }
    
    // MARK: actions
    func didSelectButton(button: EffectButton) {
        effector?.setEffect(textEffect: button.textEffect)
        
        changeTitle(of: button)
        showSelectView(of: button)
    }
}

class EffectButton: UIButton {
    var textEffect: TextEffect = .color(.red)
}
