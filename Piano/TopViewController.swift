//
//  TopViewController.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
    }
}

extension TopViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextEffectCell.reuseIdentifier, for: indexPath) as! TextEffectCell
        cell.backgroundColor = cell.isSelected ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        switch indexPath.item {
        case 0:
            cell.awesomeLabel.text = "\u{f031}"
            cell.awesomeLabel.textColor = UIColor.red
            cell.awesomeLabel.font.withSize(17)
            cell.textEffect = .red
        case 1:
            cell.awesomeLabel.text = "\u{f1dc}"
            cell.awesomeLabel.font.withSize(22)
            cell.awesomeLabel.textColor = UIColor.black
            cell.textEffect = .title3
        case 2:
            cell.awesomeLabel.text = "\u{f0cc}"
            cell.awesomeLabel.textColor = UIColor.black
            cell.awesomeLabel.font.withSize(17)
            cell.textEffect = .strike
        default:
            ()
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
}

extension TopViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let parent = parent as? MemoViewController,
            let cell = collectionView.cellForItem(at: indexPath) as? TextEffectCell
        else { return }
        
        let control = parent.textView.canvas
        control.textEffect = cell.textEffect 
    }
}

extension TopViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 3, height: 56)
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
//        label.text = scrollView.contentOffset.x != 0.0 ? "텍스트 스타일" : "텍스트 효과"
    }
}
