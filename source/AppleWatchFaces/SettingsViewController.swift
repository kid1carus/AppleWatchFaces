//
//  ViewController.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 10/17/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit
import WatchConnectivity

class SettingsViewController: UIViewController, WatchSessionManagerDelegate {

    @IBOutlet var undoButton: UIBarButtonItem!
    @IBOutlet var redoButton: UIBarButtonItem!
    @IBOutlet var sendSettingButton: UIButton!
    
    @IBOutlet var groupSegmentControl: UISegmentedControl!

    weak var watchPreviewViewController:WatchPreviewViewController?
    weak var watchSettingsTableViewController:WatchSettingsTableViewController?
    
    static var currentClockSetting: ClockSetting = ClockSetting.defaults()
    var currentClockIndex = 0
    static var undoArray = [ClockSetting]()
    static var redoArray = [ClockSetting]()
    
    static let settingsChangedNotificationName = Notification.Name("settingsChanged")
    static let settingsGetCameraImageNotificationName = Notification.Name("getBackgroundImageFromCamera")
    static let settingsPreviewSwipedNotificationName = Notification.Name("swipedOnPreview")
        
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
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        if parent == nil {
            if let vc = self.navigationController?.viewControllers.first as? FaceChooserViewController {
                vc.faceListReloadType = .onlyvisible
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is WatchPreviewViewController {
            let vc = segue.destination as? WatchPreviewViewController
            watchPreviewViewController = vc
        }
        if segue.destination is WatchSettingsTableViewController {
            let vc = segue.destination as? WatchSettingsTableViewController
            watchSettingsTableViewController = vc
        }
        
    }
    
    @IBAction func groupChangeAction(sender: UISegmentedControl) {
        
        if watchSettingsTableViewController != nil {
            watchSettingsTableViewController?.currentGroupIndex = sender.selectedSegmentIndex
            watchSettingsTableViewController?.reloadAfterGroupChange()
        }
    }
    
    @IBAction func sendSettingAction() {
        //debugPrint("sendSetting tapped")
        if let validSession = WatchSessionManager.sharedManager.validSession {
            
            //toggle it off to prevent spamming
            sendSettingButton.isEnabled = false
            delay(1.0) {
                self.sendSettingButton.isEnabled = true
            }
            
            //send background image
            let filename = SettingsViewController.currentClockSetting.clockFaceMaterialName
            let imageURL = UIImage.getImageURL(imageName: filename)
            let fileManager = FileManager.default
            // check if the image is stored already
            if fileManager.fileExists(atPath: imageURL.path) {
                self.showMessage( message: "Sending background image")
                validSession.transferFile(imageURL, metadata: ["type":"clockFaceMaterialImage", "filename":filename])
            }
            
            SettingsViewController.createTempTextFile()
            validSession.transferFile(SettingsViewController.attachmentURL(), metadata: ["type":"currentClockSettingFile", "filename":SettingsViewController.currentClockSetting.filename() ])
            
        } else {
            self.showError(errorMessage: "No valid watch session")
        }
    }
    
    @objc func onNotificationForSettingsChanged(notification:Notification) {
        debugPrint("onNotificationForSettingsChanged called")
        redrawPreviewClock()
        setUndoRedoButtonStatus()
    }
    
    @objc func onNotificationForGetCameraImage(notification:Notification) {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            //add to undo stack for actions to be able to undo
            SettingsViewController.addToUndoStack()
            
            /* get your image here */
            let resizedImage = AppUISettings.imageWithImage(image: image, scaledToSize: CGSize.init(width: 312, height: 390))

            // save it to the docs folder with name of the face
            let fileName = SettingsViewController.currentClockSetting.uniqueID + AppUISettings.backgroundFileName
            debugPrint("got an image!" + resizedImage.description + " filename: " + fileName)
            
            _ = resizedImage.save(imageName: fileName) //_ = resizedImage.save(imageName: fileName)
            SettingsViewController.currentClockSetting.clockFaceMaterialName = fileName
            
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:nil)
            NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil, userInfo:["settingType":"clockFaceMaterialName"])
        }
    }
    
    @objc func onNotificationForPreviewSwiped(notification:Notification) {
        
        if let userInfo = notification.userInfo as? [String: String] {
//            if userInfo["action"] == "prevClock" {
//                prevClock()
//            }
//            if userInfo["action"] == "nextClock" {
//                nextClock()
//            }
            if userInfo["action"] == "sendSetting" {
                sendSettingAction()
            }
        }
    }
    
    func redrawPreviewClock() {
        //tell preview to reload
        if watchPreviewViewController != nil {
            watchPreviewViewController?.redraw()
            //self.showMessage( message: SettingsViewController.currentClockSetting.title)
        }
    }
    
    func redrawSettingsTableAfterGroupChange() {
        if watchSettingsTableViewController != nil {
            watchSettingsTableViewController?.reloadAfterGroupChange()
        }
    }
    
    func redrawSettingsTable() {
        //tell the settings table to reload
        if watchSettingsTableViewController != nil {
            watchSettingsTableViewController?.selectCurrentSettings(animated: true)
        }
    }
    
    ////////////////
    func setUndoRedoButtonStatus() {
        debugPrint("undoArray count:" + SettingsViewController.undoArray.count.description)
        if SettingsViewController.undoArray.count>0 {
            undoButton.isEnabled = true
        } else {
            undoButton.isEnabled = false
        }
        if SettingsViewController.redoArray.count > 0 {
            redoButton.isEnabled = true
        } else {
            redoButton.isEnabled = false
        }
    }
    
    static func addToUndoStack() {
        undoArray.append(SettingsViewController.currentClockSetting.clone()!)
        redoArray = []
    }
    
    static func clearUndoStack() {
        undoArray = []
        redoArray = []
    }
    
    func clearUndoAndUpdateButtons() {
        SettingsViewController.clearUndoStack()
        setUndoRedoButtonStatus()
    }
    
    @IBAction func redo() {
        guard let lastSettings = SettingsViewController.redoArray.popLast() else { return } //current setting
        SettingsViewController.undoArray.append(SettingsViewController.currentClockSetting)
        
        SettingsViewController.currentClockSetting = lastSettings
        redrawPreviewClock() //show correct clockr
        redrawSettingsTableAfterGroupChange() //show new title
        setUndoRedoButtonStatus()
    }
    
    @IBAction func undo() {
        guard let lastSettings = SettingsViewController.undoArray.popLast() else { return } //current setting
        SettingsViewController.redoArray.append(SettingsViewController.currentClockSetting)
        
        SettingsViewController.currentClockSetting = lastSettings
        redrawPreviewClock() //show correct clockr
        redrawSettingsTableAfterGroupChange() //show new title
        setUndoRedoButtonStatus()
    }
    /////////////////
    
    @IBAction func cloneClockSettings() {
        //add a new item into the shared settings
        let oldTitle = SettingsViewController.currentClockSetting.title
        let newClockSetting = SettingsViewController.currentClockSetting.clone(keepUniqueID: false)!
        newClockSetting.title = oldTitle + " copy"
        UserClockSetting.sharedClockSettings.insert(newClockSetting, at: currentClockIndex)
        UserClockSetting.saveToFile()
        
        SettingsViewController.currentClockSetting = newClockSetting
        redrawPreviewClock() //show correct clock
        redrawSettingsTableAfterGroupChange() //show new title
        clearUndoAndUpdateButtons()
        
        showError(errorMessage: "Face copied")
        
        //tell chooser view to reload its cells
        NotificationCenter.default.post(name: FaceChooserViewController.faceChooserReloadChangeNotificationName, object: nil, userInfo:nil)
    }
    
    @IBAction func nextClock() {
        currentClockIndex = currentClockIndex + 1
        if (UserClockSetting.sharedClockSettings.count <= currentClockIndex) {
            currentClockIndex = 0
        }
        
        SettingsViewController.currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex].clone()!
        redrawPreviewClock()
        redrawSettingsTableAfterGroupChange()
        clearUndoAndUpdateButtons()
    }
    
    @IBAction func prevClock() {
        currentClockIndex = currentClockIndex - 1
        if (currentClockIndex<0) {
            currentClockIndex = UserClockSetting.sharedClockSettings.count - 1
        }
        
        SettingsViewController.currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex].clone()!
        redrawPreviewClock()
        redrawSettingsTableAfterGroupChange()
        clearUndoAndUpdateButtons()
    }
    
    func makeThumb( fileName: String) {
        makeThumb(fileName: fileName, cornerCrop: false)
    }
    
    func makeThumb( fileName: String, cornerCrop: Bool ) {
        //make thumbnail
        if let watchVC = watchPreviewViewController {
            
            if watchVC.makeThumb( imageName: fileName, cornerCrop: cornerCrop ) {
                //self.showMessage( message: "Screenshot successful.")
            } else {
                self.showError(errorMessage: "Problem creating screenshot.")
            }
            
        }
    }
    
    @IBAction func shareAll() {
        makeThumb(fileName: SettingsViewController.currentClockSetting.uniqueID)
        let activityViewController = UIActivityViewController(activityItems: [TextProvider(), ImageProvider(), BackgroundTextProvider(), BackgroundImageProvider(), AttachmentProvider()], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func saveClock() {
        //just save this clock
        UserClockSetting.sharedClockSettings[currentClockIndex] = SettingsViewController.currentClockSetting
        UserClockSetting.saveToFile() //remove this to reset to defaults each time app loads
        self.showMessage( message: SettingsViewController.currentClockSetting.title + " saved.")
        
        //makeThumb(fileName: SettingsViewController.currentClockSetting.uniqueID)
    }
    
    @IBAction func revertClock() {
        //just revert this clock
        SettingsViewController.currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex].clone()!
        redrawPreviewClock()
        redrawSettingsTableAfterGroupChange()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if (self.isMovingFromParent) {
            // moving back, if anything has changed, lets save
            if SettingsViewController.undoArray.count>0 {
                saveClock()
                _ = UIImage.delete(imageName: SettingsViewController.currentClockSetting.uniqueID)
            }
        }
        
        //TODO: probably not needed
        //force clean up memory
        if let scene = watchPreviewViewController?.skView.scene as? SKWatchScene {
            scene.cleanup()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get current selected clock
        redrawSettingsTableAfterGroupChange()
        redrawPreviewClock()
        
        setUndoRedoButtonStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WatchSessionManager.sharedManager.delegate = self
        SettingsViewController.clearUndoStack()
        
        //style the section segment
        // Add lines below selectedSegmentIndex
        groupSegmentControl.backgroundColor = .clear
        groupSegmentControl.tintColor = .clear
        
        // Add lines below the segmented control's tintColor
        groupSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 20)!,
            NSAttributedString.Key.foregroundColor: SKColor.white
            ], for: .normal)
        
        groupSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 20)!,
            NSAttributedString.Key.foregroundColor: SKColor.init(hexString: AppUISettings.settingHighlightColor)
            ], for: .selected)
        
        SettingsViewController.currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex].clone()!
        
         NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForPreviewSwiped(notification:)), name: SettingsViewController.settingsPreviewSwipedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForSettingsChanged(notification:)), name: SettingsViewController.settingsChangedNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForGetCameraImage(notification:)), name: SettingsViewController.settingsGetCameraImageNotificationName, object: nil)
    }
    
    static func attachmentURL()->URL {
        let filename = SettingsViewController.currentClockSetting.filename() + ".awf"
        return UserClockSetting.DocumentsDirectory.appendingPathComponent(filename)
    }
    static func createTempTextFile() {
        //TODO: move this to temporary file to be less cleanup later / trash on device
        //JSON save to file
        var serializedArray = [NSDictionary]()
        serializedArray.append(SettingsViewController.currentClockSetting.serializedSettings())
        //debugPrint("saving setting: ", clockSetting.title)
        UserClockSetting.saveDictToFile(serializedArray: serializedArray, pathURL: attachmentURL())
    }
    
}

