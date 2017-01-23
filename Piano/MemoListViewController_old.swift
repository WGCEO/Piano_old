////
////  MemoListViewController.swift
////  Piano
////
////  Created by 김찬기 on 2016. 11. 20..
////  Copyright © 2016년 Piano. All rights reserved.
////
//
//import CoreData
//import UIKit
//
//class MemoListViewController: UIViewController {
//    
//    @IBOutlet weak var tableView: UITableView!
//    let coreDataStack = PianoData.coreDataStack
//    var folder: Folder?
//    
//    var indicatingCell: () -> Void = {}
//    
//    lazy var formatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .short
//        formatter.doesRelativeDateFormatting = true
//        return formatter
//    }()
//    
//    var resultsController: NSFetchedResultsController<Memo>?
//    
//    func setAndPerformResultsController() {
//        guard let folder = self.folder else { return }
//        
//        setTableViewCellHeight()
//        
//        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
//        request.predicate = NSPredicate(format: "isInTrash == false AND folder = %@", folder)
//        let context = self.coreDataStack.viewContext
//        let dateSort = NSSortDescriptor(key: #keyPath(Memo.date), ascending: false)
//        request.sortDescriptors = [dateSort]
//        resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext:context, sectionNameKeyPath: nil, cacheName: nil)
//        resultsController?.delegate = self
//        
//        do {
//            try resultsController?.performFetch()
//        } catch {
//            print("Error performing fetch \(error.localizedDescription)")
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setAndPerformResultsController()
//
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(MemoListViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        indicatingCell()
//    }
//    
//    func preferredContentSizeChanged(notification: Notification) {
//        tableView.reloadData()
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let identifier = segue.identifier else { return }
//        
//        switch identifier {
//        case "Memo":
//            let des = segue.destination as! MemoViewController
//            des.folder = folder
//            guard let memo = sender as? Memo else { return }
//            des.memo = memo
//            
//        case "DeletedMemoList":
//            let des = segue.destination as! UINavigationController
//            let first = des.topViewController as! DeletedMemoListViewController
//            first.folder = folder
//        default:
//            ()
//        }
//    }
//    
//    @IBAction func tapCreateMemoButton(_ sender: Any) {
//        performSegue(withIdentifier: "Memo", sender: nil)
//    }
//    
//    func setTableViewCellHeight() {
//        let originalString: String = "ForBodySize"
//        let myString = originalString
//        let bodySize: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
//        let callOutSize: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .callout)])
//        let margin: CGFloat = 10
//        
//        tableView.rowHeight = bodySize.height + callOutSize.height + (margin * 2)
//    }
//}
//
//extension MemoListViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "MemoCell")
//        configure(cell: cell, at: indexPath)
//        
//        return cell
//    }
//    
//    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
//        guard let controller = resultsController else { return }
//        let memo = controller.object(at: indexPath)
////        cell.textLabel?.text = memo.firstLine
//        cell.detailTextLabel?.text = formatter.string(from: memo.date)
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let controller = resultsController else { return 0 }
//        return controller.sections?[section].numberOfObjects ?? 0
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        guard let controller = resultsController else { return 0 }
//        return controller.sections?.count ?? 0
//    }
//}
//
//extension MemoListViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let controller = resultsController else { return }
//        let memo = controller.object(at: indexPath)
//        performSegue(withIdentifier: "Memo", sender: memo)
//        
//        indicatingCell = { [unowned self] in
//            self.tableView.deselectRow(at: indexPath, animated: true)
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        guard let controller = resultsController else { return }
//        let memo = controller.object(at: indexPath)
//        memo.isInTrash = true
//    }
//}
//
//extension MemoListViewController: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .delete:
//            guard let indexPath = indexPath else { return }
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        case .insert:
//            guard let newIndexPath = newIndexPath else { return }
//            tableView.insertRows(at: [newIndexPath], with: .automatic)
//        case .update:
//            guard let indexPath = indexPath else { return }
//            if let cell = tableView.cellForRow(at: indexPath) {
//                configure(cell: cell, at: indexPath)
//                cell.setNeedsLayout()
//            }
//        case .move:
//            guard let indexPath = indexPath,
//                let newIndexPath = newIndexPath else { return }
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            tableView.insertRows(at: [newIndexPath], with: .automatic)
//        }
//    }
//    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }
//}
//
//extension MemoListViewController {
//    override func encodeRestorableState(with coder: NSCoder) {
//        guard let folder = self.folder else { return }
//        let id = folder.objectID
//        coder.encode(id.uriRepresentation(), forKey: "folder")
//        super.encodeRestorableState(with: coder)
//        
//    }
//    
//    override func decodeRestorableState(with coder: NSCoder) {
//        
//        let objectURI = coder.decodeObject(forKey: "folder")
//        
//        guard let url = objectURI as? URL,
//            let objectID = coreDataStack.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)
//            else { return }
//        let object = self.coreDataStack.viewContext.object(with: objectID)
//        let folder = object as! Folder
//        self.folder = folder
//    
//        super.decodeRestorableState(with: coder)
//    }
//    
//    override func applicationFinishedRestoringState() {
//        setAndPerformResultsController()
//        title = folder?.name
//    }
//}
//
