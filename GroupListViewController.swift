//
//  GroupListViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 12..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import CoreData

class GroupListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var lastTableViewIndexPath: IndexPath? {
        guard let objects = self.resultsController?.fetchedObjects, objects.count > 0 else { return nil }
        
        return IndexPath(row: objects.count - 1, section: 0)
    }
    let coreDataStack = PianoData.coreDataStack
    var resultsController: NSFetchedResultsController<Folder>? {
        didSet {
            guard let resultsController = resultsController else { return }
            resultsController.delegate = self
            do {
                try resultsController.performFetch()
            } catch {
                print("Error performing fetch \(error.localizedDescription)")
            }
            
            if !self.isResultsControllerEmpty() {
                self.selectSpecificRow(indexPath: IndexPath(row: 0, section: 0))
            }
        }
    }
    
    func isResultsControllerEmpty() -> Bool {
        guard let objects = resultsController?.fetchedObjects else { return true }
        return objects.count > 0 ? false : true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.setEditing(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GroupListViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func preferredContentSizeChanged(notification: Notification) {
        tableView.reloadData()
    }
    
    @IBAction func tapLongGesture(_ sender: Any) {
        let longGesture = sender as! UIGestureRecognizer
        
        if longGesture.state == .began {
            //ConfigureFolderViewController를 열고 거기다가 현재 눌러진 셀의 폴더 객체를 전달해야함
            //ConfigureFolderViewController에서 폴더가 있다면 수정모드로 가고, 없다면 생성하는 컨셉으로 가기
            
            let touchPoint = longGesture.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                selectSpecificRow(indexPath: indexPath)
                
                //제일 첫 번째 폴더는 지우지 말기
                if indexPath.row != 0 {
                    guard let folder = resultsController?.object(at: indexPath),
                        let baseVC = parent as? BaseViewController  else { return }
                    
                    baseVC.performSegue(withIdentifier: "GoToConfigureFolder", sender: folder)
                }
            }
        }
    }
    
}

extension GroupListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            if let cell = tableView.cellForRow(at: indexPath) as? GroupCell {
                configure(cell: cell, at: indexPath)
            }
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension GroupListViewController {
    override func applicationFinishedRestoringState() {
        
        do {
            try resultsController?.performFetch()
        } catch {
            print("Error performing fetch \(error.localizedDescription)")
        }
    }
}


extension GroupListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell") as! GroupCell
        //TODO: localization
        
        configure(cell: cell, at: indexPath)
        return cell
    }
    
    func configure(cell: GroupCell, at indexPath: IndexPath) {
        guard let folder = resultsController?.object(at: indexPath) else { return }
        cell.ibImageView.image = UIImage(named: folder.imageName)
//        cell.showsReorderControl = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController?.sections?[section].numberOfObjects ?? 0
    }
}

extension GroupListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let folder = resultsController?.object(at: indexPath) else { return }
        
        
        guard let parentVC = parent as? BaseViewController,
            let sheetListVC = parentVC.childViewControllers.last as? SheetListViewController else { return }
        
        sheetListVC.folder = folder
        
        //TODO2: SheetListViewController에 데이터 소스를 넣고 갱신시켜야함
    
    }
    
    //SheetList에 folder: Folder? 프로퍼티가 있고, 거기에 전달하기 -> 전달하면 거기서 didSet프로퍼티에 따라 NSFetchedResultsController를 업데이트하여 fetch를 진행하도록 세팅해놓기
    
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        
//        //폴더를 지우면 영원히 복구할 수 없다는 경고 메시지를 띄워주기
//        let alert = UIAlertController(title: "폴더를 삭제하겠습니까?", message: "폴더를 삭제하면 그 안에 있던 메모들을 복구할 방법이 없습니다.", preferredStyle: .alert)
//        
//        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in }
//        let delete = UIAlertAction(title: "삭제", style: .destructive) { [unowned self](action) in
//            guard let folder = self.resultsController?.object(at: indexPath) else { return }
//            
//            for item in folder.memos {
//                let memo = item as! Memo
//                self.coreDataStack.viewContext.delete(memo)
//            }
//            self.coreDataStack.viewContext.delete(folder)
//            
//            
//            //만약 선택되어 있는 셀이었다면 처음 셀을 선택하도록 하게 하기
//            self.selectSpecificRow(indexPath: IndexPath(row: 0, section: 0))
//        }
//        alert.addAction(cancel)
//        alert.addAction(delete)
//        
//        
//        present(alert, animated: true, completion: nil)
//    }
    
    func selectSpecificRow(indexPath: IndexPath){
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        self.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    func getIndexPath(with: Folder) -> IndexPath? {
        guard let folders = resultsController?.fetchedObjects else { return nil }
        
        for (index, folder) in folders.enumerated() {
            if with == folder {
                return IndexPath(row: index, section: 0)
            }
        }
        return nil
    }
    
    
}



