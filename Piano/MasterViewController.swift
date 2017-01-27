//
//  MasterViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 20..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import CoreData
import LTMorphingLabel

protocol MasterViewControllerDelegate: class {
    func masterViewController(_ controller: MasterViewController?, send memo: Memo)
}

class MasterViewController: UIViewController {
    
    @IBOutlet weak var composeBarButton: UIButton!
    @IBOutlet weak var titleLabel: LTMorphingLabel!
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
            
            titleLabel.text = folder?.name ?? " "
            
            guard let nav = splitViewController?.viewControllers.last as? UINavigationController,
                let detailViewController = nav.topViewController as? DetailViewController else {
                return
            }
            
            detailViewController.memo = nil
            
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
    
    
    @IBOutlet weak var leftPageButton: UIButton!
    @IBOutlet weak var pageLabel: LTMorphingLabel!
    
    func registerNotificationForAjustTextSize(){
        NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func preferredContentSizeChanged(notification: Notification) {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        
        setTableViewCellHeight()
        
        fetchFolderResultsController()
        
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
        let detailViewController = detailNav.topViewController as! DetailViewController
        delegate = detailViewController
        detailViewController.delegate = self
    }
    
    func fetchFolderResultsController() {
        //폴더 fetch
        do {
            try folderResultsController.performFetch()
        } catch {
            print("Error performing fetch \(error.localizedDescription)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        deleteTopMemoIfEmpty()
    }
    
    func deleteTopMemoIfEmpty(){
        guard let memo = memoResultsController?.fetchedObjects?.first else { return }
        
        DispatchQueue.global().async {
            let attrText = NSKeyedUnarchiver.unarchiveObject(with: memo.content as! Data) as? NSAttributedString
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
    
    @IBAction func tapTitleButton(_ sender: Any) {
        //경고창 띄워서 페이지 이름 수정, 취소
        
        guard let folder = self.folder else { return }
        
        showModifyPageAlertViewController(with: folder)
    }
    
    func showModifyPageAlertViewController(with folder: Folder) {
        let alert = UIAlertController(title: "페이지 이름 변경", message: "변경할 페이지의 이름을 적어주세요.", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "확인", style: .default) { [unowned self](_) in
            guard let text = alert.textFields?.first?.text else { return }
            
            folder.name = text
            self.titleLabel.text = text
            PianoData.save()
        }
        
        ok.isEnabled = folder.name?.characters.count != 0 ? true : false
        alert.addAction(cancel)
        alert.addAction(ok)
        
        alert.addTextField { (textField) in
            textField.placeholder = "페이지 이름"
            textField.text = folder.name
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func tapLeftPageButton(_ sender: UIButton) {
        guard let folders = folderResultsController.fetchedObjects else { return }
        
        //일단 왼쪽 폴더 넣고 페이지 타이틀 갱신 + 더이상 왼쪽으로 갈 수 있는 지 체크해서 enabled 세팅하기
        for (index, folder) in folders.enumerated() {
            if self.folder == folder, index > 0 {
                let leftIndex = index - 1
                let leftFolder = folders[leftIndex]
                self.folder = leftFolder
                self.pageLabel.text = "\(leftIndex + 1)"
                sender.isEnabled = leftIndex > 0 ? true : false
                return
            }
        }
    }
    
    @IBAction func tapRightPageButton(_ sender: UIButton) {
        guard let folders = folderResultsController.fetchedObjects else { return }
        
        for (index, folder) in folders.enumerated() {
            if self.folder == folder {
                let rightIndex = index + 1
                
                guard rightIndex < folders.count else {
                    //폴더 생성 알럿 뷰
                    showAddGroupAlertViewController()
                    return
                }
                
                let rightFolder = folders[rightIndex]
                self.folder = rightFolder
                pageLabel.text = "\(rightIndex + 1)"
                leftPageButton.isEnabled = true
                return
            }
        }
    }
    
    func selectSpecificFolder(selectedFolder: Folder) {
        guard let folders = folderResultsController.fetchedObjects else { return }
        
        self.folder = selectedFolder
        
        for (index, folder) in folders.enumerated() {
            if self.folder == folder {
                
                pageLabel.text = "\(index + 1)"
                leftPageButton.isEnabled = index > 0 ? true : false
                return
                
            }
        }
    }
    
    func textChanged(sender: AnyObject) {
        let tf = sender as! UITextField
        var resp : UIResponder! = tf
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[1].isEnabled = (tf.text != "")
    }
    
    func showAddGroupAlertViewController() {
        let alert = UIAlertController(title: "페이지 만들기", message: "페이지의 이름을 정해주세요.", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "생성", style: .default) { [unowned self](action) in
            guard let text = alert.textFields?.first?.text else { return }
            let context = PianoData.coreDataStack.viewContext
            do {
                let newFolder = Folder(context: context)
                newFolder.name = text
                newFolder.date = NSDate()
                newFolder.memos = []
                
                try context.save()
                
                //TODO: 한칸 오른쪽으로 이동하기
                self.fetchFolderResultsController()
                self.selectSpecificFolder(selectedFolder: newFolder)
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
        
        deleteTopMemoIfEmpty()
        
        let memo = Memo(context: PianoData.coreDataStack.viewContext)
        memo.content = NSKeyedArchiver.archivedData(withRootObject: NSAttributedString()) as NSData
        memo.date = NSDate()
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
        cell.ibSubTitleLabel.text = formatter.string(from: memo.date as! Date)
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

extension MasterViewController: DetailViewControllerDelegate {
    func detailViewController(_ controller: DetailViewController, addMemo: Memo) {
        guard let memos = memoResultsController.fetchedObjects else { return }
        
        for (index, memo) in memos.enumerated() {
            if memo == addMemo {
                tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
            }
        }
    }
}
