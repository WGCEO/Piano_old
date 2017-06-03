//
//  ImagePicker.swift
//  Piano
//
//  Created by dalong on 2017. 6. 2..
//  Copyright © 2017년 Piano. All rights reserved.
//

import Foundation
import UIKit

// MARK: pick images
class ImagePicker: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    //앨범에서 이미지를 가져오기 위한 이미지 피커 컨트롤러
    /*
    var imagePicker: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.allowsEditing = false
        controller.sourceType = .photoLibrary
        return controller
    }()
    */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        /*
         var selectedRange = iskeyboardAlbumButtonTouched ? textView.selectedRange : NSMakeRange(textView.attributedText.length, 0)
         if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
         
         if memo == nil {
         addNewMemo()
         }
         
         //여기서 selectedRange에다가 NSTextAttachment로 붙여 넣어야 함 물론 이미지 크기 조절해서!
         var attributedString :NSMutableAttributedString!
         attributedString = NSMutableAttributedString(attributedString:textView.attributedText)
         let oldWidth = pickedImage.size.width;
         
         //I'm subtracting 10px to make the image display nicely, accounting
         //for the padding inside the textView
         let ratio = (textView.textContainer.size.width - 10) / oldWidth;
         
         let size = pickedImage.size.applying(CGAffineTransform(scaleX: ratio, y: ratio))
         UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
         pickedImage.draw(in: CGRect(origin: CGPoint.zero, size: size))
         let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         
         let textAttachment = NSTextAttachment()
         textAttachment.image = scaledImage
         let attrStringWithImage = NSAttributedString(attachment: textAttachment)
         let spaceString = NSAttributedString(string: "\n", attributes: [NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body)])
         
         attributedString.insert(attrStringWithImage, at: selectedRange.location)
         attributedString.insert(spaceString, at: selectedRange.location + 1)
         attributedString.addAttributes([NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)], range: NSMakeRange(selectedRange.location, 2))
         textView.attributedText = attributedString
         selectedRange.location += 2
         }
         updateCellInfo()
         setTextViewEditedState()
         textView.makeTappable()
         textView.selectedRange = selectedRange
         dismiss(animated: true, completion: nil)
         
         
         if iskeyboardAlbumButtonTouched {
         textView.appearKeyboard()
         iskeyboardAlbumButtonTouched = false
         }
         
         DispatchQueue.main.async { [unowned self] in
         self.textView.scrollRangeToVisible(NSMakeRange(self.textView.selectedRange.location + 3, 0))
         }
         */
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        /*
         textView.makeTappable()
         dismiss(animated: true, completion: nil)
         
         
         if iskeyboardAlbumButtonTouched {
         textView.appearKeyboard()
         iskeyboardAlbumButtonTouched = false
         }
         */
    }
    
}
