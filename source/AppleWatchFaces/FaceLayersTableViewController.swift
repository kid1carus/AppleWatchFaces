//
//  FaceLayersTableViewController.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/4/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit

class FaceLayersTableViewController: UITableViewController {
    
    weak var settingsViewController:SettingsViewController?
    
    static let reloadLayerNotificationName = Notification.Name("reloadLayer")
    
    func sizeFromPreviewView( scale: CGFloat, reload: Bool) {
        guard let selectedRow = self.tableView.indexPathForSelectedRow else { return }
        guard let settingsViewVC = settingsViewController else { return }
        
        let layerSettings = SettingsViewController.currentFaceSetting.faceLayers[selectedRow.row]
        
        //debugPrint("pinch scale: " + scale.description)
        
        let clampedVal = clamped( value: layerSettings.scale * Float(scale), min: 0, max: AppUISettings.layerSettingsScaleMax )
        if layerSettings.scale != clampedVal {
            //add to undo stack for actions to be able to undo
            SettingsViewController.addToUndoStack()
            settingsViewVC.setUndoRedoButtonStatus()
            
            layerSettings.scale = clampedVal
            //draw labels in settings view
            settingsViewVC.drawUIForSelectedLayer(selectedLayer: selectedRow.row, section: .Scale)
            //tell preview to redraw a layer
            NotificationCenter.default.post(name: WatchPreviewViewController.settingsLayerAdjustNotificationName, object: nil,
                                            userInfo:["faceLayerIndex":selectedRow.row, "adjustmentType": WatchFaceNode.LayerAdjustmentType.Scale.rawValue])
        }
    }
    
    func dragOnPreviewView( absoluteX: CGFloat, absoluteY: CGFloat, reload: Bool) {
        nudgeItem(xDirection: 0, yDirection: 0, absoluteX: absoluteX, absoluteY: absoluteY)
    }
    
    func adjustLayerItem(adjustmentType: WatchFaceNode.LayerAdjustmentType, amount: CGFloat) {
        guard let selectedRow = self.tableView.indexPathForSelectedRow else { return }
        guard let settingsViewVC = settingsViewController else { return }
        
        let layerSettings = SettingsViewController.currentFaceSetting.faceLayers[selectedRow.row]
        
        var reload = false
        
        if adjustmentType == .Angle {
            let clampedVal = clamped( value: layerSettings.angleOffset + Float(amount), min: -Float.pi, max: Float.pi )
            if layerSettings.angleOffset != clampedVal {
                //add to undo stack for actions to be able to undo
                SettingsViewController.addToUndoStack()
                settingsViewVC.setUndoRedoButtonStatus()
                
                layerSettings.angleOffset = MathFunctions.snapToGrid(valueToSnap: clampedVal, gridSize: Float(AppUISettings.layerSettingsAngleIncrement))
                reload = true
            }
        }
        
        if adjustmentType == .Scale {
            let clampedVal = clamped( value: layerSettings.scale + Float(amount), min: 0, max: AppUISettings.layerSettingsScaleMax )
            if layerSettings.scale != clampedVal {
                //add to undo stack for actions to be able to undo
                SettingsViewController.addToUndoStack()
                settingsViewVC.setUndoRedoButtonStatus()
                
                layerSettings.scale = MathFunctions.snapToGrid(valueToSnap: clampedVal, gridSize: AppUISettings.layerSettingsScaleIncrement)
                reload = true
            }
        }
        
        if adjustmentType == .Alpha {
            let clampedVal = clamped( value: layerSettings.alpha + Float(amount), min: 0, max: 1.0 )
            if layerSettings.alpha != clampedVal {
                //add to undo stack for actions to be able to undo
                SettingsViewController.addToUndoStack()
                settingsViewVC.setUndoRedoButtonStatus()
                
                layerSettings.alpha = MathFunctions.snapToGrid(valueToSnap: clampedVal, gridSize: AppUISettings.layerSettingsAlphaIncrement)
                reload = true
            }
        }
        
        //exit if no reload
        guard reload == true else { return }
        
        //draw labels in settings view
        settingsViewVC.drawUIForSelectedLayer(selectedLayer: selectedRow.row, section: adjustmentType)
        //tell preview to redraw a layer
        NotificationCenter.default.post(name: WatchPreviewViewController.settingsLayerAdjustNotificationName, object: nil,
                                        userInfo:["faceLayerIndex":selectedRow.row, "adjustmentType": adjustmentType.rawValue])
    }
    
 
    func nudgeItem(xDirection: CGFloat, yDirection: CGFloat, absoluteX: CGFloat, absoluteY: CGFloat) {
        guard let selectedRow = self.tableView.indexPathForSelectedRow else { return }
        guard let settingsViewVC = settingsViewController else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        settingsViewVC.setUndoRedoButtonStatus()
        
        let layerSettings = SettingsViewController.currentFaceSetting.faceLayers[selectedRow.row]
        
        //set the position in the layer
        if absoluteX == 0 {
            let newPos = layerSettings.horizontalPosition + Float(xDirection)
            layerSettings.horizontalPosition = MathFunctions.snapToGrid(valueToSnap: newPos, gridSize: AppUISettings.layerSettingsPositionIncrement)
        } else {
            layerSettings.horizontalPosition = Float(absoluteX)
        }
        if absoluteY == 0 {
            let newPos = layerSettings.verticalPosition + Float(yDirection)
            layerSettings.verticalPosition = MathFunctions.snapToGrid(valueToSnap: newPos, gridSize: AppUISettings.layerSettingsPositionIncrement)
        } else {
            layerSettings.verticalPosition = Float(absoluteY)
        }
        
        //reload
        settingsViewVC.drawUIForSelectedLayer(selectedLayer: selectedRow.row, section: .Position)
        NotificationCenter.default.post(name: WatchPreviewViewController.settingsNudgedNotificationName, object: nil,
                                        userInfo:["faceLayerIndex":selectedRow.row ])
    }

