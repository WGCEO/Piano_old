//
//  SettingViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 28..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

class SettingViewController: UIViewController {
    
    let dataSourse: [String] = ["삭제된 메모함", "팁", "피아노 전시회", "I Love Piano", "아이디어/버그 제보", "기타 정보"]
    

    @IBAction func tapCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapDeletedMemo(_ sender: Any) {
        performSegue(withIdentifier: "GoToDeleteMemo", sender: nil)
    }
    
    @IBAction func tapTip(_ sender: Any) {
        //TODO: 여기서 팁 동영상이 있는 링크를 사파리뷰 컨트롤러로 실행시키기 데이터 소스로 넘겨주기
        showSafariViewController(with: "https://m.facebook.com/OurLovePiano")
    }
    
    
    @IBAction func tapPianoExhibition(_ sender: Any) {
        showSafariViewController(with: "https://m.facebook.com/OurLovePiano")
    }
    
    @IBAction func tapILovePiano(_ sender: Any) {
        //TODO: 앱 아이디
        rateApp(appId: "TODO: 앱 아이디 적어야함", completion: { [weak self](bool) in
            if bool {
                self?.showBasicAlertController(title: "감사합니다", message: "아름다운 리뷰가 저희들의 열정이 됩니다.")
            }
        })
    }
    
    @IBAction func tapReportIdeaAndBug(_ sender: Any) {
        sendEmail(withTitle: "i love piano")
    }
    
    @IBAction func tapExtraInfo(_ sender: Any) {
        performSegue(withIdentifier: "GoToOpenSource", sender: nil)
    }
    
    
    func sendEmail(withTitle: String) {
        let mailComposeViewController = configuredMailComposeViewController(withTitle: withTitle)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showBasicAlertController(title: "메일을 보낼 수 없습니다.", message: "디바이스 혹은 인터넷 상태를 확인해주세요")
        }
    }
    
    func configuredMailComposeViewController(withTitle: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["OurLovePiano@gmail.com"])
        mailComposerVC.setSubject(withTitle)
        mailComposerVC.setMessageBody("hi. i like piano app.", isHTML: false)
        
        return mailComposerVC
    }
    
    func showBasicAlertController(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alertViewController.addAction(cancel)
        present(alertViewController, animated: true, completion: nil)
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    func showSafariViewController(with urlString: String) {
        if let url = URL(string: urlString) {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            present(vc, animated: true)
        } else {
            showBasicAlertController(title: "네트워크 에러", message: "디바이스 혹은 인터넷 상태를 확인해주세요")
        }
    }

}


extension SettingViewController: MFMailComposeViewControllerDelegate {
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
