//
//  MoreViewController.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func tapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension MoreViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "MoreCell")
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "피아노에 대하여"
        case 1:
            cell.textLabel?.text = "TIP!"
        case 2:
            cell.textLabel?.text = "아이디어 제안"
        case 3:
            cell.textLabel?.text = "장애문의"
        case 4:
            cell.textLabel?.text = "라이센스"
        case 5:
            cell.textLabel?.text = "클라우드 사용하기"
        default:
            ()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
}

extension MoreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
