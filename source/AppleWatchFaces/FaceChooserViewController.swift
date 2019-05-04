//
//  FaceChooserViewController.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 11/14/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit
import WatchConnectivity

enum FaceListReloadType: String {
    case none, onlyvisible, full
}

class FaceChooserViewController: UIViewController, WatchSessionManagerDelegate {
    
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
    
    
    //var session: WCSession?
    @IBOutlet var sendToWatchButton: UIButton!
    @IBOutlet var themeThumbsButton: UIButton!
    @IBOutlet var filetransferProgress: UIProgressView!
    var totalTransfers:Int = 0
    weak var faceChooserTableViewController:FaceChooserTableViewController?
    var faceListReloadType : FaceListReloadType = .none
    
    static let faceChooserReloadChangeNotificationName = Notification.Name("faceChooserReload")
    static let faceChooserRegenerateChangeNotificationName = Notification.Name("faceChooserRegenerate")
    
    @IBAction func sendAllSettingsAction(sender: UIButton) {
        //debugPrint("sendAllSettingsAction tapped")
        if let validSession = WatchSessionManager.sharedManager.validSession {
            self.showMessage(message: "Sending ...")
            
            //send any images to be copied first
            var imagesArray:[String] = []
            for clockSetting in UserClockSetting.sharedClockSettings {
                let backgroundImage = clockSetting.clockFaceMaterialName
                guard backgroundImage.count >= AppUISettings.backgroundFileName.count else { continue }
                let lastPart = backgroundImage.suffix(AppUISettings.backgroundFileName.count)
                if lastPart == AppUISettings.backgroundFileName {
                    imagesArray.append(backgroundImage)
                }
            }
            
            sendAllBackgroundImages(imagesArray: imagesArray, validSession: validSession)
            
            //send settings file
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: UserClockSetting.ArchiveURL.path) {
                validSession.transferFile(UserClockSetting.ArchiveURL, metadata: ["type":"settingsFile", "imageCount":String(imagesArray.count)])
            } else {
                self.showError(errorMessage: "No changes to send: Watch has same defaults")
            }
            
            //show progress bar
            totalTransfers = validSession.outstandingFileTransfers.count
            filetransferProgress.isHidden = false
            showfileTransferProgress()
        } else {
            self.showError(errorMessage: "No valid watch session")
        }
        
        
    }
    
    func sendAllBackgroundImages(imagesArray:[String], validSession: WCSession) {
        
        if imagesArray.count>0 {
            //show message to user
            self.showMessage(message: "Sending background images ...")
            //loop through all sending them
            let fileManager = FileManager.default
            for filename in imagesArray {
                let backgroundImageURL = UIImage.getImageURL(imageName: filename)
                if fileManager.fileExists(atPath: backgroundImageURL.path) {
                    validSession.transferFile(backgroundImageURL, metadata: ["type":"clockFaceMaterialSync", "filename":filename])
                } else {
                    self.showError(errorMessage: "No changes to send")
                }
            }
        }
        
    }
    
    func showfileTransferProgress() {
        guard let validSession = WatchSessionManager.sharedManager.validSession, totalTransfers>0 else {
            filetransferProgress.isHidden = true
            sendToWatchButton.isEnabled = true
            self.showError(errorMessage: "Lost watch session")
            return
        }
        
        let transfers = validSession.outstandingFileTransfers
        
        //exit if we have them all
        guard transfers.count>0 else {
            filetransferProgress.isHidden = true
            sendToWatchButton.isEnabled = true
            self.showMessage(message: "Background images sent")
            return
        }
        
        sendToWatchButton.isEnabled = false
        
        //TODO: eventually get fancy with file sizes / transfer progress??
        let progress = Float(Float(transfers.count) / Float(totalTransfers))
        filetransferProgress.progress = progress
        debugPrint("items queued, outstanding: " + validSession.outstandingFileTransfers.count.description + " progress: " + progress.description)
        
        //otherwise call showProgress
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            self.showfileTransferProgress()
        })
    }
    
    // array of outstanding transfers
    //validSession.outstandingFileTransfers
    
    @IBAction func addNewSettingAction(sender: UIButton) {
//        let originalCount = UserClockSetting.sharedClockSettings.count
//        UserClockSetting.addMissingFromDefaults()
//        
//        if let faceChooserTableVC  = faceChooserTableViewController  {
//            faceChooserTableVC.reloadAllThumbs() // may have deleted or insterted, so reloadData
//        }
//        let newCount = UserClockSetting.sharedClockSettings.count
//        showMessage(message: "Added from defaults, " + (newCount - originalCount).description + " added" )
//        
//        let missingThumbs = UserClockSetting.settingsWithoutThumbNails()
//        guard missingThumbs.count==0 else {
//            //first run, reload everything
//            if missingThumbs.count == UserClockSetting.sharedClockSettings.count {
//                faceListReloadType = .full
//            }
//            self.performSegue(withIdentifier: "callMissingThumbsGeneratorID", sender: nil)
//            return
//        }
    }
    
    func doResetAllAction() {
//        UserClockSetting.resetToDefaults()
//
//        AppUISettings.deleteAllFolders()
//        AppUISettings.createFolders()
//        AppUISettings.copyFolders()
//
//        faceListReloadType = .full
//
//        _ = self.shouldRegenerateThumbNailsAndExit()
//
//        self.showMessage(message: "All faces reset to defaults")
    }
    
    @IBAction func resetAllSettingAction(sender: UIButton) {
        let alert = UIAlertController(title: "Do full reset?", message: "This will remove all your custom settings.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            self.doResetAllAction()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
//    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
//        if let error = error {
//            self.showError(errorMessage: error.localizedDescription)
//        } else {
//            self.showMessage(message: "All settings sent")
//        }
//    }
    
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        //debugPrint("session activationDidCompleteWith")
//        showMessage( message: "Watch session active")
//    }
//
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        //debugPrint("session sessionDidBecomeInactive")
//        showError(errorMessage: "Watch session became inactive")
//    }
//
//    func sessionDidDeactivate(_ session: WCSession) {
//        //debugPrint("session sessionDidDeactivate")
//        showError(errorMessage: "Watch session deactivated")
//    }
    
    func showError( errorMessage: String) {
        DispatchQueue.main.async {
            self.showToast(message: errorMessage, color: UIColor.red, heightFromBottom: 170.0)
        }
    }
    
    func showMessage( message: String) {
        DispatchQueue.main.async {
            self.showToast(message: message, color: UIColor.lightGray, heightFromBottom: 170.0)
        }
    }
    
    func shouldRegenerateThumbNailsAndExit() -> Bool {
        //generate thumbs and exit if needed
        let missingThumbs = UserClockSetting.settingsWithoutThumbNails()
        if (missingThumbs.count > 0) {
            //first run, reload everything
            if missingThumbs.count == UserClockSetting.sharedClockSettings.count {
                faceListReloadType = .full
            }
            self.performSegue(withIdentifier: "callMissingThumbsGeneratorID", sender: nil)
            return true
        }
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//        let missingThemeThumbs = UserClockSetting.themesWithoutThumbNails()
//        guard missingThemeThumbs.count==0 else {
//            return
//        }
//
//        //generate thumbs and exit if needed
//        if shouldRegenerateThumbNailsAndExit() {
//            return
//        }
        
        // Set up and activate your session early here!
        WatchSessionManager.sharedManager.startSession()
        WatchSessionManager.sharedManager.delegate = self
        
        if faceListReloadType == .full {
            if let faceChooserTableVC  = faceChooserTableViewController  {
                faceChooserTableVC.reloadAllThumbs()
            }
        }
        if faceListReloadType == .onlyvisible {
            if let faceChooserTableVC  = faceChooserTableViewController  {
                faceChooserTableVC.reloadVisibleThumbs()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filetransferProgress.isHidden = true
        
        UserFaceSetting.loadFromFile()
        
        //show gen thumbs button, only in simulator and only if its turned on in AppUISettings
        #if (arch(i386) || arch(x86_64))
        if (AppUISettings.showRenderThumbsButton) {
            themeThumbsButton.isHidden = false
        }
        
        #endif
        
//        //generate theme thumbs and exit if needed
//        let missingThemeThumbs = UserClockSetting.themesWithoutThumbNails()
//        guard missingThemeThumbs.count==0 else {
//            self.performSegue(withIdentifier: "themeThumbsSegueID", sender: nil)
//            return
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForReloadChange(notification:)), name: FaceChooserViewController.faceChooserReloadChangeNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForGenerateThumbs(notification:)), name: FaceChooserViewController.faceChooserRegenerateChangeNotificationName, object: nil)
        
    }
    
    @objc func onNotificationForGenerateThumbs(notification:Notification) {
        if let faceChooserTableVC  = faceChooserTableViewController  {
            faceChooserTableVC.reloadAllThumbs()
        }
        delay(0.5) {
             _ = self.shouldRegenerateThumbNailsAndExit()
        }
    }
    
    @objc func onNotificationForReloadChange(notification:Notification) {
        if let faceChooserTableVC  = faceChooserTableViewController  {
            faceChooserTableVC.reloadAllThumbs()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "themeThumbsSegueID" {
            if let gtvc = segue.destination as? GenerateThumbnailsViewController {
                gtvc.shouldGenerateThemeThumbs = true
            }
        }
        if segue.destination is FaceChooserTableViewController {
            let vc = segue.destination as? FaceChooserTableViewController
            faceChooserTableViewController = vc
        }
        
        if segue.identifier == "chooseFacesEditSegueID" {
            if let nc = segue.destination as? UINavigationController {
                if let vc = nc.viewControllers.first as? FaceChooserEditTableViewController {
                    vc.faceChooserViewController = self
                }
            }
        }
        
        if segue.identifier == "newFaceSegueID" {
            if segue.destination is SettingsViewController {
                //add a new item into the shared settings
                let newClockSetting = ClockSetting.defaults()
                UserClockSetting.sharedClockSettings.insert(newClockSetting, at: 0)
                
                //ensure it shows the first one ( our new one )
                let vc = segue.destination as? SettingsViewController
                vc?.currentFaceIndex = 0
                //make thumb only works once the VC is fully loaded: doing it here only gets back box
                //vc?.makeThumb(fileName: SettingsViewController.currentClockSetting.uniqueID)
                
                //reload this tableView so it wont crash later trying to only show visible
                if let faceChooserTableVC  = faceChooserTableViewController  {
                    faceChooserTableVC.reloadAllThumbs()
                }
            }
        }
        
    }

}
