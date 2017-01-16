//
//  ConfigureFolderViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 16..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit

class ConfigureFolderViewController: UIViewController {

    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var bottomViewBottom: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var textField: UITextField!
    let coreDataStack = PianoData.coreDataStack

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.becomeFirstResponder()
//        setCollectionViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConfigureFolderViewController.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConfigureFolderViewController.setCollectionViewLayout), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func setCollectionViewLayout() {
        let layout = collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let length = collectionView.frame.height > 120 ? 120 : collectionView.frame.height
        layout.itemSize = CGSize(width: length, height: length)
    }
    
    func keyboardWillShow(notification: Notification){
        
        guard let userInfo = notification.userInfo,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return }
        let kbHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        
        UIView.animate(withDuration: duration) { [weak self] in
            //TODO: change literal constant
            self?.bottomViewBottom.constant = kbHeight
            self?.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func tapDeleteButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }

    @IBAction func tapCompleteButton(_ sender: Any) {
        guard let text = textField.text else { return }
        
        do {
            
            let context = coreDataStack.viewContext
            let newFolder = Folder(context: context)
            newFolder.name = text
            newFolder.date = Date()
            newFolder.memos = []
            //TODO: 아래 수정
            newFolder.imageName = "select0"
            
            try context.save()
            
//            guard let groupListVC = self.childViewControllers.first as? GroupListViewController else { return }
//            groupListVC.selectSpecificRow(indexPath: IndexPath(row: order, section: 0))
        } catch {
            print("Error importing folders: \(error.localizedDescription)")
        }

//        guard let groupListVC = self.childViewControllers.first as? GroupListViewController else { return }
//        groupListVC.selectSpecificRow(indexPath: IndexPath(row: order, section: 0))
        
        
        dismiss(animated: true, completion: nil)
    }
    
    
   
    
    
}

extension ConfigureFolderViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let id = ConfigureFolderCell.reuseIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ConfigureFolderCell
        
        return cell
    }
}


extension ConfigureFolderViewController: UICollectionViewDelegate {
    
}

extension ConfigureFolderViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            completeButton.isEnabled = false
            return
        }
        completeButton.isEnabled = text.characters.count > 0 ? true : false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            completeButton.isEnabled = false
            return true
        }
        completeButton.isEnabled = text.characters.count > 0 ? true : false
        return true
    }
}
