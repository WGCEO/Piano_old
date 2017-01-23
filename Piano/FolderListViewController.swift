//
//  FolderListViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 20..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import CoreData

class FolderListViewController: UIViewController {
    
    let topInset: CGFloat = 28
    
    
    @IBOutlet weak var tableView: UITableView!
    lazy var resultsController: NSFetchedResultsController<Folder> = {
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
        
        tableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0)
        registerNotificationForAjustTextSize()
        resultsController.delegate = self
        
        do {
            try resultsController.performFetch()
        } catch {
            print("Error performing fetch \(error.localizedDescription)")
        }
        setTableViewCellHeight()
    }
    
    func setTableViewCellHeight() {
        let originalString: String = "ForBodySize"
        let myString = originalString
        let bodySize: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
        let subHeadSize: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .subheadline)])
        let margin: CGFloat = 10
        
        tableView.rowHeight = bodySize.height + subHeadSize.height + (margin * 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectTableViewCell(with: IndexPath(row: 0, section: 0))
    }
    
    func registerNotificationForAjustTextSize(){
        NotificationCenter.default.addObserver(self, selector: #selector(FolderListViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func preferredContentSizeChanged(notification: Notification) {
        tableView.reloadData()
    }
    
    func selectTableViewCell(with indexPath: IndexPath){
        guard let objects = resultsController.fetchedObjects else { return }
        
        if objects.count != 0 {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            tableView(tableView, didSelectRowAt: indexPath)
        } else {
            sendFolderToMemoListViewController(folder: nil)
        }
    }
    
    func sendFolderToMemoListViewController(folder: Folder?) {
        guard let masterViewController = parent as? MasterViewController,
            let memoListViewController = masterViewController.childViewControllers.last as? MemoListViewController else { return }
        
        //같은 폴더면 넘기지 마삼.
        guard memoListViewController.folder != folder else { return }
        memoListViewController.folder = folder
    }
    

    @IBAction func tapLongPressGesture(_ sender: Any) {
        let longPressGesture = sender as! UIGestureRecognizer
        
        if longPressGesture.state == .began {
            var touchPoint = longPressGesture.location(in: self.view)
            touchPoint.y -= topInset
            
            if let indexPath = tableView.indexPathForRow(at: touchPoint){
                selectTableViewCell(with: indexPath)
                
                let folder = resultsController.object(at: indexPath)
                let masterViewController = parent as! MasterViewController
                masterViewController.performSegue(withIdentifier: "GoToConfigureFolder", sender: folder)
            }
        }
    }

}

extension FolderListViewController: NSFetchedResultsControllerDelegate {
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
            if let cell = tableView.cellForRow(at: indexPath) as? FolderCell {
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


extension FolderListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FolderCell.reuseIdentifier) as! FolderCell
        //TODO: localization
        
        configure(cell: cell, at: indexPath)
        return cell
    }
    
    func configure(cell: FolderCell, at indexPath: IndexPath) {
        let folder = resultsController.object(at: indexPath)
        cell.ibImageView.image = UIImage(named: folder.imageName)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }
}

extension FolderListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let folder = resultsController.object(at: indexPath)
        sendFolderToMemoListViewController(folder: folder)
    }
    
    func getIndexPath(with: Folder) -> IndexPath? {
        guard let folders = resultsController.fetchedObjects else { return nil }
        
        for (index, folder) in folders.enumerated() {
            if with == folder {
                return IndexPath(row: index, section: 0)
            }
        }
        return nil
    }
    
    
}

