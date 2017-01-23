//
//  ConfigureFolderViewController.swift
//  Piano
//
//  Created by kevin on 2017. 1. 16..
//  Copyright © 2017년 Piano. All rights reserved.
//

import UIKit
import CoreData

protocol ConfigureFolderViewControllerDelegate: class {
    func configureFolderViewController(_ controller: ConfigureFolderViewController, deleteFolder: Folder)
    func configureFolderViewController(_ controller: ConfigureFolderViewController, completeFolder: Folder)
}

class ConfigureFolderViewController: UIViewController {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var bottomViewBottom: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var textField: UITextField!
    let coreDataStack = PianoData.coreDataStack
    weak var delegate: ConfigureFolderViewControllerDelegate?
    
    //폴더 있을 때: (폴더 삭제, 수정하기) 폴더 없을 때: (취소, 폴더 생성)
    var folder: Folder!
    var isNewFolder: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingUI()
        textField.becomeFirstResponder()
        setCollectionViewLayout()
    }
    
    func settingUI(){
        if isNewFolder {
            deleteButton.setTitle("취소", for: .normal)
            deleteButton.setTitleColor(.white, for: .normal)
            completeButton.setTitle("폴더 생성", for: .normal)
        } else {
            textField.text = folder.name
            //TODO: 컬렉션뷰를 폴더의 해당 이미지에 일치하는 곳으로 이동시키기
            deleteButton.setTitle("폴더 영구 삭제", for: .normal)
            deleteButton.setTitleColor(.red, for: .normal)
            completeButton.setTitle("수정하기", for: .normal)
        }
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

        delegate?.configureFolderViewController(self, deleteFolder: folder)
        textField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func tapCompleteButton(_ sender: Any) {
        
        delegate?.configureFolderViewController(self, completeFolder: folder)
        textField.resignFirstResponder()
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
