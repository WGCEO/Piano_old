//
//  SettingTableViewController.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 19..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

import UIKit

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
    
    
    
}
