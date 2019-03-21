//
//  FaceForegroundSettingsTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 11/17/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class FaceForegroundSettingsTableViewCell: WatchSettingsSelectableTableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var faceForegroundSelectionCollectionView: UICollectionView!
    
    // called after a new setting should be selected ( IE a new design is loaded )
    override func chooseSetting( animated: Bool ) {
    
        let currentSetting = SettingsViewController.currentClockSetting.faceForegroundType
        if let typeIndex = FaceForegroundTypes.userSelectableValues.firstIndex(of: currentSetting) {
            let indexPath = IndexPath.init(row: typeIndex, section: 0)

            //scroll and set native selection
            faceForegroundSelectionCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.right)

            //stupid hack to force selection after scroll
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
                self.setCellSelection(indexPath: indexPath)
            })
        }
    }
    
    func setCellSelection( indexPath: IndexPath ) {
        //select new one
        if let settingsCell = faceForegroundSelectionCollectionView.cellForItem(at: indexPath) as? FaceForegroundSettingCollectionViewCell {
            if let scene = settingsCell.skView.scene, let selectedNode = scene.childNode(withName: "selectedNode") {
                //TODO: animate this
                selectedNode.isHidden = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let settingType = FaceForegroundTypes.userSelectableValues[indexPath.row]
        debugPrint("selected cell faceForegroundTypes: " + settingType.rawValue)
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        //update the value
        SettingsViewController.currentClockSetting.faceForegroundType = settingType
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:nil)
        NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil,
                                        userInfo:["cellId": self.cellId , "settingType":"faceForegroundType"])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let settingType = FaceForegroundTypes.userSelectableValues[indexPath.row]
        debugPrint("deSelected cell faceForegroundTypes: " + settingType.rawValue)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FaceForegroundTypes.userSelectableValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "settingsForegroundCell", for: indexPath) as! FaceForegroundSettingCollectionViewCell
        
        if cell.skView.scene == nil  {
            //first run. create a new scene
            let previewScene = SKScene.init()
            previewScene.scaleMode = .aspectFill
            
            // Present the scene
            cell.skView.presentScene(previewScene)
            cell.skView.delegate = cell
        }
        
        cell.faceForegroundType = FaceForegroundTypes.userSelectableValues[indexPath.row]
        cell.redrawScene()
        
        return cell
    }
    
    
}
