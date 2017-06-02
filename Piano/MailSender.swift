//
//  MailSender.swift
//  Piano
//
//  Created by dalong on 2017. 6. 2..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation

class MailSender: MFMailComposeViewController {
    func sendMail() {
        guard canDoAnotherTask() else { return }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        /*
         DispatchQueue.main.async { [unowned self] in
         guard let attrText = self.textView.attributedText else { return }
         let mail:MFMailComposeViewController = MFMailComposeViewController()
         mail.mailComposeDelegate = self
         
         let mutableAttrText = NSMutableAttributedString(attributedString: attrText)
         
         attrText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, attrText.length), options: []) { (value, range, stop) in
         
         guard let attachment = value as? NSTextAttachment,
         let image = attachment.image,
         let data = UIImagePNGRepresentation(image) else { return }
         
         mail.addAttachmentData(data, mimeType: "image/png", fileName: "piano\(range.location).png")
         mutableAttrText.replaceCharacters(in: range, with: NSAttributedString(string: "\n"))
         }
         
         attrText.enumerateAttribute(NSFontAttributeName, in: NSMakeRange(0, attrText.length), options: []) { (value, range, stop) in
         guard let font = value as? UIFont else { return }
         
         let newFont = font.withSize(font.pointSize - 4)
         mutableAttrText.addAttributes([NSFontAttributeName : newFont], range: range)
         }
         
         mail.setMessageBody(self.parseToHTMLString(from: mutableAttrText), isHTML:true)
         
         if MFMailComposeViewController.canSendMail() {
         self.present(mail, animated: true, completion:nil)
         } else {
         self.showSendMailErrorAlert()
         }
         
         self.activityIndicator.stopAnimating()
         self.textView.makeTappable()
         }
         */
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "EmailErrorTitle".localized(withComment: "메일을 보낼 수 없습니다."), message: "CheckDeviceOrInternet".localized(withComment: "디바이스 혹은 인터넷 상태를 확인해주세요"), preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK".localized(withComment: "확인"), style: .cancel, handler: nil)
        sendMailErrorAlert.addAction(cancel)
        present(sendMailErrorAlert, animated: true, completion: nil)
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