    func addNewItem( layerType: FaceLayerTypes) {
        let indexPath = IndexPath(row: SettingsViewController.currentFaceSetting.faceLayers.count-1, section: 0)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
        
        delay(0.1) {
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        }
        
        delay(0.3) {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    
    }
    
    func redrawPreview() {
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":"itemReorder"])
    }
    
    func reload() {
        self.tableView.reloadData()
    }
    
    @objc func onSettingsLayerSelectedNotification(notification:Notification) {
        //ignore this if layers isnt selected
        guard let settingsVC = settingsViewController else { return }
        guard settingsVC.isLayersSelected() else { return }
        
        
        if let data = notification.userInfo as? [String: Int], let rowIndex = data["faceLayerIndex"] {
            let selectedRow = IndexPath.init(row: rowIndex, section: 0)
            
            self.tableView.selectRow(at: selectedRow, animated: true, scrollPosition: .top)
            
            //TODO: this is the one thats crashing, tested commenting the beginupdates after delay 6/16/19
            //  -- try checking for row cell before selecting if it keeps crashing here?
//            delay(0.35) {
//                // animate to show new heights when selected
//                self.tableView.beginUpdates()
//                self.tableView.endUpdates()
//            }
    
            if let settingsVC = settingsViewController {
                settingsVC.drawUIForSelectedLayer(selectedLayer: rowIndex, section: .All)
            }
        }
    }
    
    @objc func onReloadLayerNotification(notification:Notification) {
        guard let data = notification.userInfo as? [String: Int] else { return }
        guard let layerIndex = data["layerIndex"] else { return }
        
        self.tableView.reloadRows(at: [IndexPath.init(row: layerIndex, section: 0)], with: UITableView.RowAnimation.automatic)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //important only select one at a time
        self.tableView.allowsMultipleSelection = false
        self.tableView.allowsSelectionDuringEditing = true
        self.setEditing(true, animated: true)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSettingsLayerSelectedNotification(notification:)),
                                               name: WatchPreviewViewController.settingsSelectedLayerNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReloadLayerNotification(notification:)), name: FaceLayersTableViewController.reloadLayerNotificationName, object: nil)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var cellHeight:CGFloat = 80
        
        let faceLayer = SettingsViewController.currentFaceSetting.faceLayers[indexPath.row]
        
        //this was showing small versions of cells before I edited it out ( was causing too many selection and scroling issues
        
        //if selected show
        //if let selectedPath = tableView.indexPathForSelectedRow {
            //debugPrint("selectedpath:" + selectedPath.description + indexPath.description)
            //if selectedPath.row == indexPath.row {
                switch faceLayer.layerType {
                case .Gear:
                    cellHeight = 230.0
                case .ImageTexture:
                    cellHeight = 225.0
                case .ColorTexture:
                    cellHeight = 105.0
                case .GradientTexture:
                    cellHeight = 145.0
                case .HourHand:
                    cellHeight = 220.0
                case .MinuteHand:
                    cellHeight = 250.0
                case .SecondHand:
                    cellHeight = 290.0
                case .ShapeRing:
                    cellHeight = 255.0
                case .NumberRing:
                    cellHeight = 335.0
                case .DateTimeLabel:
                    cellHeight = 285.0
                case .ParticleField:
                    cellHeight = 180.0
                }
            //}
        //}
        
        return cellHeight
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return SettingsViewController.currentFaceSetting.faceLayers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = FaceLayerTableViewCell()
        
        let faceLayer = SettingsViewController.currentFaceSetting.faceLayers[indexPath.row]
        
        
        if (faceLayer.layerType == .ShapeRing) {
            cell = tableView.dequeueReusableCell(withIdentifier: "faceLayerShapeID", for: indexPath) as! FaceLayerShapeTableViewCell
        }
        else if (faceLayer.layerType == .NumberRing) {
            cell = tableView.dequeueReusableCell(withIdentifier: "faceLayerNumbersID", for: indexPath) as! FaceLayerNumberRingTableViewCell
        }
        else if (faceLayer.layerType == .DateTimeLabel) {
            cell = tableView.dequeueReusableCell(withIdentifier: "decoratorEditorDigitalTimeID", for: indexPath) as! FaceLayerDateTimeLabelTableViewCell
        }
        else if (faceLayer.layerType == .SecondHand) || (faceLayer.layerType == .MinuteHand) || (faceLayer.layerType == .HourHand) {
            cell = tableView.dequeueReusableCell(withIdentifier: "faceLayerHandID", for: indexPath) as! FaceLayerHandTableViewCell
        }
        else if (faceLayer.layerType == .ColorTexture) {
            cell = tableView.dequeueReusableCell(withIdentifier: "faceLayerColorBackgroundID", for: indexPath) as! FaceLayerColorBackgroundTableViewCell
        }
        else if (faceLayer.layerType == .GradientTexture) {
            cell = tableView.dequeueReusableCell(withIdentifier: "faceLayerGradientCellID", for: indexPath) as! FaceLayerGradientBackgroundTableViewCell
        }
        else if (faceLayer.layerType == .ImageTexture) {
            cell = tableView.dequeueReusableCell(withIdentifier: "faceLayerImageCellID", for: indexPath) as! FaceLayerImageBackgroundTableViewCell
        }
        else if (faceLayer.layerType == .Gear) {
            cell = tableView.dequeueReusableCell(withIdentifier: "faceLayerGearID", for: indexPath) as! FaceLayerGearTableViewCell
        }
        else if (faceLayer.layerType == .ParticleField) {
            cell = tableView.dequeueReusableCell(withIdentifier: "faceLayerFieldID", for: indexPath) as! FaceLayerFieldTableViewCell
        }
            
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "LayerCellID", for: indexPath) as! FaceLayerTableViewCell
        }
    
        cell.parentTableview = self.tableView
        cell.setupUIForFaceLayer(faceLayer: faceLayer)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let settingsViewVC = settingsViewController else { return }
        
        let sourceRow = sourceIndexPath.row;
        let destRow = destinationIndexPath.row;
        
        if (sourceRow != destRow) {
            
            SettingsViewController.addToUndoStack()
            settingsViewVC.setUndoRedoButtonStatus()
            debugPrint("moving cells src:" + sourceRow.description + " dest:" + destRow.description)
            
            let object = SettingsViewController.currentFaceSetting.faceLayers[sourceRow]
            SettingsViewController.currentFaceSetting.faceLayers.remove(at: sourceRow)
            SettingsViewController.currentFaceSetting.faceLayers.insert(object, at: destRow)
        
            redrawPreview()
            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let settingsViewVC = settingsViewController else { return }
            SettingsViewController.addToUndoStack()
            settingsViewVC.hideLayerControls()
            settingsViewVC.setUndoRedoButtonStatus()
            
            let sourceRow = indexPath.row;
            //let trashedSetting = clockSettings.ringSettings[sourceRow]
            SettingsViewController.currentFaceSetting.faceLayers.remove(at: sourceRow)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            redrawPreview()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //debugPrint("selected cell:" + indexPath.description)
        
//        // animate to show new heights when selected
//        tableView.beginUpdates()
//        tableView.endUpdates()
        
        
        if let settingsVC = settingsViewController {
            //show layer in preview
            settingsVC.highlightLayer(index: indexPath.row)
            //draw layer options UI
            settingsVC.drawUIForSelectedLayer(selectedLayer: indexPath.row, section: .All)
        }
    }
    
    func clamped (value: Float, min: Float, max: Float) -> Float {
        if value > max { return max }
        if value < min { return min }
        return value
    }

}
