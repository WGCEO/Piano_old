//
//  MemoTableViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 20..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import CoreData
import LTMorphingLabel

class MemoTableViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: LTMorphingLabel!
    
    var folder: Folder? {
        didSet {
            MemoManager.currentFolder = folder
            
            titleLabel.text = folder?.name ?? " "
            
            setFirstCellIfIpad()
        }
    }
    
    lazy var memoViewController: MemoViewController = {
        let unwrapSplitViewController = self.splitViewController!
        let unwrapDetailNav = unwrapSplitViewController.viewControllers.last as! UINavigationController
        return unwrapDetailNav.topViewController as! MemoViewController
    }()
    
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var leftPageButton: UIBarButtonItem!
    
    
    
    func registerNotificationForAjustTextSize(){
        NotificationCenter.default.addObserver(self, selector: #selector(MemoTableViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func preferredContentSizeChanged(notification: Notification) {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        registerNotificationForAjustTextSize()
        
        setTableViewCellHeight()
        
        //첫번째 폴더의 메모들 fetch
        setFirstFolderIfExist()

        //detailViewController.delegate = self
    
    }
    
    
    func setFirstFolderIfExist() {
        let folder = MemoManager.folders.first
        
        guard self.folder != folder else { return }
        
        self.folder = folder
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        //아이폰일때만 지워라잉?
        /*
        if !detailViewController.isVisible {
            detailViewController.saveCoreDataIfIphone()
            
            indicatingCell()
            indicatingCell = {}
        }
        */
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
        
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
        tableView(tableView, didSelectRowAt: indexPath)
    }
    
    @IBAction func tapTitleButton(_ sender: Any) {
        //경고창 띄워서 페이지 이름 수정, 취소
        
        guard let folder = self.folder else { return }
        guard canDoAnotherTask() else { return }
        
        showModifyPageAlertViewController(with: folder)
    }
    
    func showModifyPageAlertViewController(with folder: Folder) {
        let alert = UIAlertController(title: "ChangeFolderNameTitle".localized(withComment: "폴더 이름 변경"), message: "ChangeFolderNameMessage".localized(withComment: "폴더의 이름을 적어주세요."), preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel".localized(withComment: "취소"), style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "OK".localized(withComment: "확인"), style: .default) { [unowned self](_) in
            guard let text = alert.textFields?.first?.text else { return }
            
            folder.name = text
            self.titleLabel.text = text
            PianoData.save()
        }
        
        ok.isEnabled = folder.name?.characters.count != 0 ? true : false
        alert.addAction(cancel)
        alert.addAction(ok)
        
        alert.addTextField { (textField) in
            textField.placeholder = "FolderName".localized(withComment: "폴더이름")
            textField.text = folder.name
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tapLeftPageBarButton(_ sender: UIBarButtonItem) {
        guard canDoAnotherTask() else { return }
        
        let folders = MemoManager.folders
        
        //일단 왼쪽 폴더 넣고 페이지 타이틀 갱신 + 더이상 왼쪽으로 갈 수 있는 지 체크해서 enabled 세팅하기
        for (index, folder) in folders.enumerated() {
            if self.folder == folder, index > 0 {
                let leftIndex = index - 1
                let leftFolder = folders[leftIndex]
                //이전 폴더 대입
                self.folder = leftFolder
                //enabled 세팅
                sender.isEnabled = leftIndex > 0 ? true : false
                return
            }
        }
    }
    
    func canDoAnotherTask() -> Bool{
        return ActivityIndicator.sharedInstace.isAnimating
    }
    
    @IBAction func tapRightPageBarButton(_ sender: UIBarButtonItem) {
        guard canDoAnotherTask() else { return }
        
        let folders = MemoManager.folders
        
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
                leftPageButton.isEnabled = true
                return
            }
        }
        
        showAddGroupAlertViewController()
    }

    func setFirstCellIfIpad() {
        if memoViewController.isVisible {
            
            if hasMemoInCurrentFolder() {
                selectTableViewCell(with: IndexPath(row: 0, section: 0))
            } else {
                //detailViewController.memo = nil
            }
        }
    }
    
    func hasMemoInCurrentFolder() -> Bool {
        if MemoManager.memoes.count != 0 {
            return true
        } else {
            return false
        }
    }
    
    func selectSpecificFolder(selectedFolder: Folder) {
        let folders = MemoManager.folders
        
        self.folder = selectedFolder
        
        for (index, folder) in folders.enumerated() {
            if self.folder == folder {
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
        let alert = UIAlertController(title: "AddFolderTitle".localized(withComment: "폴더 생성"), message: "AddFolderMessage".localized(withComment: "폴더의 이름을 적어주세요."), preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel".localized(withComment: "취소"), style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "Create".localized(withComment: "생성"), style: .default) { [unowned self](action) in
            guard let text = alert.textFields?.first?.text else { return }
            let context = PianoData.coreDataStack.viewContext
            do {
                let newFolder = Folder(context: context)
                newFolder.name = text
                newFolder.date = NSDate()
                newFolder.memos = []
                
                try context.save()
                
                MemoManager.fetchFolders()
                self.selectSpecificFolder(selectedFolder: newFolder)
            } catch {
                print("Error importing folders: \(error.localizedDescription)")
            }
        }
        
        ok.isEnabled = false
        alert.addAction(cancel)
        alert.addAction(ok)
        
        alert.addTextField { (textField) in
            textField.placeholder = "FolderName".localized(withComment: "폴더이름")
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tapComposeBarButton(_ item: UIBarButtonItem) {
        item.isEnabled = false
        
        let deadline = DispatchTime.now() + .milliseconds(50)
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            self?.addNewMemo()
            
            item.isEnabled = true
        }
    }
    
    
    //곧바로 여기 테이블 뷰에 접근하면 됨
    func addNewMemo(){
        let _ = MemoManager.newMemo()
        
        //select하면 디테일뷰에 데이터 전달
        selectTableViewCell(with: IndexPath(row: 0, section: 0))
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        if identifier == "ConfigureFolderViewController" {
            let nav = segue.destination as! UINavigationController
            let configureFolderViewController = nav.topViewController as! ConfigureFolderViewController
            configureFolderViewController.delegate = self
        } else if identifier == "MoveMemoViewController" {
            let nav = segue.destination as! UINavigationController
            let moveMemoViewController = nav.topViewController as! MoveMemoViewController
            guard let customObj = sender as? (Memo, CGRect) else { return }
            moveMemoViewController.memo = customObj.0
            nav.popoverPresentationController?.sourceRect = customObj.1
            
            
        }
    }
}

extension MemoTableViewController: ConfigureFolderViewControllerDelegate {
    func configureFolderViewController(_ controller: ConfigureFolderViewController, selectFolder: Folder) {
        MemoManager.fetchFolders()
        selectSpecificFolder(selectedFolder: selectFolder)
    }
    
    func configureFolderViewController(_ controller: ConfigureFolderViewController, deleteFolder: Folder) {
        MemoManager.fetchFolders()
        let folders = MemoManager.folders
        
        guard let firstFolder = folders.first else {
            //폴더가 아예 없다면,
            self.folder = nil
            leftPageButton.isEnabled = false
            return
        }
        
        if folder == deleteFolder {
            //맨 처음으로 보내버리기
            selectSpecificFolder(selectedFolder: firstFolder)
        } else {
            //TODO: selectSpecificFolder의 내용과 사뭇 일치하므로 리펙토링해야함
            for (index, folder) in folders.enumerated() {
                if self.folder == folder {
                    leftPageButton.isEnabled = index > 0 ? true : false
                    return
                }
            }
        }
        
    }
}



extension MemoTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell") as! MemoCell
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    func configure(cell: MemoCell, at indexPath: IndexPath) {
        guard let memo = MemoManager.memo(at: indexPath) else { return }
        
        //TODO: Localizing
        cell.ibTitleLabel.text = memo.firstLine
        cell.ibSubTitleLabel.text = formatter.string(from: memo.date! as Date)
        
        let view = UIView()
        view.backgroundColor = UIColor.piano
        cell.selectedBackgroundView = view
        
        if let data = memo.imageData {
            let image = UIImage(data: data as Data)
            cell.ibImageView.image = image
        } else {
            cell.ibImageView.image = nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return MemoManager.sections()?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return MemoManager.sections()?.count ?? 0
    }
}

extension MemoTableViewController: UITableViewDelegate {
    internal func deselectRowIfNeeded() {
        // TODO: if iPhone일 때만 선택해제
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let memo = MemoManager.memo(at: indexPath)
        memo?.isInTrash = true
    }
    
    //메모 전달. 모든 메모는 여기서 전달하기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deselectRowIfNeeded()
        
        guard let navigationController = memoViewController.navigationController else { return }
        
        let memo = MemoManager.memo(at: indexPath)
        memoViewController.memo = memo
        
        self.splitViewController?.showDetailViewController(navigationController, sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let memo = MemoManager.memo(at: indexPath) else { return nil }
        
        let move = UITableViewRowAction(style: .normal, title: "Move".localized(withComment: "이동")) { [unowned self](action, indexPath) in
            let rect = tableView.rectForRow(at: indexPath)
            let customObj: (Memo, CGRect) = (memo, rect)
            self.performSegue(withIdentifier: "MoveMemoViewController", sender: customObj)
        }
        move.backgroundColor = .orange
        
        let delete =  UITableViewRowAction(style: .normal, title: "Delete".localized(withComment: "삭제")) { (action, indexPath) in
            memo.isInTrash = true
            PianoData.save()
        }
        
        delete.backgroundColor = .red
        
        
        return [delete, move]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

/* Memo Manager를 이용하는 것으로 변경
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
*/
