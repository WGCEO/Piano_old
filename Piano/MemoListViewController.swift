//
//  MemoListViewController.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import CoreData
import UIKit

class MemoListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
//    lazy var folderPredicate: NSPredicate = {
//        return NSPredicate(format: "folder = %@", self.folder)
//    }()
    var coreDataStack: PianoPersistentContainer!
    var folder: Folder!
    
    var indicatingCell: () -> Void = {}
    
    lazy var resultsController: NSFetchedResultsController<Memo> = {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        request.predicate = NSPredicate(format: "isInTrash == false AND folder = %@", self.folder)
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
        
        do {
            try resultsController.performFetch()
        } catch {
            print("Error performing fetch \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MemoListViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        indicatingCell()
        
        
        //이거 배열에 리터럴 숫자 넣어서 에러생기는 지 체크(메모가 아무것도 없을 때)
        guard let count = resultsController.sections?[0].numberOfObjects, count != 0 else { return }
        
        for index in 0...count - 1 {
            let memo = resultsController.object(at: IndexPath(row: index, section: 0))
            let attrText = NSKeyedUnarchiver.unarchiveObject(with: memo.content) as! NSAttributedString
            if attrText.string.isEmpty {
                let context = coreDataStack.viewContext
                context.delete(memo)
                do {
                    try context.save()
                } catch {
                    print("error: \(error)")
                }
                return  //어차피 하나밖에 지울 게 없을 것이므로(제일 첫번 째 로우)
            }
        }
    }
    
    func preferredContentSizeChanged(notification: Notification) {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "Memo":
            let des = segue.destination as! MemoViewController
            des.coreDataStack = coreDataStack
            des.folder = folder
            
            guard let memo = sender as? Memo else { return }
            des.memo = memo
        default:
            ()
        }
    }
    
    @IBAction func tapCreateMemoButton(_ sender: Any) {
        performSegue(withIdentifier: "Memo", sender: nil)
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

extension MemoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "MemoCell")
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        let memo = resultsController.object(at: indexPath)
        cell.textLabel?.text = memo.firstLine
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultsController.sections?.count ?? 0
    }
}

extension MemoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let memo = resultsController.object(at: indexPath)
        performSegue(withIdentifier: "Memo", sender: memo)
        
        indicatingCell = { [unowned self] in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension MemoListViewController: NSFetchedResultsControllerDelegate {
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

