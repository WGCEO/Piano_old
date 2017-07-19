//
//  SettingTableViewController.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 19..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import MessageUI

class SettingTableViewController: UITableViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    //Storyboard에서 세팅해도 제대로 적용안돼 이 코드 삽입
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = PianoGlobal.backgroundColor
        return view
    }
    
    
    //MARK: 아래부터 이메일 관련 로직
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == IndexPath(row: 1, section: 3) {
            sendEmail(withTitle: "Piano Note Idea")
        }
    }
    
    func sendEmail(withTitle: String) {
        let mailComposeViewController = configuredMailComposeViewController(withTitle: withTitle)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showBasicAlertController(title: "EmailErrorTitle".localized(withComment: "메일을 보낼 수 없습니다."), message: "CheckDeviceOrInternet".localized(withComment: "디바이스 혹은 인터넷 상태를 확인해주세요"))
        }
    }
    
    func configuredMailComposeViewController(withTitle: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["OurLovePiano@gmail.com"])
        mailComposerVC.setSubject(withTitle)
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    func showBasicAlertController(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK".localized(withComment: "확인"), style: .cancel, handler: nil)
        alertViewController.addAction(cancel)
        present(alertViewController, animated: true, completion: nil)
    }
    
}

extension SettingTableViewController: MFMailComposeViewControllerDelegate {
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
