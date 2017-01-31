//
//  SelectEffectViewController.swift
//  Piano
//
//  Created by kevin on 2016. 12. 27..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class SelectEffectViewController: UIViewController {
    
    weak var selectedButton: EffectButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    lazy var dataSource: [TextEffect] = {
        switch self.selectedButton.textEffect {
        case .color:
            let canvas = ColorPalette()
            return canvas.palette
        case .title:
            return [.title(.title3), .title(.title2), .title(.title1)]
        case .line:
            return [.line(.strikethrough), .line(.underline)]
        }
    }()
    
    let padding: CGFloat = 16
    let cellSize = CGSize(width: 40, height: 40)

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let effect = selectedButton.textEffect
        
        switch effect {
        case .color:
            descriptionLabel.text = "색상을 선택해주세요."
        case .title:
            descriptionLabel.text = "제목의 크기를 선택해주세요."
        case .line:
            descriptionLabel.text = "선의 종류를 선택해주세요."
        }

        // Do any additional setup after loading the view.
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }

}

extension SelectEffectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextEffectCell.reuseIdentifier, for: indexPath) as! TextEffectCell

        let data = dataSource[indexPath.item]
        cell.textEffect = data
        
        switch data {
        case .color(let x):
            cell.backgroundColor = x
            cell.awesomeLabel.text = ""
            cell.awesomeLabel.textColor = x
        case .title(let x):
            
            let font = UIFont.preferredFont(forTextStyle: x)
            let size = font.pointSize + CGFloat(6)
            cell.awesomeLabel.font = cell.awesomeLabel.font.withSize(size)
            cell.awesomeLabel.text = "\u{f1dc}"
            cell.awesomeLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
        case .line(let x):
            
            cell.awesomeLabel.text = x != .strikethrough ?  "\u{f0cd}" : "\u{f0cc}"
            cell.awesomeLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
}

extension SelectEffectViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TextEffectCell
            else { return }

        selectedButton.textEffect = cell.textEffect
        dismiss(animated: true, completion: nil)
    }
}

extension SelectEffectViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch selectedButton.textEffect {
        case .color:
            let edge = (view.bounds.width - (cellSize.width * 8 + padding * 7)) / 2
            
            return edge > 0 ?
                UIEdgeInsetsMake(0, edge, 0, edge) :
                UIEdgeInsetsMake(0, padding, 0, padding)
        case .title:
            let edge = (view.bounds.width - (cellSize.width * 3 + padding * 2)) / 2
            return UIEdgeInsetsMake(0, edge, 0, edge)
        case .line:
            let edge = (view.bounds.width - (cellSize.width * 2 + padding * 1)) / 2
            return UIEdgeInsetsMake(0, edge, 0, edge)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
