//
//  MasterViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 20..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        guard let splitViewController = splitViewController else { return }
        let detailNav = splitViewController.viewControllers.last as! UINavigationController
        let detailViewController = detailNav.topViewController as! DetailViewController
        let memoListViewController = childViewControllers.last as! MemoListViewController
        memoListViewController.delegate = detailViewController
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //스토리보드에서 초기화할 때 컨테이너 뷰를 만들기 위해 segue를 거치므로 이 코드가 실행되기 때문에 이때에는 조기 탈출!
        guard let identifier = segue.identifier else { return }
        
        if identifier == "GoToConfigureFolder" {
            let des = segue.destination as! ConfigureFolderViewController
            des.delegate = self
            
            if let existFolder = sender as? Folder{
                des.folder = existFolder
                des.isNewFolder = false
            } else {
                do {
                    let context = PianoData.coreDataStack.viewContext
                    let newFolder = Folder(context: context)
                    newFolder.name = ""
                    newFolder.date = Date()
                    newFolder.memos = []
                    //TODO: 아래 수정
                    newFolder.imageName = "folder0"
                    
                    try context.save()
                    des.folder = newFolder
                    des.isNewFolder = true
                    
                    let folderListViewController = childViewControllers.first as! FolderListViewController
                    if let objects = folderListViewController.resultsController.fetchedObjects, objects.count == 1 {
                        folderListViewController.selectTableViewCell(with: IndexPath(row: 0, section: 0))
                    }
                    
                } catch {
                    print("Error importing folders: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func tapAddFolderButton(_ sender: Any) {
        performSegue(withIdentifier: "GoToConfigureFolder", sender: nil)
    }
    
    @IBAction func tapAddMemoButton(_ sender: Any) {
        addNewMemo()
    }
    
    
    func addNewMemo(){
        let memoListViewController = childViewControllers.last as! MemoListViewController
        
        //폴더를 먼저 추가해야 메모를 생성할 수 있음
        //TODO: 여기에 폴더를 먼저 추가하라는 팝업 창 띄워줘야함
        guard let folder = memoListViewController.folder else { return }
        
        let memo = Memo(context: PianoData.coreDataStack.viewContext)
        memo.content = NSKeyedArchiver.archivedData(withRootObject: NSAttributedString())
        memo.date = Date()
        memo.folder = folder
        memo.firstLine = "새로운 메모"
        
        PianoData.save()
        
        //select하면 디테일뷰에 데이터 전달
        memoListViewController.selectTableViewCell(with: IndexPath(row: 0, section: 0))
    }


}

extension MasterViewController: ConfigureFolderViewControllerDelegate {

    func configureFolderViewController(_ controller: ConfigureFolderViewController, deleteFolder: Folder) {
        print(deleteFolder)
        for item in deleteFolder.memos {
            let memo = item as! Memo
            PianoData.coreDataStack.viewContext.delete(memo)
        }
        
        PianoData.coreDataStack.viewContext.delete(deleteFolder)
        print(deleteFolder)
        PianoData.save()
        
        print(deleteFolder)
        //TODO: 삭제한 다음, 폴더가 존재한다면, indexPath  = 0인 셀을 선택하도록 하기, 존재하지 않는다면, folder에 nil을 곧바로 대입
        let folderListViewController = childViewControllers.first as! FolderListViewController
        folderListViewController.selectTableViewCell(with: IndexPath(row: 0, section: 0))
    }
    
    func configureFolderViewController(_ controller: ConfigureFolderViewController, completeFolder: Folder) {
        guard let text = controller.textField.text else { return }
        completeFolder.name = text
        //TODO: configure에서 선택된 이미지 이름 가져오기
        completeFolder.imageName = "folder0"
        PianoData.save()
        
        let folderListViewController = childViewControllers.first as! FolderListViewController
        folderListViewController.selectTableView(with: completeFolder)
    }
}
