//  FaceBackgroundColorSettingTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 10/29/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class FaceOverlayColorSettingTableViewCell: ColorSettingsTableViewCell {
    
    @IBOutlet var faceOverlayColorSelectionCollectionView: UICollectionView!
    
    // called after a new setting should be selected ( IE a new design is loaded )
    override func chooseSetting( animated: Bool ) {
        //debugPrint("** FaceBackgroundColorSettingTableViewCell called **" + SettingsViewController.currentClockSetting.clockFaceMaterialName)
    
        let filteredColor = colorListVersion(unfilteredColor: SettingsViewController.currentClockSetting.clockForegroundMaterialName)
        if let materialColorIndex = colorList.firstIndex(of: filteredColor) {
            let indexPath = IndexPath.init(row: materialColorIndex, section: 0)

            //scroll and set native selection
            faceOverlayColorSelectionCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.right)
        } else {
            faceOverlayColorSelectionCollectionView.deselectAll(animated: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newColor = colorList[indexPath.row]
    
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        //update the value
        SettingsViewController.currentClockSetting.clockForegroundMaterialName = newColor
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:nil)
        NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil,
                                        userInfo:["cellId": self.cellId , "settingType":"clockForegroundMaterialName"])
    }
    
}
