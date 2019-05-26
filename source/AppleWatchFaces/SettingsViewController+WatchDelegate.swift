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
            
            //send any images to be copied first
            let fileManager = FileManager.default
            for layer in SettingsViewController.currentFaceSetting.faceLayers {
                if layer.filenameForImage != "" {
                    
                    let backgroundImageURL = UIImage.getImageURL(imageName: layer.filenameForImage)
                    if fileManager.fileExists(atPath: backgroundImageURL.path) {
                        validSession.transferFile(backgroundImageURL, metadata: ["type":"clockFaceMaterialSync", "filename":layer.filenameForImage])
                    } else {
                        self.showError(errorMessage: "No changes to send")
                    }
                    
                }
            }

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
