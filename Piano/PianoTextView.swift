//
//  PianoTextView.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class PianoTextView: UITextView {
    
    var mode: TextViewMode = .typing
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.font = UIFont.preferredFont(forTextStyle: .body)
        self.textContainerInset = UIEdgeInsetsMake(20, 25, 0, 25)
    }
}
