//
//  EffectsWidthSettingsTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 4/5/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//


import UIKit

class MainTransparencySettingsTableViewCell : WatchSettingsSelectableTableViewCell {
    
    @IBOutlet var clockFaceMaterialAlphaSlider:UISlider!
    @IBOutlet var clockCasingMaterialAlphaSlider:UISlider!
    @IBOutlet var clockForegroundMaterialAlphaSlider:UISlider!
    let settingsTypeAlphaUpdate = "alphaUpdateBackgrounds"
    
    // called after a new setting should be selected ( IE a new design is loaded )
    override func chooseSetting( animated: Bool ) {
        let currentClockSetting = SettingsViewController.currentClockSetting
        
        clockFaceMaterialAlphaSlider.value = currentClockSetting.clockFaceMaterialAlpha
        clockCasingMaterialAlphaSlider.value = currentClockSetting.clockCasingMaterialAlpha
        clockForegroundMaterialAlphaSlider.value = currentClockSetting.clockForegroundMaterialAlpha
    }
    
    @IBAction func sliderValueDidChange(sender: UISlider ) {
        //debugPrint("slider value:" + String( sender.value ) )
        let currentClockSetting = SettingsViewController.currentClockSetting
        
        var existingValue:Float = 0
        if sender == clockFaceMaterialAlphaSlider { existingValue=clockFaceMaterialAlphaSlider.value }
        if sender == clockCasingMaterialAlphaSlider { existingValue=clockCasingMaterialAlphaSlider.value }
        if sender == clockForegroundMaterialAlphaSlider { existingValue=clockForegroundMaterialAlphaSlider.value }
        
        let roundedValue = Float(round(50*sender.value)/50)
        if roundedValue != existingValue || roundedValue == sender.minimumValue || roundedValue == sender.maximumValue {
            //debugPrint("new value:" + String( roundedValue ) )
            //add to undo stack for actions to be able to undo
            SettingsViewController.addToUndoStack()
            
            if sender == clockFaceMaterialAlphaSlider { currentClockSetting.clockFaceMaterialAlpha = roundedValue }
            if sender == clockCasingMaterialAlphaSlider { currentClockSetting.clockCasingMaterialAlpha = roundedValue }
            if sender == clockForegroundMaterialAlphaSlider { currentClockSetting.clockForegroundMaterialAlpha = roundedValue }
        
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingsTypeAlphaUpdate])
            NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil,
                                            userInfo:["cellId": self.cellId , "settingType":settingsTypeAlphaUpdate])
        }
        
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }
//    
//    override func awakeFromNib() {
//        
//    }
    
}

