//
//  SheetListViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 12..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import CoreData

class SheetListViewController: UIViewController {
    
    let coreDataStack = PianoData.coreDataStack
    var resultsController: NSFetchedResultsController<Memo>? {
        didSet {
            resultsController?.delegate = self
            
            do {
                try resultsController?.performFetch()
                tableView.reloadData()
            } catch {
                print("Error performing fetch \(error.localizedDescription)")
            }
        }
    }
    @IBOutlet weak var tableView: UITableView!
    var folder: Folder? {
        didSet {
            guard let folder = folder else { return }
            self.setTableViewCellHeight()
            let request: NSFetchRequest<Memo> = Memo.fetchRequest()
            request.predicate = NSPredicate(format: "isInTrash == false AND folder = %@", folder)
            let context = self.coreDataStack.viewContext
            let dateSort = NSSortDescriptor(key: #keyPath(Memo.date), ascending: false)
            request.sortDescriptors = [dateSort]
            resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext:context, sectionNameKeyPath: nil, cacheName: nil)
            
            
        }
    }
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SheetListViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func preferredContentSizeChanged(notification: Notification) {
        tableView.reloadData()
    }

}

extension SheetListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        guard let controller = resultsController else { return }
        let memo = controller.object(at: indexPath)
        cell.textLabel?.text = memo.firstLine
        cell.detailTextLabel?.text = formatter.string(from: memo.date)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let controller = resultsController else { return 0 }
        return controller.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let controller = resultsController else { return 0 }
        return controller.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return folder?.name
    }
    


}

extension SheetListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = resultsController,
            let baseVC = parent as? BaseViewController else { return }
        let memo = controller.object(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        baseVC.performSegue(withIdentifier: "GoToMemo", sender: memo)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let controller = resultsController else { return }
        let memo = controller.object(at: indexPath)
        memo.isInTrash = true
    }

    
    func setTableViewCellHeight() {
        let originalString: String = "ForBodySize"
        let myString = originalString
        let bodySize: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
        let callOutSize: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .callout)])
        let margin: CGFloat = 10
        
        tableView.rowHeight = bodySize.height + callOutSize.height + (margin * 2)
    }
}

extension SheetListViewController: NSFetchedResultsControllerDelegate {
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
            if let cell = tableView.cellForRow(at: indexPath) {
                configure(cell: cell, at: indexPath)
                cell.setNeedsLayout()
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
