//
//  ViewController.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 10/17/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit

class SettingsViewController: UIViewController, WatchSessionManagerDelegate {

    @IBOutlet var layerTableContainer: UIView!
    @IBOutlet var colorsTableContainer: UIView!
    
    @IBOutlet var undoButton: UIBarButtonItem!
    @IBOutlet var redoButton: UIBarButtonItem!
    @IBOutlet var sendSettingButton: UIButton!
    
    @IBOutlet var nudgeLButton: UIButton!
    @IBOutlet var nudgeRButton: UIButton!
    @IBOutlet var nudgeUButton: UIButton!
    @IBOutlet var nudgeDButton: UIButton!
    
    @IBOutlet var posXLabel: UILabel!
    @IBOutlet var posYLabel: UILabel!
    @IBOutlet var numControlsView: UIView!
    
    @IBOutlet var alphaLessButton: UIButton!
    @IBOutlet var alphaMoreButton: UIButton!
    
    @IBOutlet var alphaLabel: UILabel!
    @IBOutlet var alphaControlsView: UIView!
    
    @IBOutlet var scaleLessButton: UIButton!
    @IBOutlet var scaleMoreButton: UIButton!
    
    @IBOutlet var scaleLabel: UILabel!
    @IBOutlet var scaleControlsView: UIView!
    
    @IBOutlet var angleLessButton: UIButton!
    @IBOutlet var angleMoreButton: UIButton!
    
    @IBOutlet var angleLabel: UILabel!
    @IBOutlet var angleControlsView: UIView!
    
    @IBOutlet var groupSegmentControl: UISegmentedControl!

    weak var watchPreviewViewController:WatchPreviewViewController?
    weak var faceLayersTableViewController:FaceLayersTableViewController?
    weak var faceColorsTableViewController:FaceColorsTableViewController?
    
    static var currentFaceSetting: FaceSetting = FaceSetting.defaults()
    var currentFaceIndex = 0
    static var undoArray = [FaceSetting]()
    static var redoArray = [FaceSetting]()
    
    static let settingsChangedNotificationName = Notification.Name("settingsChanged")
    static let settingsGetCameraImageNotificationName = Notification.Name("getBackgroundImageFromCamera")
    static let settingsPreviewSwipedNotificationName = Notification.Name("swipedOnPreview")
    static let settingsExitingNotificationName = Notification.Name("settingsExiting")
    
    @IBAction func adjustAngleForLayerItem( sender: UIButton) {
        
        var scaleAdjust:CGFloat = 0.0
        let nudgeAmt:CGFloat = CGFloat.pi / 8
        
        if sender == angleLessButton { scaleAdjust = -nudgeAmt }
        if sender == angleMoreButton { scaleAdjust = nudgeAmt }
        
        if let flTVC = faceLayersTableViewController {
            flTVC.adjustLayerItem(adjustmentType: .Angle, amount: scaleAdjust)
        }
    }
    
    @IBAction func adjustScaleForLayerItem( sender: UIButton) {
        
        var scaleAdjust:CGFloat = 0.0
        let nudgeAmt:CGFloat = 0.025
        
        if sender == scaleLessButton { scaleAdjust = -nudgeAmt }
        if sender == scaleMoreButton { scaleAdjust = nudgeAmt }
        
        if let flTVC = faceLayersTableViewController {
            flTVC.adjustLayerItem(adjustmentType: .Scale, amount: scaleAdjust)
        }
    }
    
    @IBAction func adjustAlphaForLayerItem( sender: UIButton) {
        
        var alphaAdjust:CGFloat = 0.0
        let nudgeAmt:CGFloat = 0.025
        
        if sender == alphaLessButton { alphaAdjust = -nudgeAmt }
        if sender == alphaMoreButton { alphaAdjust = nudgeAmt }
        
        if let flTVC = faceLayersTableViewController {
            flTVC.adjustLayerItem(adjustmentType: .Alpha, amount: alphaAdjust)
        }
    }
    
    @IBAction func nudgeLayerItem( sender: UIButton) {
        //TODO: set direction and turn on timer
        var xDirection:CGFloat = 0
        var yDirection:CGFloat = 0
        
        let nudgeAmt:CGFloat = 0.025
        
        if sender == nudgeLButton { xDirection = -nudgeAmt }
        if sender == nudgeRButton { xDirection = nudgeAmt }
        if sender == nudgeUButton { yDirection = nudgeAmt }
        if sender == nudgeDButton { yDirection = -nudgeAmt }
        
        if let flTVC = faceLayersTableViewController {
            flTVC.nudgeItem(xDirection: xDirection, yDirection: yDirection)
        }
    }
    
    func addNewItem( layerType: FaceLayerTypes) {
        //TODO: copy some things from last item for convenience
        
        var faceLayerOptions = FaceLayerOptions()
        if layerType == .ShapeRing {
            faceLayerOptions = ShapeLayerOptions.init(defaults: true)
        }
        
        let newLayer = FaceLayer.init(layerType: layerType, alpha: 1.0, horizontalPosition: 0, verticalPosition:0, scale: 1.0,
                                      angleOffset: 0, desiredThemeColorIndex: 0, layerOptions: faceLayerOptions)
        SettingsViewController.currentFaceSetting.faceLayers.append(newLayer)
        redrawPreviewClock()
        
        if let flVC = faceLayersTableViewController {
            flVC.addNewItem(layerType: layerType)
        }
        
    }
    
