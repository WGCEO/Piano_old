////
////  MemoListViewController.swift
////  Piano
////
////  Created by kevin on 2017. 1. 20..
////  Copyright © 2017년 Piano. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//protocol MemoListViewControllerDelegate: class {
//    func memoListViewController(_ controller: MemoListViewController, send memo: Memo)
//}
//
//class MemoListViewController: UIViewController {
//    
//    @IBOutlet weak var folderNameLabel: UILabel!
//    
////    weak var delegate: MemoListViewControllerDelegate?
//    @IBOutlet weak var tableView: UITableView!
//    var resultsController: NSFetchedResultsController<Memo>! {
//        didSet {
//            resultsController.delegate = self
//            
//            do {
//                try resultsController.performFetch()
//                tableView.reloadData()
//            } catch {
//                print("Error performing fetch \(error.localizedDescription)")
//            }
//        }
//    }
//    var folder: Folder? {
//        didSet {
//            let request: NSFetchRequest<Memo> = Memo.fetchRequest()
//            //TODO: folder ?? "" 이거 버그 생길 수 있는 경우가 있는 지 체크 -> 다 지운다음 확인
//            request.predicate = NSPredicate(format: "isInTrash == false AND folder = %@", folder ?? " ")
//            let context = PianoData.coreDataStack.viewContext
//            let dateSort = NSSortDescriptor(key: #keyPath(Memo.date), ascending: false)
//            request.sortDescriptors = [dateSort]
//            resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext:context, sectionNameKeyPath: nil, cacheName: nil)
//            
//            guard let label = folderNameLabel else { return }
//            label.text = folder?.name ?? " "
//        }
//    }
//    
//    lazy var formatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .short
//        formatter.doesRelativeDateFormatting = true
//        return formatter
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        folderNameLabel.text = folder?.name ?? " "
//        self.setTableViewCellHeight()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        guard let memo = resultsController?.fetchedObjects?.first else { return }
//        
//        DispatchQueue.global().async {
//            let attrText = NSKeyedUnarchiver.unarchiveObject(with: memo.content) as? NSAttributedString
//            DispatchQueue.main.async {
//                let textView = UITextView()
//                textView.attributedText = attrText
//                if textView.attributedText.size().width == 0 {
//                    PianoData.coreDataStack.viewContext.delete(memo)
//                    PianoData.save()
//                }
//            }
//        }
//    }
//    
//    func registerNotificationForAjustTextSize(){
//        NotificationCenter.default.addObserver(self, selector: #selector(MemoListViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
//    }
//    
//    func preferredContentSizeChanged(notification: Notification) {
//        tableView.reloadData()
//    }
//    
//    func setTableViewCellHeight() {
//        let originalString: String = "ForBodySize"
//        let myString = originalString
//        let bodySize: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
//        let subHeadSize: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .subheadline)])
//        let margin: CGFloat = 12
//        
//        tableView.rowHeight = bodySize.height + subHeadSize.height + (margin * 2)
//    }
//
//    func selectTableViewCell(with indexPath: IndexPath){
//        guard let objects = resultsController?.fetchedObjects, objects.count > 0 else { return }
//        
//        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
//        tableView(tableView, didSelectRowAt: indexPath)
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
//            if let cell = tableView.cellForRow(at: indexPath) as? MemoCell {
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
//extension MemoListViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell") as! MemoCell
//        configure(cell: cell, at: indexPath)
//        
//        return cell
//    }
//    
//    func configure(cell: MemoCell, at indexPath: IndexPath) {
//        let memo = resultsController.object(at: indexPath)
//        //TODO: Localizing
//        cell.ibTitleLabel.text = memo.firstLine
//        cell.ibSubTitleLabel.text = formatter.string(from: memo.date)
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return resultsController?.sections?[section].numberOfObjects ?? 0
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return resultsController?.sections?.count ?? 0
//    }
//}
//
//extension MemoListViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        let memo = resultsController.object(at: indexPath)
//        memo.isInTrash = true
//    }
//    
//    //메모 전달. 모든 메모는 여기서 전달하기
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        
//        guard let masterViewController = parent as? MasterViewController else { return }
//        let memo = resultsController.object(at: indexPath)
//
//        delegate?.memoListViewController(self, send: memo)
//        
//        DispatchQueue.main.async { [unowned self] in
//            if let detailViewController = self.delegate as? DetailViewController {
//                masterViewController.splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
//            }
//        }
//        
//    }
//}
