//
//  MasterViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 20..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import CoreData

protocol MasterViewControllerDelegate: class {
    func masterViewController(_ controller: MasterViewController, send memo: Memo)
}

class MasterViewController: UIViewController {
    
    weak var delegate: MasterViewControllerDelegate?
    
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
    
    var memoResultsController: NSFetchedResultsController<Memo>! {
        didSet {
            memoResultsController.delegate = self
            do {
                try memoResultsController.performFetch()
                tableView.reloadData()
            } catch {
                print("Error performing fetch \(error.localizedDescription)")
            }
        }
    }
    
    var folder: Folder? {
        didSet {
            let request: NSFetchRequest<Memo> = Memo.fetchRequest()
            //TODO: folder ?? "" 이거 버그 생길 수 있는 경우가 있는 지 체크 -> 다 지운다음 확인
            request.predicate = NSPredicate(format: "isInTrash == false AND folder = %@", folder ?? " ")
            let context = PianoData.coreDataStack.viewContext
            let dateSort = NSSortDescriptor(key: #keyPath(Memo.date), ascending: false)
            request.sortDescriptors = [dateSort]
            memoResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext:context, sectionNameKeyPath: nil, cacheName: nil)
            
            self.title = folder?.name ?? " "
        }
    }
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    func registerNotificationForAjustTextSize(){
        NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func preferredContentSizeChanged(notification: Notification) {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableViewCellHeight()
        
        //폴더 fetch
        do {
            try folderResultsController.performFetch()
        } catch {
            print("Error performing fetch \(error.localizedDescription)")
        }
        
        //첫번째 폴더의 메모들 fetch
        if let folder = folderResultsController.fetchedObjects?.first {
            //같은 폴더일 경우 넘기지 말기
            guard self.folder != folder else { return }
            self.folder = folder
        } else {
            //folder에 nil 대입
            self.folder = nil
        }


        guard let splitViewController = splitViewController else { return }
        let detailNav = splitViewController.viewControllers.last as! UINavigationController
        delegate = detailNav.topViewController as! DetailViewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        deleteTopMemoIfEmpty()
    }
    
    func deleteTopMemoIfEmpty(){
        guard let memo = memoResultsController?.fetchedObjects?.first else { return }
        
        DispatchQueue.global().async {
            let attrText = NSKeyedUnarchiver.unarchiveObject(with: memo.content) as? NSAttributedString
            DispatchQueue.main.async {
                let textView = UITextView()
                textView.attributedText = attrText
                if textView.attributedText.length == 0 {
                    PianoData.coreDataStack.viewContext.delete(memo)
                    PianoData.save()
                }
            }
        }
    }
    
    func setTableViewCellHeight() {
        let originalString: String = "ForBodySize"
        let myString = originalString
        let bodySize: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
        let subHeadSize: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .caption1)])
        let margin: CGFloat = 16
        
        tableView.rowHeight = bodySize.height + subHeadSize.height + (margin * 2)
    }
    
    func selectTableViewCell(with indexPath: IndexPath){
        guard let objects = memoResultsController?.fetchedObjects, objects.count > 0 else { return }
        
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
        tableView(tableView, didSelectRowAt: indexPath)
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        //스토리보드에서 초기화할 때 컨테이너 뷰를 만들기 위해 segue를 거치므로 이 코드가 실행되기 때문에 이때에는 조기 탈출!
//        guard let identifier = segue.identifier else { return }
//        
//        if identifier == "GoToConfigureFolder" {
//            let des = segue.destination as! ConfigureFolderViewController
//            des.delegate = self
//            
//            if let existFolder = sender as? Folder{
//                des.folder = existFolder
//                des.isNewFolder = false
//            } else {
//                do {
//                    let context = PianoData.coreDataStack.viewContext
//                    let newFolder = Folder(context: context)
//                    newFolder.name = ""
//                    newFolder.date = Date()
//                    newFolder.memos = []
//                    //TODO: 아래 수정
//                    newFolder.imageName = "folder0"
//                    
//                    try context.save()
//                    des.folder = newFolder
//                    des.isNewFolder = true
//                    
//                    let folderListViewController = childViewControllers.first as! FolderListViewController
//                    if let objects = folderListViewController.resultsController.fetchedObjects, objects.count == 1 {
//                        folderListViewController.selectTableViewCell(with: IndexPath(row: 0, section: 0))
//                    }
//                    
//                } catch {
//                    print("Error importing folders: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
    
//    @IBAction func tapAddFolderButton(_ sender: Any) {
//        performSegue(withIdentifier: "GoToConfigureFolder", sender: nil)
//    }
    
    @IBAction func tapAddMemoButton(_ sender: Any) {
        addNewMemo()
    }
    
    //곧바로 여기 테이블 뷰에 접근하면 됨
    func addNewMemo(){
        
        //폴더를 먼저 추가해야 메모를 생성할 수 있음
        //TODO: 여기에 폴더를 먼저 추가하라는 팝업 창 띄워줘야함
        guard let folder = self.folder else {
            //폴더가 없다는 말이므로 폴더를 먼저 추가해달라고 말하기
            return }
        
        let memo = Memo(context: PianoData.coreDataStack.viewContext)
        memo.content = NSKeyedArchiver.archivedData(withRootObject: NSAttributedString())
        memo.date = Date()
        memo.folder = folder
        memo.firstLine = "새로운 메모"
        
        PianoData.save()
        
        //select하면 디테일뷰에 데이터 전달
        selectTableViewCell(with: IndexPath(row: 0, section: 0))
    }


}

