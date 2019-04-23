//
//  DecoratorAlphaSettingsTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 4/23/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//


import UIKit

class DecoratorAlphaSettingsTableViewCell : WatchSettingsSelectableTableViewCell {
    
    @IBOutlet var alphaFirstSlider:UISlider!
    @IBOutlet var alphaSecondSlider:UISlider!
    @IBOutlet var alphaThirdSlider:UISlider!
    let settingsTypeAlphaUpdate = "alphaUpdate"
    
    // called after a new setting should be selected ( IE a new design is loaded )
    override func chooseSetting( animated: Bool ) {
        guard let clockFaceSettings = SettingsViewController.currentClockSetting.clockFaceSettings else { return }
        if let secondHandWidth = clockFaceSettings.ringAlphas[safe: 0] {
            alphaFirstSlider.value = secondHandWidth
        } else {
            alphaFirstSlider.value = 1
        }
        if let minuteHandWidth = clockFaceSettings.ringAlphas[safe: 1] {
            alphaSecondSlider.value = minuteHandWidth
        } else {
            alphaSecondSlider.value = 1
        }
        if let hourHandWidth = clockFaceSettings.ringAlphas[safe: 2] {
            alphaThirdSlider.value = hourHandWidth
        } else {
            alphaThirdSlider.value = 1
        }
    }
    
    @IBAction func firstSliderValueDidChange ( sender: UISlider) {
        guard let clockFaceSettings = SettingsViewController.currentClockSetting.clockFaceSettings else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        let thresholdForChange:Float = 0.1
        let roundedValue = Float(round(50*sender.value)/50)
        var didChangeSetting = false
        
        //default it
        if clockFaceSettings.ringAlphas.count < 3 {
            clockFaceSettings.ringAlphas = [1,1,1]
        }
        
        if let currentVal = clockFaceSettings.ringAlphas[safe: 0] {
            if abs(roundedValue.distance(to: currentVal)) > thresholdForChange || roundedValue == sender.minimumValue || roundedValue == sender.maximumValue {
                clockFaceSettings.ringAlphas[0] = roundedValue
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
    
    @IBAction func secondSliderValueDidChange ( sender: UISlider) {
        guard let clockFaceSettings = SettingsViewController.currentClockSetting.clockFaceSettings else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        let thresholdForChange:Float = 0.1
        let roundedValue = Float(round(50*sender.value)/50)
        var didChangeSetting = false
        
        //default it
        if clockFaceSettings.ringAlphas.count < 3 {
            clockFaceSettings.ringAlphas = [1,1,1]
        }
        
        if let currentVal = clockFaceSettings.ringAlphas[safe: 1] {
            if abs(roundedValue.distance(to: currentVal)) > thresholdForChange || roundedValue == sender.minimumValue || roundedValue == sender.maximumValue{
                clockFaceSettings.ringAlphas[1] = roundedValue
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
    
    @IBAction func thirdSliderValueDidChange ( sender: UISlider) {
        guard let clockFaceSettings = SettingsViewController.currentClockSetting.clockFaceSettings else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        let thresholdForChange:Float = 0.1
        let roundedValue = Float(round(50*sender.value)/50)
        var didChangeSetting = false
        
        //default it
        if clockFaceSettings.ringAlphas.count < 3 {
            clockFaceSettings.ringAlphas = [1,1,1]
        }
        
        if let currentVal = clockFaceSettings.ringAlphas[safe: 2] {
            if abs(roundedValue.distance(to: currentVal)) > thresholdForChange || roundedValue == sender.minimumValue || roundedValue == sender.maximumValue {
                clockFaceSettings.ringAlphas[2] = roundedValue
                didChangeSetting = true
            }
        } else {
            debugPrint("WARNING: no ring alpha array index to modify")
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

