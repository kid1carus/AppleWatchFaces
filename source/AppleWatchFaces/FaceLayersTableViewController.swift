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
    
    func adjustLayerItem(adjustmentType: WatchFaceNode.LayerAdjustmentType, amount: CGFloat) {
        guard let selectedRow = self.tableView.indexPathForSelectedRow else { return }
        guard let settingsViewVC = settingsViewController else { return }
        
        let layerSettings = SettingsViewController.currentFaceSetting.faceLayers[selectedRow.row]
        
        func clamped (value: Float, min: Float, max: Float) -> Float {
            if value > max { return max }
            if value < min { return min }
            return value
        }
        
        var reload = false
        
        if adjustmentType == .Angle {
            let clampedVal = clamped( value: layerSettings.angleOffset + Float(amount), min: -Float.pi, max: Float.pi )
            if layerSettings.angleOffset != clampedVal {
                layerSettings.angleOffset = clampedVal
                reload = true
            }
        }
        
        if adjustmentType == .Scale {
            let clampedVal = clamped( value: layerSettings.scale + Float(amount), min: 0, max: AppUISettings.layerSettingsScaleMax )
            if layerSettings.scale != clampedVal {
                layerSettings.scale = clampedVal
                reload = true
            }
        }
        
        if adjustmentType == .Alpha {
            let clampedVal = clamped( value: layerSettings.alpha + Float(amount), min: 0, max: 1.0 )
            if layerSettings.alpha != clampedVal {
                layerSettings.alpha = clampedVal
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
    
    func nudgeItem(xDirection: CGFloat, yDirection: CGFloat) {
        guard let selectedRow = self.tableView.indexPathForSelectedRow else { return }
        guard let settingsViewVC = settingsViewController else { return }
        
        let layerSettings = SettingsViewController.currentFaceSetting.faceLayers[selectedRow.row]
        
        //set the position in the layer
        layerSettings.horizontalPosition = layerSettings.horizontalPosition + Float(xDirection)
        layerSettings.verticalPosition = layerSettings.verticalPosition + Float(yDirection)
        
        //reload
        settingsViewVC.drawUIForSelectedLayer(selectedLayer: selectedRow.row, section: .Position)
        NotificationCenter.default.post(name: WatchPreviewViewController.settingsNudgedNotificationName, object: nil,
                                        userInfo:["faceLayerIndex":selectedRow.row ])
    }

    func addNewItem( layerType: FaceLayerTypes) {
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: SettingsViewController.currentFaceSetting.faceLayers.count-1, section: 0)], with: .automatic)
        self.tableView.endUpdates()
    }
    
    func redrawPreview() {
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":"itemReorder"])
    }
    
    func reload() {
        self.tableView.reloadData()
    }
    
    @objc func onSettingsLayerSelectedNotification(notification:Notification) {
        if let data = notification.userInfo as? [String: Int], let rowIndex = data["faceLayerIndex"] {
            let selectedRow = IndexPath.init(row: rowIndex, section: 0)
            self.tableView.selectRow(at: selectedRow, animated: false, scrollPosition: .none)
            
            // animate to show new heights when selected
            tableView.beginUpdates()
            tableView.endUpdates()
            
            if let settingsVC = settingsViewController {
                settingsVC.drawUIForSelectedLayer(selectedLayer: rowIndex, section: .All)
            }
        }
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
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var cellHeight:CGFloat = 80
        
        let faceLayer = SettingsViewController.currentFaceSetting.faceLayers[indexPath.row]
        
        //if selected show
        if let selectedPath = tableView.indexPathForSelectedRow {
            //debugPrint("selectedpath:" + selectedPath.description + indexPath.description)
            if selectedPath.row == indexPath.row {
                switch faceLayer.layerType {
                case .ImageTexture:
                    cellHeight = 145.0
                case .ColorTexture:
                    cellHeight = 80.0
                case .GradientTexture:
                    cellHeight = 145.0
                case .HourHand:
                    cellHeight = 250.0
                case .MinuteHand:
                    cellHeight = 250.0
                case .SecondHand:
                    cellHeight = 250.0
                case .ShapeRing:
                    cellHeight = 220.0
                case .NumberRing:
                    cellHeight = 300.0
                case .DateTimeLabel:
                    cellHeight = 250.0
                }
            }
        }
        
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
            
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "LayerCellID", for: indexPath) as! FaceLayerTableViewCell
        }
    
        cell.parentTableview = self.tableView
        cell.setupUIForFaceLayer(faceLayer: faceLayer)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceRow = sourceIndexPath.row;
        let destRow = destinationIndexPath.row;
        
        if (sourceRow != destRow) {
            
            debugPrint("moving cells src:" + sourceRow.description + " dest:" + destRow.description)
            
            let object = SettingsViewController.currentFaceSetting.faceLayers[sourceRow]
            SettingsViewController.currentFaceSetting.faceLayers.remove(at: sourceRow)
            SettingsViewController.currentFaceSetting.faceLayers.insert(object, at: destRow)
        
            redrawPreview()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let sourceRow = indexPath.row;
            //let trashedSetting = clockSettings.ringSettings[sourceRow]
            SettingsViewController.currentFaceSetting.faceLayers.remove(at: sourceRow)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            redrawPreview()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //debugPrint("selected cell:" + indexPath.description)
        
        // animate to show new heights when selected
        tableView.beginUpdates()
        tableView.endUpdates()
        
        if let settingsVC = settingsViewController {
            settingsVC.drawUIForSelectedLayer(selectedLayer: indexPath.row, section: .All)
        }
    }

}
