//
//  DeletedMemoListViewController.swift
//  Piano
//
//  Created by kevin on 2016. 12. 22..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit
import CoreData

class DeletedMemoListViewController: UIViewController {

    let coreDataStack = PianoData.coreDataStack
    @IBOutlet weak var tableView: UITableView!
    
    var indicatingCell: () -> Void = {}
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    lazy var resultsController: NSFetchedResultsController<Memo> = {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        request.predicate = NSPredicate(format: "isInTrash == true")
        let context = self.coreDataStack.viewContext
        let dateSort = NSSortDescriptor(key: #keyPath(Memo.date), ascending: false)
        request.sortDescriptors = [dateSort]
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext:context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTableViewCellHeight()
        //TODO: 이거 비동기로 처리하지 않아도 되는 것인가?
        deleteMemosIfPassOneMonth()
        
        do {
            try resultsController.performFetch()
        } catch {
            print("Error performing fetch \(error.localizedDescription)")
        }
    }
    
    func deleteMemosIfPassOneMonth() {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        request.predicate = NSPredicate(format: "isInTrash == true AND date < %@", NSDate())
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
        batchDelete.affectedStores = coreDataStack.viewContext.persistentStoreCoordinator?.persistentStores
        batchDelete.resultType = .resultTypeCount
        do {
            let batchResult = try coreDataStack.viewContext.execute(batchDelete) as! NSBatchDeleteResult
            print("record deleted \(batchResult.result)")
        } catch {
            print("could not delete \(error.localizedDescription)")
        }
    }
    
    func setTableViewCellHeight() {
        let originalString: String = "ForBodySize"
        let myString = originalString
        let bodySize: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
        let callOutSize: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .callout)])
        let margin: CGFloat = 10
        
        tableView.rowHeight = bodySize.height + callOutSize.height + (margin * 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DeletedMemoListViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        indicatingCell()
    }
    
    func preferredContentSizeChanged(notification: Notification) {
        tableView.reloadData()
    }

    @IBAction func tapCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "DeletedMemo":
            let des = segue.destination as! DeletedMemoViewController
            des.coreDataStack = coreDataStack
            guard let memo = sender as? Memo else { return }
            des.memo = memo
            des.folder = memo.folder

        default:
            ()
        }
    }
}

extension DeletedMemoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "DeletedMemoCell")
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        let memo = resultsController.object(at: indexPath)
        cell.textLabel?.text = memo.firstLine
        cell.detailTextLabel?.text = formatter.string(from: memo.date)
        //TODO: 
        cell.imageView?.image = UIImage(named: memo.folder.imageName)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultsController.sections?.count ?? 0
    }
}

extension DeletedMemoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let memo = resultsController.object(at: indexPath)
        performSegue(withIdentifier: "DeletedMemo", sender: memo)
        
        indicatingCell = { [unowned self] in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension DeletedMemoListViewController: NSFetchedResultsControllerDelegate {
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
