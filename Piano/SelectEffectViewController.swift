//
//  SelectEffectViewController.swift
//  Piano
//
//  Created by kevin on 2016. 12. 27..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class SelectEffectViewController: UIViewController {
    
    //TODO: 코어데이터에서 불러와야함
    weak var selectedButton: EffectButton!
    
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
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension SelectEffectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextEffectCell.reuseIdentifier, for: indexPath) as! TextEffectCell

        let data = dataSource[indexPath.item]
        cell.textEffect = data
        //TODO: 일단 경우에 따라 다르므로 바꿔야함
        
        switch data {
        case .color(let x):
            cell.awesomeLabel.text = "\u{f031}"
            cell.awesomeLabel.textColor = x
        case .title(let x):
            cell.awesomeLabel.text = "\u{f1dc} + \(x._rawValue)"
            cell.awesomeLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
        case .line(let x):
            cell.awesomeLabel.text = "\u{f0cc} + \(x.hashValue)"
            cell.awesomeLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
        
        //TODO: 여기서 뷰컨트롤러 해제함과 동시에 값 돌려줘야함(함수 호출해서 돌려주기)

        //didSet적용해줘야함
        selectedButton.textEffect = cell.textEffect
        dismiss(animated: true, completion: nil)
    }
}

extension SelectEffectViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
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
}
