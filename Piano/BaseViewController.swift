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
    var memoViewController: MemoViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let groupListVC = childViewControllers.first as! GroupListViewController
        
        let context = self.coreDataStack.viewContext
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        let dateSort = NSSortDescriptor(key: #keyPath(Folder.date), ascending: true)
        request.sortDescriptors = [dateSort]
        groupListVC.resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext:context, sectionNameKeyPath: nil, cacheName: nil)
        

    }
    
    @IBAction func tapAddMemoButton(_ sender: Any) {
        
        let memoListViewController = childViewControllers.last as! SheetListViewController
        
        memoListViewController.delegate?.newMemo(with: memoListViewController.folder)
        
        if let memoViewController = memoListViewController.delegate as? MemoViewController {
            splitViewController?.showDetailViewController(memoViewController.navigationController!, sender: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        guard let identifier = segue.identifier else {
            //스토리보드에서 초기화할 때 컨테이너 뷰를 만들기 위해 segue를 거치므로 이 코드가 실행되기 때문에 이때에는 조기 탈출!
            return
        }
        
        switch identifier {
        case "GoToConfigureFolder":
            let des = segue.destination as! ConfigureFolderViewController
//            des.delegate = self
            des.folder = sender as? Folder
        default:
            ()
            
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
                newFolder.date = NSDate()
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
            textField.placeholder = "메모 그룹 이름을 입력하세요"
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
//    func showDenyAlertViewController() {
//        let alert = UIAlertController(title: "추가할 수 없음", message: "폴더의 갯수는 최대 10개입니다.", preferredStyle: .alert)
//        let ok = UIAlertAction(title: "확인", style: .cancel, handler: nil)
//        alert.addAction(ok)
//        present(alert, animated: true, completion: nil)
//    }
}


//extension BaseViewController: ConfigureFolderViewControllerDelegate {
//    func selectLastIndexCell() {
//        let groupListVC = childViewControllers.first as! GroupListViewController
//        guard let indexPath = groupListVC.lastTableViewIndexPath else { return }
//        groupListVC.selectSpecificRow(indexPath: indexPath)
//        
//    }
//    
//    func refreshTableViewWithSelectFolder(folder: Folder) {
//        let groupListVC = childViewControllers.first as! GroupListViewController
//        guard let indexPath = groupListVC.getIndexPath(with: folder) else { return }
//        groupListVC.tableView.reloadData()
//        groupListVC.selectSpecificRow(indexPath: indexPath)
//        
//    }
//    
//    func refreshTableView() {
//        let groupListVC = childViewControllers.first as! GroupListViewController
//        groupListVC.tableView.reloadData()
//    }
//}


