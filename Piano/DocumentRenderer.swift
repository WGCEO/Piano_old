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
    class func render(type: DocumentType, with textView: UITextView, _ handler: ((URL?)->Void)?) {
        DispatchQueue.main.async {
            let renderer = DocumentRenderer()
            
            var fileURL: URL?
            switch type {
            case .pdf:
                 fileURL = renderer.renderPDFDocument(with: textView)
            }
            
            handler?(fileURL)
        }
    }
    
    private func renderPDFDocument(with textView: UITextView) -> URL {
        let printPageRenderer = A4PaperPrintPageRenderer()
        
        printPageRenderer.addPrintFormatter(textView.viewPrintFormatter(), startingAtPageAt: 0)
        
        return drawPDFDocument(using: printPageRenderer)
    }
    
    private func drawPDFDocument(using printPageRenderer: UIPrintPageRenderer) -> URL {
        let path = NSTemporaryDirectory().appending("piano.pdf")
        UIGraphicsBeginPDFContextToFile(path, CGRect.zero, nil)
        
        for page in 0..<printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            printPageRenderer.drawPage(at: page, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        
        return URL(fileURLWithPath: path)
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