class TextProvider: NSObject, UIActivityItemSource {
    
    let myWebsiteURL = NSURL(string:"https://github.com/orff/AppleWatchFaces")!.absoluteString!
    //let appName = "AppleWatchFaces on github"
    let watchFaceCreatedText = "Watch face \"" + SettingsViewController.currentClockSetting.title + "\" I created"

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return NSObject()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
    
        return watchFaceCreatedText
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        let promoText = watchFaceCreatedText + " using " + myWebsiteURL + "."
        
        //copy to clipboard for insta / FB
        UIPasteboard.general.string = promoText
        
        if activityType == .postToFacebook  {
            return nil
        }
        
        return promoText
    }
}

class AttachmentProvider: NSObject, UIActivityItemSource {
    
    
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return NSObject()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        if activityType == .postToFacebook  {
            return nil
        }
        
        SettingsViewController.createTempTextFile()
        return SettingsViewController.attachmentURL()

    }
}

class ImageProvider: NSObject, UIActivityItemSource {
    
    func getThumbImageURL() -> URL? {
        if let newImageURL = UIImage.getValidatedImageURL(imageName: SettingsViewController.currentClockSetting.uniqueID) {
            return newImageURL
        }
        return nil
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        if let newImageURL  = getThumbImageURL() {
            return newImageURL
        } else {
            return UIImage.init()
        }
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return getThumbImageURL()
    }
}

class BackgroundTextProvider: NSObject, UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return NSObject()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
//        if activityType == .postToFacebook  {
//            return nil
//        }
//        let material = SettingsViewController.currentClockSetting.clockFaceMaterialName
//        if !AppUISettings.materialIsColor(materialName: material) && UIImage.getImageFor(imageName: material) != nil {
//            return "Background and settings file attached."
//        }
//        return "Settings file attached."
    }
    
}

class BackgroundImageProvider: NSObject, UIActivityItemSource {
    
    func getBackgroundImageURL() -> URL? {
        let material = SettingsViewController.currentClockSetting.clockFaceMaterialName
        if !AppUISettings.materialIsColor(materialName: material) {
            if let newImageURL = UIImage.getValidatedImageURL(imageName: material) {
                return newImageURL
            }
        }
        return nil
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        if let newImageURL = getBackgroundImageURL() {
            return newImageURL
        } else {
            return UIImage.init()
        }
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if let newImageURL = getBackgroundImageURL() {
            return newImageURL
        } else {
            return nil
        }
    }
}
