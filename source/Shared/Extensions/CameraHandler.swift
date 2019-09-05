//
//  CameraHandler.swift
//  theappspace.com
//
//  Created by Dejan Atanasov on 26/06/2017.
//  Copyright © 2017 Dejan Atanasov. All rights reserved.
//

import Foundation
import UIKit
import Photos

class CameraHandler: NSObject{
    static let shared = CameraHandler()
    fileprivate var currentVC: UIViewController!
    
    //MARK: Internal Properties
    var imagePickedBlock: ((UIImage, URL?) -> Void)?
    
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            //myPickerController.allowsEditing = true
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    func photoLibrary()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    func askPermissions() -> Bool {
        var ret = false
        PHPhotoLibrary.requestAuthorization() { (status) -> Void in
            switch status {
            case .authorized:
                ret = true
            // as above
            case .denied, .restricted:
                ret =  false
            // as above
            case .notDetermined:
                break
            }
        }
        return ret
    }
    
    func checkPermissions() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            return true
        case .denied, .restricted :
            return false
        //handle denied status
        case .notDetermined:
            // ask for permissions
            return askPermissions()
        }
    }
    
    func showActionSheet(vc: UIViewController) {
        
        if !checkPermissions() {
            return
        }
        
        currentVC = vc
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        vc.present(actionSheet, animated: true, completion: nil)
    }
    
}




extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //originals from gallery
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            var urlToUse:URL? = nil
            if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                urlToUse = url
            }
            self.imagePickedBlock?(image, urlToUse)
            
        }
        //edited from camera
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            var urlToUse:URL? = nil
            if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                urlToUse = url
            }
            self.imagePickedBlock?(image, urlToUse)
            
        }
        
        currentVC.dismiss(animated: true, completion: nil)
    }
    
}