//extension MasterViewController: ConfigureFolderViewControllerDelegate {
//
//    func configureFolderViewController(_ controller: ConfigureFolderViewController, deleteFolder: Folder) {
//        print(deleteFolder)
//        for item in deleteFolder.memos {
//            let memo = item as! Memo
//            PianoData.coreDataStack.viewContext.delete(memo)
//        }
//        
//        PianoData.coreDataStack.viewContext.delete(deleteFolder)
//        print(deleteFolder)
//        PianoData.save()
//        
//        print(deleteFolder)
//        //TODO: 삭제한 다음, 폴더가 존재한다면, indexPath  = 0인 셀을 선택하도록 하기, 존재하지 않는다면, folder에 nil을 곧바로 대입
//        let folderListViewController = childViewControllers.first as! FolderListViewController
//        folderListViewController.selectTableViewCell(with: IndexPath(row: 0, section: 0))
//    }
//    
//    func configureFolderViewController(_ controller: ConfigureFolderViewController, completeFolder: Folder) {
//        guard let text = controller.textField.text else { return }
//        completeFolder.name = text
//        //TODO: configure에서 선택된 이미지 이름 가져오기
//        completeFolder.imageName = "folder0"
//        PianoData.save()
//        
//        let folderListViewController = childViewControllers.first as! FolderListViewController
//        folderListViewController.selectTableView(with: completeFolder)
//    }
//}



extension MasterViewController: NSFetchedResultsControllerDelegate {
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
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension MasterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell") as! MemoCell
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    func configure(cell: MemoCell, at indexPath: IndexPath) {
        let memo = memoResultsController.object(at: indexPath)
        //TODO: Localizing
        cell.ibTitleLabel.text = memo.firstLine
        cell.ibSubTitleLabel.text = formatter.string(from: memo.date)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return memoResultsController?.sections?.count ?? 0
    }
}

extension MasterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let memo = memoResultsController.object(at: indexPath)
        memo.isInTrash = true
    }
    
    //메모 전달. 모든 메모는 여기서 전달하기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let memo = memoResultsController.object(at: indexPath)
        
        delegate?.masterViewController(self, send: memo)
        
        DispatchQueue.main.async { [unowned self] in
            if let detailViewController = self.delegate as? DetailViewController {
                self.splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
            }
        }
        
    }
}
