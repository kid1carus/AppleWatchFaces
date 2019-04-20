//
//  EffectsWidthSettingsTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 4/5/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//


import UIKit

class HandAlphaSettingsTableViewCell : WatchSettingsSelectableTableViewCell {
    
    @IBOutlet var alphaSecondHandSlider:UISlider!
    @IBOutlet var alphaMinuteHandSlider:UISlider!
    @IBOutlet var alphaHourHandSlider:UISlider!
    let settingsTypeAlphaUpdate = "alphaUpdate"
    
    // called after a new setting should be selected ( IE a new design is loaded )
    override func chooseSetting( animated: Bool ) {
        guard let clockFaceSettings = SettingsViewController.currentClockSetting.clockFaceSettings else { return }
        if let secondHandWidth = clockFaceSettings.handAlphas[safe: 0] {
            alphaSecondHandSlider.value = secondHandWidth
        } else {
            alphaSecondHandSlider.value = 1
        }
        if let minuteHandWidth = clockFaceSettings.handAlphas[safe: 1] {
            alphaMinuteHandSlider.value = minuteHandWidth
        } else {
            alphaMinuteHandSlider.value = 1
        }
        if let hourHandWidth = clockFaceSettings.handAlphas[safe: 2] {
            alphaHourHandSlider.value = hourHandWidth
        } else {
            alphaHourHandSlider.value = 1
        }
    }
    
    @IBAction func secondHandWidthSliderValueDidChange ( sender: UISlider) {
        guard let clockFaceSettings = SettingsViewController.currentClockSetting.clockFaceSettings else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        let thresholdForChange:Float = 0.1
        let roundedValue = Float(round(50*sender.value)/50)
        var didChangeSetting = false
        
        //default it
        if clockFaceSettings.handAlphas.count < 3 {
            clockFaceSettings.handAlphas = [1,1,1]
        }
        
        if let currentVal = clockFaceSettings.handAlphas[safe: 0] {
            if abs(roundedValue.distance(to: currentVal)) > thresholdForChange || roundedValue == sender.minimumValue || roundedValue == sender.maximumValue {
                clockFaceSettings.handAlphas[0] = roundedValue
                didChangeSetting = true
            }
        } else {
            debugPrint("WARNING: no hand alpha array index to modify")
        }
        
        if didChangeSetting {
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingsTypeAlphaUpdate])
            NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil,
                                            userInfo:["cellId": self.cellId , "settingType":"alphaUpdate"])
        }
    }
    
    @IBAction func minuteHandWidthSliderValueDidChange ( sender: UISlider) {
        guard let clockFaceSettings = SettingsViewController.currentClockSetting.clockFaceSettings else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        let thresholdForChange:Float = 0.1
        let roundedValue = Float(round(50*sender.value)/50)
        var didChangeSetting = false
        
        //default it
        if clockFaceSettings.handAlphas.count < 3 {
            clockFaceSettings.handAlphas = [1,1,1]
        }
        
        if let currentVal = clockFaceSettings.handAlphas[safe: 1] {
            if abs(roundedValue.distance(to: currentVal)) > thresholdForChange || roundedValue == sender.minimumValue || roundedValue == sender.maximumValue{
                clockFaceSettings.handAlphas[1] = roundedValue
                didChangeSetting = true
            }
        } else {
            debugPrint("WARNING: no hand alpha array index to modify")
        }
        
        if didChangeSetting {
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingsTypeAlphaUpdate])
            NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil,
                                            userInfo:["cellId": self.cellId , "settingType":"alphaUpdate"])
        }
    }
    
    @IBAction func hourHandWidthSliderValueDidChange ( sender: UISlider) {
        guard let clockFaceSettings = SettingsViewController.currentClockSetting.clockFaceSettings else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        let thresholdForChange:Float = 0.1
        let roundedValue = Float(round(50*sender.value)/50)
        var didChangeSetting = false
        
        //default it
        if clockFaceSettings.handAlphas.count < 3 {
            clockFaceSettings.handAlphas = [1,1,1]
        }
        
        if let currentVal = clockFaceSettings.handAlphas[safe: 2] {
            if abs(roundedValue.distance(to: currentVal)) > thresholdForChange || roundedValue == sender.minimumValue || roundedValue == sender.maximumValue {
                clockFaceSettings.handAlphas[2] = roundedValue
                didChangeSetting = true
            }
        } else {
            debugPrint("WARNING: no hand alpha array index to modify")
        }
        
        if didChangeSetting {
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingsTypeAlphaUpdate])
            NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil,
                                            userInfo:["cellId": self.cellId , "settingType":"alphaUpdate"])
        }
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//    override func awakeFromNib() {
//    }
    
}

