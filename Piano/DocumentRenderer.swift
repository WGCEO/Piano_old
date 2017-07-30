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
    func render(type: DocumentType, with textView: UITextView) -> Data {
        switch type {
        case .pdf:
            return renderPDFDocument(with: textView)
        }
    }
    
    private func renderPDFDocument(with textView: UITextView) -> Data {
        let printPageRenderer = A4PaperPrintPageRenderer()
        
        printPageRenderer.addPrintFormatter(textView.viewPrintFormatter(), startingAtPageAt: 0)
        
        return drawPDFDocument(using: printPageRenderer)
    }
    
    private func drawPDFDocument(using printPageRenderer: UIPrintPageRenderer) -> Data {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        for page in 0..<printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            printPageRenderer.drawPage(at: page, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        
        return data as Data
    }
}


class A4PaperPrintPageRenderer: UIPrintPageRenderer {
    let A4PaperWidth: CGFloat = 595.2
    let A4PaperHeight: CGFloat = 841.8
    
    let margin: CGFloat = 0 // 30.0
    
    override init() {
        super.init()
        
        let paperFrame = CGRect(x: 0.0, y: 0.0, width: A4PaperWidth, height: A4PaperWidth)
        setValue(NSValue(cgRect: paperFrame), forKey: "paperRect")
        
        let printableRect = CGRect(x: margin, y: margin, width: (A4PaperWidth-(margin*2)), height: (A4PaperWidth-(margin*2)))
        setValue(NSValue(cgRect: printableRect), forKey: "printableRect")
    }
}
