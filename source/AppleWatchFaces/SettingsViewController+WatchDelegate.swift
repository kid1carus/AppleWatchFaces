//
//  SettingsViewController+WatchDelegate.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/17/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit
import WatchConnectivity

extension SettingsViewController {
    
    @IBAction func sendSettingAction() {
        debugPrint("sendSetting tapped")
        if let validSession = WatchSessionManager.sharedManager.validSession {

            //toggle it off to prevent spamming
            sendSettingButton.isEnabled = false
            delay(1.0) {
                self.sendSettingButton.isEnabled = true
            }

//                    //send background image
//                    let filename = SettingsViewController.currentClockSetting.clockFaceMaterialName
//                    let imageURL = UIImage.getImageURL(imageName: filename)
//                    let fileManager = FileManager.default
//                    // check if the image is stored already
//                    if fileManager.fileExists(atPath: imageURL.path) {
//                        self.showMessage( message: "Sending background image")
//                        validSession.transferFile(imageURL, metadata: ["type":"clockFaceMaterialImage", "filename":filename])
//                    }

            SettingsViewController.createTempTextFile()
            validSession.transferFile(SettingsViewController.attachmentURL(), metadata: ["type":"currentClockSettingFile", "filename":SettingsViewController.currentFaceSetting.filename() ])

        } else {
            self.showError(errorMessage: "No valid watch session")
        }
    }
    
    //WatchSessionManagerDelegate implementation
    func sessionActivationDidCompleteError(errorMessage: String) {
        showError(errorMessage: errorMessage)
    }
    
    func sessionActivationDidCompleteSuccess() {
        showMessage( message: "Watch session active")
    }
    
    func sessionDidBecomeInactive() {
        showError(errorMessage: "Watch session became inactive")
    }
    
    func sessionDidDeactivate() {
        showError(errorMessage: "Watch session did deactivate")
    }
    
    func fileTransferError(errorMessage: String) {
        self.showError(errorMessage: errorMessage)
    }
    
    func fileTransferSuccess() {
        self.showMessage(message: "All settings sent")
    }
    
    func showError( errorMessage: String) {
        DispatchQueue.main.async {
            self.showToast(message: errorMessage, color: UIColor.red)
        }
    }
    
    func showMessage( message: String) {
        DispatchQueue.main.async {
            self.showToast(message: message, color: UIColor.lightGray)
        }
    }
}
