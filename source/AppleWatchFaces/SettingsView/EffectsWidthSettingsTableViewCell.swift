//
//  EffectsWidthSettingsTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 4/5/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//


import UIKit

class EffectsWidthSettingsTableViewCell : WatchSettingsSelectableTableViewCell {
    
    @IBOutlet var effectWidthSecondHandSlider:UISlider!
    
    // called after a new setting should be selected ( IE a new design is loaded )
    override func chooseSetting( animated: Bool ) {
        guard let clockFaceSettings = SettingsViewController.currentClockSetting.clockFaceSettings else { return }
        if let secondHandWidth = clockFaceSettings.handEffectWidths[safe: 0] {
            effectWidthSecondHandSlider.value = secondHandWidth
        }
    }
    
    @IBAction func seconfHandWidthSliderValueDidChange ( sender: UISlider) {
        guard let clockFaceSettings = SettingsViewController.currentClockSetting.clockFaceSettings else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        let thresholdForChange:Float = 0.1
        let roundedValue = Float(round(50*sender.value)/50)
        var didChangeSetting = false
        
        //default it
        if clockFaceSettings.handEffectWidths.count < 3 {
            clockFaceSettings.handEffectWidths = [0,0,0]
        }
        
        if let currentVal = clockFaceSettings.handEffectWidths[safe: 0] {
            if abs(roundedValue.distance(to: currentVal)) > thresholdForChange || roundedValue == 0 {
                clockFaceSettings.handEffectWidths[0] = roundedValue
                didChangeSetting = true
            }
        } else {
            debugPrint("WARNING: no hand effect width array index to modify")
        }
        
        if didChangeSetting {
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:nil)
            NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil,
                                            userInfo:["cellId": self.cellId , "settingType":"shouldShowHandOutlines"])
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func awakeFromNib() {
        effectWidthSecondHandSlider.minimumValue = AppUISettings.handEffectSettigsSliderSpacerMin
        effectWidthSecondHandSlider.maximumValue = AppUISettings.handEffectSettigsSliderSpacerMax
    }
    
}

