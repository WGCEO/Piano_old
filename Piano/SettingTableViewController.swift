//
//  SettingTableViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 26..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import MessageUI

class SettingTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sender: (UIImage, String)
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            sender = (UIImage(named: "piano")!, "지우개, 피아노 효과, 색/제목/선, 페이지")
        case (2, 0):
            sender = (UIImage(named: "piano")!, "피아노 철학 및 다음 업데이트 정보")
            
        case (2, 1):
            rateApp(appId: "23232", completion: { (_) in
                print("감사염")
            })
            return
        case (2, 2):
            sendEmail()
            return
        case (2, 4):
            sender = (UIImage(named: "piano")!, "오픈소스 라이브러리")
        default:
            return
        }
        
        
        performSegue(withIdentifier: "GoToDetail", sender: sender)
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func sendEmail() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["wepiano@naver.com"])
        mailComposerVC.setSubject("we love piano")
        mailComposerVC.setMessageBody("hi. i like piano app.", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "메일을 보낼 수 없습니다.", message: "디바이스 혹은 인터넷 상태를 확인해주세요", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        sendMailErrorAlert.addAction(cancel)
        present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let des = segue.destination as? SettingDetailViewController,
        let dataSource = sender as? (UIImage, String) else { return }
        
        
        des.dataSource = dataSource
    }
}

extension SettingTableViewController: MFMailComposeViewControllerDelegate {
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
