//
//  MailSender.swift
//  Piano
//
//  Created by dalong on 2017. 6. 2..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import MessageUI

class MailSender: NSObject, MFMailComposeViewControllerDelegate {
    private static var sharedInstance = {
        return MailSender()
    }()
    
    public class func sendMail(with attributedString: NSAttributedString, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            let mailViewController: MFMailComposeViewController = MFMailComposeViewController()
            mailViewController.mailComposeDelegate = sharedInstance

            let preprocessedAttrString = attachResource(to: mailViewController, from: attributedString)
            if let messageBody = preprocessedAttrString.parseToHTMLString() {
                mailViewController.setMessageBody(messageBody, isHTML:true)
            }
            
            if MFMailComposeViewController.canSendMail() {
                AppNavigator.present(mailViewController, animated: true, completion: completion)
            } else {
                showSendMailErrorAlert()
            }
        }
    }
    
    public class func attachResource(to mail: MFMailComposeViewController, from attributedString: NSAttributedString) -> NSAttributedString {
        let mutableAttrbutedString = NSMutableAttributedString(attributedString: attributedString)
        
        //images
        attributedString.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, attributedString.length), options: []) { (value, range, stop) in
            guard let attachment = value as? NSTextAttachment,
                let image = attachment.image,
                let data = UIImagePNGRepresentation(image) else { return }
            
            mail.addAttachmentData(data, mimeType: "image/png", fileName: "piano\(range.location).png")
            mutableAttrbutedString.replaceCharacters(in: range, with: NSAttributedString(string: "\n"))
        }
        
        //font
        attributedString.enumerateAttribute(NSFontAttributeName, in: NSMakeRange(0, attributedString.length), options: []) { (value, range, stop) in
            guard let font = value as? UIFont else { return }
            
            let newFont = font.withSize(font.pointSize - 4)
            mutableAttrbutedString.addAttributes([NSFontAttributeName : newFont], range: range)
        }
        
        return mutableAttrbutedString
    }
    
    private class func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "EmailErrorTitle".localized(withComment: "메일을 보낼 수 없습니다."), message: "CheckDeviceOrInternet".localized(withComment: "디바이스 혹은 인터넷 상태를 확인해주세요"), preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK".localized(withComment: "확인"), style: .cancel, handler: nil)
        sendMailErrorAlert.addAction(cancel)
        AppNavigator.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

fileprivate extension NSAttributedString {
    func parseToHTMLString() -> String? {
        let attributes = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
        do {
            let range = NSMakeRange(0, length)
            let data = try self.data(from: range, documentAttributes: attributes)
            
            return String(data: data, encoding: String.Encoding.utf8)
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}
