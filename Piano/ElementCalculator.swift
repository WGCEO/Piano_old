//
//  ElementKerner.swift
//  Piano
//
//  Created by dalong on 2017. 7. 23..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

let dotKerningRate: CGFloat = 0.3
let standardText = "4" as NSString

fileprivate struct VariableContainer: Hashable {
    let font: UIFont
    let elementType: ElementType
    let unitType: UnitType
    
    var hashValue: Int {
        return font.hashValue
    }
    
    init(_ elementType: ElementType, _ unitType: UnitType, _ font: UIFont) {
        self.elementType = elementType
        self.unitType = unitType
        self.font = font
    }
    
    static func ==(lhs: VariableContainer, rhs: VariableContainer) -> Bool {
        return lhs.font.hashValue == rhs.font.hashValue
            && lhs.elementType.hashValue == rhs.elementType.hashValue
            && lhs.unitType.hashValue == rhs.unitType.hashValue
    }
}

class ElementCalculator {
    static let sharedInstance = ElementCalculator()
    
    private var widthCache: [VariableContainer: CGFloat] = [:]
    private var kerningCache: [VariableContainer: CGFloat] = [:]
    
    // MARK: - life cycle
    private init() {
        
    }
    
    // MARK: - public methods
    public func enumerateKerning(with element: Element, font: UIFont, handler: ((_ kerning: CGFloat, _ unit: Unit)->Void)?) {
        element.enumerateUnits { [weak self] (unit) in
            if let kerning = self?.calculateKerning(elementType: element.type, unitType: unit.type, font: font) {
                handler?(kerning, unit)
            }
        }
    }
    
    public func calculateWidth(with element: Element, font: UIFont) -> CGFloat {
        let variableContainer = VariableContainer(element.type, .none, font)
        if let value = widthCache[variableContainer] {
            return value
        }
        
        var width = calculateWhiteSpaceWidth(with: font)
        width += calculateDotWidth(with: font) * (dotKerningRate + 1)
        
        if element.type == .number {
            let numberRange = NSMakeRange(0, element.range.length - 2)
            let numberText = element.text.substring(with: numberRange) as NSString
            
            width += calculateTextWidth(with: numberText, font: font)
        } else if element.type == .list {
            width += calculateCharacterWidth(with: "•", font: font)
        }
        
        widthCache[variableContainer] = width
        return width
    }
    
    // MARK: - calculate kerning
    private func calculateKerning(elementType: ElementType, unitType: UnitType, font: UIFont) -> CGFloat? {
        let variableContainer = VariableContainer(elementType, unitType, font)
        if let value = kerningCache[variableContainer] {
            return value
        }
        
        var kerning: CGFloat?
        switch elementType {
        case .number:
            kerning = calculateKerningInNumber(unitType: unitType, font: font)
        case .list:
            kerning = calculateKerningInList(unitType: unitType, font: font)
        default:
            kerning = nil
        }
        
        kerningCache[variableContainer] = kerning
        return kerning
    }
    
    private func calculateKerningInNumber(unitType: UnitType, font: UIFont) -> CGFloat? {
        switch unitType {
        case .head:
            return 0
        case .dot:
            return calculateDotWidth(with: font) * dotKerningRate
        case .whitespace:
            return 0
        case .none:
            return nil
        }
    }
    
    private func calculateKerningInList(unitType: UnitType, font: UIFont) -> CGFloat? {
        switch unitType {
        case .head:
            return calculateDotWidth(with: font) * (dotKerningRate + 1)
        case .dot:
            return nil
        case .whitespace:
            return 0
        case .none:
            return nil
        }
    }
    
    // MARK: - calculate width
    private func calculateTextWidth(with text: NSString, font: UIFont) -> CGFloat {
        var width: CGFloat = 0.0
        for character in (text as String).characters.reversed() {
            let charWidth = (String(character) as NSString).boundingRect(with: CGSize(), options: [], attributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.kern: 0], context: nil).width
            
            width += charWidth
        }
        
        return width
    }
    
    private func calculateCharacterWidth(with text: NSString, font: UIFont) -> CGFloat {
        return text.boundingRect(with: CGSize(), options: [], attributes: [NSAttributedStringKey.font : font], context: nil).width
    }
    
    private func calculateDotWidth(with font: UIFont) -> CGFloat {
        let width = ("." as NSString).boundingRect(with: CGSize(), options: [], attributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.kern: 0], context: nil).width
        
        return width
    }
    
    private func calculateWhiteSpaceWidth(with font: UIFont) -> CGFloat {
        let width = (" " as NSString).boundingRect(with: CGSize(), options: [], attributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.kern: 0], context: nil).width
        
        return width
    }
}
