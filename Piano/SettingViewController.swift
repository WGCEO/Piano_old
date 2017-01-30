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
    
    @IBOutlet weak var portraitStackView: UIStackView!
    @IBOutlet weak var landscapeStackView: UIStackView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let size = UIScreen.main.bounds.size
        setStackViewByViewMode(size: size)
    }
    
    func setStackViewByViewMode(size: CGSize){
        landscapeStackView.isHidden = size.width < size.height
        portraitStackView.isHidden = size.width > size.height
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setStackViewByViewMode(size: size)
        
    }

    @IBAction func tapCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapDeletedMemo(_ sender: Any) {
        performSegue(withIdentifier: "GoToDeleteMemo", sender: nil)
    }
    
    @IBAction func tapDeletedMemoL(_ sender: Any) {
        performSegue(withIdentifier: "GoToDeleteMemo", sender: nil)
    }
    
    
    func tip(){
        //TODO: 여기서 팁 동영상이 있는 링크를 사파리뷰 컨트롤러로 실행시키기 데이터 소스로 넘겨주기
        showSafariViewController(with: "https://m.facebook.com/OurLovePiano")
    }
    
    func exhibition(){
        showSafariViewController(with: "https://m.facebook.com/OurLovePiano")
    }
    
    func iLovePiano(){
        //TODO: 앱 아이디
        rateApp(appId: "TODO: 앱 아이디 적어야함", completion: { [weak self](bool) in
            if bool {
                self?.showBasicAlertController(title: "감사합니다", message: "아름다운 리뷰가 저희들의 열정이 됩니다.")
            }
        })
    }
    
    func reportIdeaAndBug(){
        sendEmail(withTitle: "i love piano")
    }
    
    func extraInfo(){
        performSegue(withIdentifier: "GoToOpenSource", sender: nil)
    }
    
    @IBAction func tapTip(_ sender: Any) {
        tip()
    }
    
    @IBAction func tapTipL(_ sender: Any) {
        tip()
    }
    
    @IBAction func tapPianoExhibition(_ sender: Any) {
        exhibition()
    }
    @IBAction func tapPianoExhibitionL(_ sender: Any) {
        exhibition()
    }
    
    @IBAction func tapILovePiano(_ sender: Any) {
        iLovePiano()
    }
    @IBAction func tapILovePianoL(_ sender: Any) {
        iLovePiano()
    }
    
    @IBAction func tapReportIdeaAndBug(_ sender: Any) {
        reportIdeaAndBug()
    }
    
    @IBAction func tapReportIdeaAndBugL(_ sender: Any) {
        reportIdeaAndBug()
    }
    @IBAction func tapExtraInfo(_ sender: Any) {
        extraInfo()
    }
    
    @IBAction func tapExtraInfoL(_ sender: Any) {
        extraInfo()
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
