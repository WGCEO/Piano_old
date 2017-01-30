//
//  ConfigureFolderViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 29..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import CoreData

protocol ConfigureFolderViewControllerDelegate: class {
    func configureFolderViewController(_ controller: ConfigureFolderViewController, selectFolder: Folder)
    func configureFolderViewController(_ controller: ConfigureFolderViewController, tapCancelButton: Any)
}

class ConfigureFolderViewController: UIViewController {
    
    weak var delegate: ConfigureFolderViewControllerDelegate?
    @IBOutlet weak var tableView: UITableView!
    lazy var folderResultsController: NSFetchedResultsController<Folder> = {
        let context = PianoData.coreDataStack.viewContext
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        let dateSort = NSSortDescriptor(key: #keyPath(Folder.date), ascending: true)
        request.sortDescriptors = [dateSort]
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext:context,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setTableViewCellHeight()
        folderResultsController.delegate = self
        fetchFolderResultsController()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotificationForAjustTextSize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterNotificationForAdjustTextSize()
    }
    
    func registerNotificationForAjustTextSize(){
        NotificationCenter.default.addObserver(self, selector: #selector(ConfigureFolderViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func preferredContentSizeChanged(notification: Notification) {
        tableView.reloadData()
    }
    
    func unregisterNotificationForAdjustTextSize(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func fetchFolderResultsController() {
        //폴더 fetch
        do {
            try folderResultsController.performFetch()
        } catch {
            print("Error performing fetch \(error.localizedDescription)")
        }
    }
    @IBAction func tapCancelButton(_ sender: Any) {
        dismiss(animated: true) { [unowned self] in
            self.delegate?.configureFolderViewController(self, tapCancelButton: sender)
        }
    }

    func setTableViewCellHeight() {
        let str: String = "ForBodySize"
        let bodySize: CGSize = str.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
        let captionSize: CGSize = str.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .caption1)])
        let margin: CGFloat = 12
        
        tableView.rowHeight = bodySize.height + captionSize.height + (margin * 2)
    }
    
    @IBAction func tapAddFolderBarButton(_ sender: Any) {
        showAddGroupAlertViewController()
    }
    
    func textChanged(sender: AnyObject) {
        let tf = sender as! UITextField
        var resp : UIResponder! = tf
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[1].isEnabled = (tf.text != "")
    }
    
    func showAddGroupAlertViewController() {
        let alert = UIAlertController(title: "폴더 만들기", message: "폴더의 이름을 정해주세요.", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "생성", style: .default) { (action) in
            guard let text = alert.textFields?.first?.text else { return }
            let context = PianoData.coreDataStack.viewContext
            do {
                let newFolder = Folder(context: context)
                newFolder.name = text
                newFolder.date = NSDate()
                newFolder.memos = []
                
                try context.save()
                
            } catch {
                print("Error importing folders: \(error.localizedDescription)")
            }
        }
        
        ok.isEnabled = false
        alert.addAction(cancel)
        alert.addAction(ok)
        
        alert.addTextField { (textField) in
            textField.placeholder = "페이지 이름"
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
}

extension ConfigureFolderViewController: NSFetchedResultsControllerDelegate {
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
            if let cell = tableView.cellForRow(at: indexPath) as? MemoCell {
                configure(cell: cell, at: indexPath)
                cell.setNeedsLayout()
            }
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension ConfigureFolderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        let folder = folderResultsController.object(at: indexPath)
        //TODO: Localizing
        cell.textLabel?.text = folder.name
        let count = folder.memos?.count ?? 0
        cell.detailTextLabel?.text = "\(count)" + "개의 메모"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return folderResultsController.sections?.count ?? 0
    }
}

extension ConfigureFolderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let folder = folderResultsController.object(at: indexPath)
        //팝업 뷰 띄워서 영구적으로 지워진다고 말하고 확인 누르면 지우고, 안누르면 지우지 말기
        showAlertViewControllerWhenTryToDelete(with: folder)
    }
    
    //화면 닫음과 동시에 델리게이트에 있는 폴더 세팅하기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let folder = folderResultsController.object(at: indexPath)
        dismiss(animated: true) { [unowned self] in
            self.delegate?.configureFolderViewController(self, selectFolder: folder)
        }
    }
    
    func showAlertViewControllerWhenTryToDelete(with folder: Folder) {
        let alert = UIAlertController(title: "폴더 영구 삭제", message: "삭제하면 다시는 복구할 수 없습니다. 정말로 삭제하시겠습니까?", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "삭제", style: .destructive) { (_) in
            
            guard let memos = folder.memos else { return }
            for memo in memos {
                PianoData.coreDataStack.viewContext.delete(memo as! NSManagedObject)
            }
            
            
            PianoData.coreDataStack.viewContext.delete(folder)
            PianoData.save()
        }
        
        alert.addAction(cancel)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
}


