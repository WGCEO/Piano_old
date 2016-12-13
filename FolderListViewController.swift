//
//  FolderListViewController.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class FolderListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var indicatingCell: () -> Void = {}
//    var memoViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        indicatingCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FolderListViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func preferredContentSizeChanged(notification: Notification) {
        tableView.reloadData()
    }

}

extension FolderListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "FolderCell")
        //TODO: localization
        
        switch indexPath.section {
        case 0 where indexPath.row == 0:
            cell?.textLabel?.text = "모든 메모"
            cell?.detailTextLabel?.text = "40"
            cell.textLabel?.textColor = #colorLiteral(red: 0.2558659911, green: 0.2558728456, blue: 0.2558691502, alpha: 1)
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0.2901960784, green: 0.7843137255, blue: 0.6666666667, alpha: 1)
        case 0 where indexPath.row == 1:
            cell?.textLabel?.text = "최근 삭제된 메모"
            cell?.detailTextLabel?.text = "12"
            cell.textLabel?.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0.9725490196, green: 0.3215686275, blue: 0.4039215686, alpha: 1)
        case 1 where indexPath.row != 3:
            cell?.textLabel?.text = "흠\(indexPath.row)"
            cell?.detailTextLabel?.text = "10"
            cell.textLabel?.textColor = #colorLiteral(red: 0.2558659911, green: 0.2558728456, blue: 0.2558691502, alpha: 1)
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0.2901960784, green: 0.7843137255, blue: 0.6666666667, alpha: 1)
        default:
            cell.textLabel?.text = "폴더 추가하기"
            cell.textLabel?.textColor = #colorLiteral(red: 0.2558659911, green: 0.2558728456, blue: 0.2558691502, alpha: 1)
            cell.accessoryType = .none
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 4
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //TODO: Localization
        switch section {
        case 0:
            return "ALL"
        case 1:
            return "GROUP"
        default:
            return nil
        }
    }
}


extension FolderListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 43
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indicatingCell = { [unowned self] in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
