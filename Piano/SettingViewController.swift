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
    
    let dataSourse: [String] = ["삭제된 메모함", "팁", "피아노 철학", "다음 업데이트 정보", "I Love Piano", "아이디어 제안", "버그 문의", "피아노 세상", "오픈소스"]
    
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func sendEmail(withTitle: String) {
        let mailComposeViewController = configuredMailComposeViewController(withTitle: withTitle)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController(withTitle: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["wepiano@naver.com"])
        mailComposerVC.setSubject(withTitle)
        mailComposerVC.setMessageBody("hi. i like piano app.", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "메일을 보낼 수 없습니다.", message: "디바이스 혹은 인터넷 상태를 확인해주세요", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        sendMailErrorAlert.addAction(cancel)
        present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func showInternetErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "네트워크 에러.", message: "디바이스 혹은 인터넷 상태를 확인해주세요", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        sendMailErrorAlert.addAction(cancel)
        present(sendMailErrorAlert, animated: true, completion: nil)
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
            showInternetErrorAlert()
        }
    }

}


extension SettingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.reuseIdentifier, for: indexPath) as! SettingCell
        configure(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    func configure(cell: SettingCell, indexPath: IndexPath) {
        cell.ibLabel.text = dataSourse[indexPath.item]
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourse.count
    }
}


extension SettingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            performSegue(withIdentifier: "GoToDeleteMemo", sender: nil)
        case 1:
            //TODO: 여기서 팁 동영상이 있는 링크를 사파리뷰 컨트롤러로 실행시키기 데이터 소스로 넘겨주기
            showSafariViewController(with: "https://m.facebook.com/OurLovePiano")
            
        case 2:
            //TODO: 여기서 피아노 철학 정보 만들어서 데이터 소스로 넘겨주기
            showSafariViewController(with: "https://m.facebook.com/OurLovePiano")
            
        case 3:
            //TODO: 여기서 다음 업데이트 정보 만들어서 데이터 소스로 넘겨주기
            showSafariViewController(with: "https://m.facebook.com/OurLovePiano")
            
        case 4:
            rateApp(appId: "TODO: 앱 아이디 적어야함", completion: { (bool) in
                if bool {
                    //TODO: 알럿 뷰 컨트롤러 띄워줘서 리뷰를 안 쓴 사람도 뜨끔해서 쓸 수 있도록 하게 하기
                }
            })
            
        case 5:
            guard let url = URL(string: "https://www.messenger.com/t/OurLovePiano/"),
                UIApplication.shared.canOpenURL(url) else {
                showInternetErrorAlert()
                return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        case 6:
            sendEmail(withTitle: "i found a bug in Piano!")
            
        case 7:
            showSafariViewController(with: "https://m.facebook.com/OurLovePiano")
        case 8:
            performSegue(withIdentifier: "GoToOpenSource", sender: nil)
        default:
            ()
        }
    }
}

extension SettingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let length = width < height ? width / 2 : width / 3
        let between: CGFloat = width < height ? 12 : 10
        return CGSize(width: length - between, height: length - between)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
