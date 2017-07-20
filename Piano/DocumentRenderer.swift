//
//  PDFGenerator.swift
//  Piano
//
//  Created by dalong on 2017. 7. 18..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

enum DocumentType {
    case pdf
}

class DocumentRenderer {
    func render(type: DocumentType, with text: String) -> Data {
        switch type {
        case .pdf:
            return renderPDFDocument(with: text)
        }
    }
    
    private func renderPDFDocument(with text: String) -> Data {
        let printPageRenderer = A4PaperPrintPageRenderer()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: text)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        return drawPDFDocument(using: printPageRenderer)
    }
    
    private func drawPDFDocument(using printPageRenderer: UIPrintPageRenderer) -> Data {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        UIGraphicsBeginPDFPage()
        
        printPageRenderer.drawPage(at: 0, in: UIGraphicsGetPDFContextBounds())
        
        UIGraphicsEndPDFContext()
        
        return data as Data
    }
}


class A4PaperPrintPageRenderer: UIPrintPageRenderer {
    let A4PaperWidth: CGFloat = 595.2
    let A4PaperHeight: CGFloat = 841.8
    
    override init() {
        super.init()
        
        let paperFrame = CGRect(x: 0.0, y: 0.0, width: A4PaperWidth, height: A4PaperWidth)
        setValue(NSValue(cgRect: paperFrame), forKey: "paperRect")
        setValue(NSValue(cgRect: paperFrame), forKey: "printableRect")
    }
}
