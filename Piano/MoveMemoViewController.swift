//
//  MoveMemoViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 30..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import CoreData

class MoveMemoViewController: UIViewController {
    
    var memo: Memo!
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(MoveMemoViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
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
        dismiss(animated: true, completion: nil)
    }
    
    func setTableViewCellHeight() {
        let str: String = "ForBodySize"
        let bodySize: CGSize = str.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
        let captionSize: CGSize = str.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .caption1)])
        let margin: CGFloat = 12
        
        tableView.rowHeight = bodySize.height + captionSize.height + (margin * 2)
    }

}

extension MoveMemoViewController: NSFetchedResultsControllerDelegate {
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

extension MoveMemoViewController: UITableViewDataSource {
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

extension MoveMemoViewController: UITableViewDelegate {
    
    //화면 닫음과 동시에 델리게이트에 있는 폴더 세팅하기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let folder = folderResultsController.object(at: indexPath)
        memo.folder = folder
        dismiss(animated: true, completion: nil)
    }
    
}
