//
//  ReviewViewController.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 19..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func moveToAppStore(_ sender: Any) {
        
        rateApp(appId: "1200863515", completion: nil)
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func showBasicAlertController(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK".localized(withComment: "확인"), style: .cancel, handler: nil)
        alertViewController.addAction(cancel)
        present(alertViewController, animated: true, completion: nil)
    }
    

    func rateApp(appId: String, completion: ((_ success: Bool)->())?) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/id" + appId) else {
            completion?(false)
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    

}
