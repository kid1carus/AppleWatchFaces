//
//  FaceLayersTableViewController.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/4/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit

class FaceLayersTableViewController: UITableViewController {
    
    func nudgeItem(xDirection: CGFloat, yDirection: CGFloat) {
        guard let selectedRow = self.tableView.indexPathForSelectedRow else { return }
        
        let layerSettings = SettingsViewController.currentFaceSetting.faceLayers[selectedRow.row]
        
        //set the position in the layer
        layerSettings.horizontalPosition = layerSettings.horizontalPosition + Float(xDirection)
        layerSettings.verticalPosition = layerSettings.verticalPosition + Float(yDirection)
        
        //reload
        NotificationCenter.default.post(name: WatchPreviewViewController.settingsNudgedNotificationName, object: nil,
                                        userInfo:["faceLayerIndex":selectedRow.row ])
    }
    
    func alphaAdjustItem( alphaAdjust: CGFloat) {
        guard let selectedRow = self.tableView.indexPathForSelectedRow else { return }
        let layerSettings = SettingsViewController.currentFaceSetting.faceLayers[selectedRow.row]
        
        //clamp to 0 - 1.0
        guard layerSettings.alpha+Float(alphaAdjust) >= 0 else { return }
        guard layerSettings.alpha+Float(alphaAdjust) <= 1.0 else { return }
        
        //set the position in the layer
        layerSettings.alpha += Float(alphaAdjust)
        
        //reload
        NotificationCenter.default.post(name: WatchPreviewViewController.settingsAlphaAdjustNotificationName, object: nil,
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
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var cellHeight:CGFloat = 68
        
        let faceLayer = SettingsViewController.currentFaceSetting.faceLayers[indexPath.row]
        
        //if selected show
        if let selectedPath = tableView.indexPathForSelectedRow {
            //debugPrint("selectedpath:" + selectedPath.description + indexPath.description)
            if selectedPath.row == indexPath.row {
                switch faceLayer.layerType {
                case .ImageTexture:
                    cellHeight = 270.0
                case .ColorTexture:
                    cellHeight = 270.0
                case .GradientTexture:
                    cellHeight = 270.0
                case .HourHand:
                    cellHeight = 160.0
                case .MinuteHand:
                    cellHeight = 290.0
                case .SecondHand:
                    cellHeight = 160.0
                case .ShapeRing:
                    cellHeight = 290.0
                case .NumberRing:
                    cellHeight = 160.0
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
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "LayerCellID", for: indexPath) as! FaceLayerTableViewCell
        }
    
        cell.setupUIForFaceLayer(faceLayer: faceLayer)
        cell.parentTableview = self.tableView
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceRow = sourceIndexPath.row;
        let destRow = destinationIndexPath.row;
        
            let object = SettingsViewController.currentFaceSetting.faceLayers[sourceRow]
            SettingsViewController.currentFaceSetting.faceLayers.remove(at: sourceRow)
            SettingsViewController.currentFaceSetting.faceLayers.insert(object, at: destRow)
        
        redrawPreview()
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
    }

}
