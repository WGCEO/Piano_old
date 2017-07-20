//
//  FAQViewController.swift
//  Piano
//
//  Created by changi kim on 2017. 7. 19..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import CoreData

class OldNoteListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let coreDataStack = PianoData.coreDataStack
    lazy private var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    lazy private var resultsController: NSFetchedResultsController<Memo> = {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        request.predicate = NSPredicate(format: "isInTrash == false")
        let context = self.coreDataStack.viewContext
        let dateSort = NSSortDescriptor(key: #keyPath(Memo.date), ascending: true)
        request.sortDescriptors = [dateSort]
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext:context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func setTableViewCellHeight() {
        let originalString: String = "ForBodySize"
        let myString = originalString
        let bodySize: CGSize = myString.size(withAttributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .body)])
        let callOutSize: CGSize = myString.size(withAttributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .callout)])
        let margin: CGFloat = 10
        
        tableView.rowHeight = bodySize.height + callOutSize.height + (margin * 2)
    }
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(OldNoteListViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    @objc func preferredContentSizeChanged(notification: Notification) {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "OldNoteViewController":
            let des = segue.destination as! OldNoteViewController
            des.coreDataStack = coreDataStack
            guard let memo = sender as? Memo else { return }
            des.memo = memo
            
        default:
            ()
        }
    }

    @IBAction func back(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }
}

extension OldNoteListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell") as! NoteCell
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    func configure(cell: NoteCell, at indexPath: IndexPath) {
        let memo = resultsController.object(at: indexPath)
        
        cell.headerLabel.text = memo.firstLine
        cell.dateLabel.text = formatter.string(from: memo.date! as Date)
        
        
        if let data = memo.imageData {
            let image = UIImage(data: data as Data)
            cell.ibImageView.image = image
        } else {
            cell.ibImageView.image = nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultsController.sections?.count ?? 0
    }
}

extension OldNoteListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = resultsController.object(at: indexPath)
        performSegue(withIdentifier: "OldNoteViewController", sender: note)
    }
}

extension OldNoteListViewController: NSFetchedResultsControllerDelegate {
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
            if let cell = tableView.cellForRow(at: indexPath) as? NoteCell {
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
