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
    public static let sharedInstance = MailSender()
    
    public class func sendMail(with attributedString: NSAttributedString?, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            //mail
            let mailViewController: MFMailComposeViewController = MFMailComposeViewController()
            mailViewController.mailComposeDelegate = sharedInstance

            /*
            //text
            let mutableAttrText = NSMutableAttributedString(attributedString: attributedString)

            //images
            attributedString.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, attributedString.length), options: []) { (value, range, stop) in
                guard let attachment = value as? NSTextAttachment,
                let image = attachment.image,
                let data = UIImagePNGRepresentation(image) else { return }

                mail.addAttachmentData(data, mimeType: "image/png", fileName: "piano\(range.location).png")
                mutableAttrText.replaceCharacters(in: range, with: NSAttributedString(string: "\n"))
            }

            //font
            attributedString.enumerateAttribute(NSFontAttributeName, in: NSMakeRange(0, attributedString.length), options: []) { (value, range, stop) in
                guard let font = value as? UIFont else { return }

                let newFont = font.withSize(font.pointSize - 4)
                mutableAttrText.addAttributes([NSFontAttributeName : newFont], range: range)
            }
            */
            
            if let messageBody = parseToHTMLString(from: attributedString) {
                mailViewController.setMessageBody(messageBody, isHTML:true)
            }
            
            if MFMailComposeViewController.canSendMail() {
                AppNavigator.present(mailViewController, animated: true, completion: completion)
            } else {
                showSendMailErrorAlert()
            }
        }
    }
    
    private class func parseToHTMLString(from: NSAttributedString?) -> String? {
        /*
         let attr = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
         do {
         let data = try from.data(from: NSMakeRange(0, from.length), documentAttributes: attr)
         guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else { return ""}
         return htmlString
         } catch {
         print(error.localizedDescription)
         }
         */
        
        return ""
    }

    
    private class func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "EmailErrorTitle".localized(withComment: "메일을 보낼 수 없습니다."), message: "CheckDeviceOrInternet".localized(withComment: "디바이스 혹은 인터넷 상태를 확인해주세요"), preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK".localized(withComment: "확인"), style: .cancel, handler: nil)
        sendMailErrorAlert.addAction(cancel)
        AppNavigator.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func returnEmailStringBase64EncodedImage(image:UIImage) -> String {
        let imgData = UIImagePNGRepresentation(image)!
        let dataString = imgData.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
        return dataString
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