    @IBAction func newItem() {
        let optionMenu = UIAlertController(title: nil, message: "New Item", preferredStyle: .actionSheet)
        optionMenu.view.tintColor = UIColor.black
        
        for layerType in FaceLayerTypes.userSelectableValues {
            let newActionDescription = FaceLayer.descriptionForType(layerType)
            let newAction = UIAlertAction(title: newActionDescription, style: .default, handler: { action in
                self.addNewItem(layerType: layerType)
            } )
            optionMenu.addAction(newAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @objc func onNotificationForSettingsChanged(notification:Notification) {
        debugPrint("onNotificationForSettingsChanged called")
 
        redrawPreviewClock()
        setUndoRedoButtonStatus()
    }
    
    @objc func onNotificationForGetCameraImage(notification:Notification) {
//        CameraHandler.shared.showActionSheet(vc: self)
//        CameraHandler.shared.imagePickedBlock = { (image) in
//            //add to undo stack for actions to be able to undo
//            SettingsViewController.addToUndoStack()
//
//            /* get your image here */
//            let resizedImage = AppUISettings.imageWithImage(image: image, scaledToSize: CGSize.init(width: 312, height: 390))
//
//            // save it to the docs folder with name of the face
//            let fileName = SettingsViewController.currentFaceSetting.uniqueID + AppUISettings.backgroundFileName
//            debugPrint("got an image!" + resizedImage.description + " filename: " + fileName)
//
//            _ = resizedImage.save(imageName: fileName) //_ = resizedImage.save(imageName: fileName)
//            SettingsViewController.currentFaceSetting.clockFaceMaterialName = fileName
//
//            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:nil)
//            NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil, userInfo:["settingType":"clockFaceMaterialName"])
//        }
    }
    
    @objc func onNotificationForPreviewSwiped(notification:Notification) {
        
        if let userInfo = notification.userInfo as? [String: String] {
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
    
    func redrawSettingsTable() {
        if let faceLayersTableViewController = faceLayersTableViewController {
            faceLayersTableViewController.reload()
        }
        if let faceColorsTableViewController = faceColorsTableViewController {
            faceColorsTableViewController.reload()
        }
    }
    
    @IBAction func groupChangeAction(sender: UISegmentedControl) {
        //show / hide the tableViews
        
        if sender.selectedSegmentIndex == 0 { //main
            hideLayerControls()
        }
        if sender.selectedSegmentIndex == 1 { // layers
            colorsTableContainer.isHidden = true
            layerTableContainer.isHidden = false
            // reload layers because colors and other things may have changes
            if let faceLayersTableViewController = faceLayersTableViewController {
                faceLayersTableViewController.reload()
            }
        }
        if sender.selectedSegmentIndex == 2 { // colors
            hideLayerControls()
            
            colorsTableContainer.isHidden = false
            layerTableContainer.isHidden = true
        }
    }
    
    //MARK: ** draw UI **
    
    func hideLayerControls() {
        guard self.numControlsView.isHidden==false else { return }
        
        for controlsView in [numControlsView, alphaControlsView, scaleControlsView,
                             angleControlsView] {
            let controlsView = controlsView!
            controlsView.alpha = 1.0
            UIView.animate(withDuration: 0.25, animations: {
                controlsView.alpha = 0.0
            }) { (Bool) in
                controlsView.isHidden = true
            }
        }
    }
    
    func showLayerControls() {
        guard self.numControlsView.isHidden==true else { return }
        
        for controlsView in [numControlsView, alphaControlsView, scaleControlsView,
                     angleControlsView] {
                        let controlsView = controlsView!
                        controlsView.isHidden = false
                        controlsView.alpha = 0.0
                        
                        UIView.animate(withDuration: 0.25) {
                            controlsView.alpha = 1.0
                        }
        }
        
    }
    
    func drawUIForSelectedLayer(selectedLayer: Int, section: WatchFaceNode.LayerAdjustmentType) {
        let faceLayer = SettingsViewController.currentFaceSetting.faceLayers[selectedLayer]
        
        if (section == .All) {
            showLayerControls()
        }
        
        if (section == .Scale || section == .All) {
            scaleLabel.text = String(round(faceLayer.scale*1000)/1000)
        }
        
        if (section == .Angle || section == .All) {
            angleLabel.text = String(round(faceLayer.angleOffset*1000)/1000)
        }
        
        if (section == .Alpha || section == .All) {
            alphaLabel.text = String(round(faceLayer.alpha*1000)/1000)
        }
        
        if (section == .Position || section == .All) {
            posXLabel.text = String(round(faceLayer.horizontalPosition*100)/100)
            posYLabel.text = String(round(faceLayer.verticalPosition*100)/100)
        }
    }
    
    
    /////////////////
    
    @IBAction func cloneClockSettings() {
        //add a new item into the shared settings
        let oldTitle = SettingsViewController.currentFaceSetting.title
        let newClockSetting = SettingsViewController.currentFaceSetting.clone(keepUniqueID: false)!
        newClockSetting.title = oldTitle + " copy"
        UserFaceSetting.sharedFaceSettings.insert(newClockSetting, at: currentFaceIndex)
        UserFaceSetting.saveToFile()
        
        SettingsViewController.currentFaceSetting = newClockSetting
        redrawPreviewClock() //show correct clock
        redrawSettingsTable() //show new title
        clearUndoAndUpdateButtons()
        
        showError(errorMessage: "Face copied")
        
        //tell chooser view to reload its cells
        NotificationCenter.default.post(name: FaceChooserViewController.faceChooserReloadChangeNotificationName, object: nil, userInfo:nil)
    }
    
    @IBAction func nextClock() {
        currentFaceIndex = currentFaceIndex + 1
        if (UserFaceSetting.sharedFaceSettings.count <= currentFaceIndex) {
            currentFaceIndex = 0
        }
        
        SettingsViewController.currentFaceSetting = UserFaceSetting.sharedFaceSettings[currentFaceIndex].clone()!
        redrawPreviewClock()
        redrawSettingsTable()
        clearUndoAndUpdateButtons()
    }
    
    @IBAction func prevClock() {
        currentFaceIndex = currentFaceIndex - 1
        if (currentFaceIndex<0) {
            currentFaceIndex = UserFaceSetting.sharedFaceSettings.count - 1
        }
        
        SettingsViewController.currentFaceSetting = UserFaceSetting.sharedFaceSettings[currentFaceIndex].clone()!
        redrawPreviewClock()
        redrawSettingsTable()
        clearUndoAndUpdateButtons()
    }
    
    @IBAction func saveClock() {
        //just save this clock
        UserFaceSetting.sharedFaceSettings[currentFaceIndex] = SettingsViewController.currentFaceSetting
        UserFaceSetting.saveToFile() //remove this to reset to defaults each time app loads
        self.showMessage( message: SettingsViewController.currentFaceSetting.title + " saved.")
        
        //makeThumb(fileName: SettingsViewController.currentClockSetting.uniqueID)
    }
    
    //MARK: UIViewController
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
        if segue.destination is FaceLayersTableViewController {
            let vc = segue.destination as? FaceLayersTableViewController
            faceLayersTableViewController = vc
            vc?.settingsViewController = self
        }
        if segue.destination is FaceColorsTableViewController {
            let vc = segue.destination as? FaceColorsTableViewController
            faceColorsTableViewController = vc
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if (self.isMovingFromParent) {
            // moving back, if anything has changed, lets save
            //if SettingsViewController.undoArray.count>0 {
                saveClock()
                _ = UIImage.delete(imageName: SettingsViewController.currentFaceSetting.uniqueID)
                NotificationCenter.default.post(name: SettingsViewController.settingsExitingNotificationName, object: nil, userInfo:["currentFaceIndex":currentFaceIndex])
            //}
        }
        
        //TODO: probably not needed
        //force clean up memory
        if let scene = watchPreviewViewController?.skView.scene as? SKWatchScene {
            scene.cleanup()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get current selected clock
        redrawSettingsTable()
        redrawPreviewClock()
        
        setUndoRedoButtonStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WatchSessionManager.sharedManager.delegate = self
        SettingsViewController.clearUndoStack()
        
        colorsTableContainer.isHidden = true
        
        numControlsView.layer.cornerRadius = AppUISettings.watchControlsCornerRadius
        numControlsView.layer.borderWidth = AppUISettings.watchControlsWidth
        numControlsView.layer.borderColor = AppUISettings.watchControlsBorderColor
        
        alphaControlsView.layer.cornerRadius = AppUISettings.watchControlsCornerRadius
        alphaControlsView.layer.borderWidth = AppUISettings.watchControlsWidth
        alphaControlsView.layer.borderColor = AppUISettings.watchControlsBorderColor
        
        scaleControlsView.layer.cornerRadius = AppUISettings.watchControlsCornerRadius
        scaleControlsView.layer.borderWidth = AppUISettings.watchControlsWidth
        scaleControlsView.layer.borderColor = AppUISettings.watchControlsBorderColor
        
        angleControlsView.layer.cornerRadius = AppUISettings.watchControlsCornerRadius
        angleControlsView.layer.borderWidth = AppUISettings.watchControlsWidth
        angleControlsView.layer.borderColor = AppUISettings.watchControlsBorderColor
        
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
        
        SettingsViewController.currentFaceSetting = UserFaceSetting.sharedFaceSettings[currentFaceIndex].clone()!
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForPreviewSwiped(notification:)), name: SettingsViewController.settingsPreviewSwipedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForSettingsChanged(notification:)), name: SettingsViewController.settingsChangedNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForGetCameraImage(notification:)), name: SettingsViewController.settingsGetCameraImageNotificationName, object: nil)
    }
    
}

