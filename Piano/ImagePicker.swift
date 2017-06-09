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
    private static var sharedInstace: ImagePicker = {
        return ImagePicker()
    }()
    
    var handler: ((UIImage?) -> Void)?
    
    private override init() {
        super.init()
    }
    
    class func pickImage(handler: ((UIImage?) -> Void)?) {
        sharedInstace.handler = handler
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = sharedInstace
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .photoLibrary
        
        AppNavigator.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        handler?(image)
        
        self.handler = nil
    }
    
    /*
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
    */
    
}
