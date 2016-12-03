//
//  TopViewController.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func tapApplyButton(_ sender: Any) {
        //TODO: 중복코드 처리하기
        guard let parent = parent as? MemoViewController else { return }
        parent.showTopView(bool: false)
        parent.textView.isSelectable = true
        parent.textView.isEditable = true
        parent.textView.canvas.removeFromSuperview()
        parent.textView.mode = .typing
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        guard let parent = parent as? MemoViewController else { return }
        parent.showTopView(bool: false)
        parent.textView.isSelectable = true
        parent.textView.isEditable = true
        parent.textView.canvas.removeFromSuperview()
        parent.textView.mode = .typing
    }
}

extension TopViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextEffectCell.reuseIdentifier, for: indexPath) as! TextEffectCell
        
        switch indexPath.item {
        case 0:
            cell.imageView.image = UIImage(named: "b")
        case 1:
            cell.imageView.image = UIImage(named: "textColor")
        case 2:
            cell.imageView.image = UIImage(named: "textBg")
        case 3:
            cell.imageView.image = UIImage(named: "textLine")
        case 4:
            cell.imageView.image = UIImage(named: "italic")
        case 5:
            cell.imageView.image = UIImage(named: "textColor")
        case 6:
            cell.imageView.image = UIImage(named: "textBg")
        case 7:
            cell.imageView.image = UIImage(named: "textLine")
        case 8:
            cell.imageView.image = UIImage(named: "italic")
        case 9:
            cell.imageView.image = UIImage(named: "b")
        default:
            ()
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
}

extension TopViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 5, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        label.text = scrollView.contentOffset.x != 0.0 ? "텍스트 스타일" : "텍스트 효과"
    }
}
