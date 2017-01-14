//
//  BaseViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 12..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import CoreData

class BaseViewController: UIViewController {
    
    let coreDataStack = PianoData.coreDataStack

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let groupListVC = childViewControllers.first as? GroupListViewController else { return }
        
        let context = self.coreDataStack.viewContext
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        let dateSort = NSSortDescriptor(key: #keyPath(Folder.order), ascending: true)
        request.sortDescriptors = [dateSort]
        groupListVC.resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext:context, sectionNameKeyPath: nil, cacheName: nil)
        
    }
    
    @IBAction func tapAddGroupButton(_ sender: Any) {
        
        guard let groupListVC = childViewControllers.first as? GroupListViewController,
            let section = groupListVC.resultsController?.sections, section.count > 0 else { return }
        
        //TODO: 폴더 갯수가 10개보다 작아야 추가 가능!
        if section[0].numberOfObjects < 10 {
            showAddGroupAlertViewController(order: section[0].numberOfObjects)
        } else {
            showDenyAlertViewController()
        }
    }

    
    @IBAction func tapAddMemoButton(_ sender: Any) {
        
        performSegue(withIdentifier: "GoToMemo", sender: nil)
        
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let groupListVC = childViewControllers.first as? GroupListViewController,
            let selectedRow = groupListVC.tableView.indexPathForSelectedRow,
            let folder = groupListVC.resultsController?.object(at: selectedRow),
            let identifier = segue.identifier else { return }
        
        
        if identifier == "GoToMemo" {
            
            let des = segue.destination as! MemoViewController
            des.folder = folder
            guard let memo = sender as? Memo else { return }
            des.memo = memo
            
        }
    }
    
    func textChanged(sender: AnyObject) {
        let tf = sender as! UITextField
        var resp : UIResponder! = tf
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[1].isEnabled = (tf.text != "")
    }
    
    func showAddGroupAlertViewController(order: Int) {
        let alert = UIAlertController(title: "새로운 폴더", message: "이 폴더의 이름을 입력하십시오.", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "저장", style: .default) { [unowned self](action) in
            guard let text = alert.textFields?.first?.text else { return }
            let context = self.coreDataStack.viewContext
            do {
                let newFolder = Folder(context: context)
                newFolder.name = text
                newFolder.order = Int16(order)
                newFolder.memos = []
                
                try context.save()
                
                guard let groupListVC = self.childViewControllers.first as? GroupListViewController else { return }
                groupListVC.selectSpecificRow(indexPath: IndexPath(row: order, section: 0))
            } catch {
                print("Error importing folders: \(error.localizedDescription)")
            }
        }
        
        ok.isEnabled = false
        alert.addAction(cancel)
        alert.addAction(ok)
        
        alert.addTextField { (textField) in
            textField.placeholder = "이름"
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func showDenyAlertViewController() {
        let alert = UIAlertController(title: "추가할 수 없음", message: "폴더의 갯수는 최대 10개입니다.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
