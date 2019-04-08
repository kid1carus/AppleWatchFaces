//
//  EffectsWidthSettingsTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 4/5/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//


import UIKit

class FaceForegroundOptionSettingsTableViewCell : WatchSettingsSelectableTableViewCell {
    
    @IBOutlet var fieldTypeSegment:UISegmentedControl!
    @IBOutlet var shapeTypeSegment:UISegmentedControl!
    @IBOutlet var itemSizeSlider:UISlider!
    
    // called after a new setting should be selected ( IE a new design is loaded )
    override func chooseSetting( animated: Bool ) {
        guard let clockOverlaySettings = SettingsViewController.currentClockSetting.clockOverlaySettings else { return }
        
        itemSizeSlider.value = clockOverlaySettings.itemSize
        
        if let segmentIndex = OverlayShapeTypes.userSelectableValues.index(of: clockOverlaySettings.shapeType) {
            shapeTypeSegment.selectedSegmentIndex = segmentIndex
        }
        
        if let typeSegmentIndex = PhysicsFieldTypes.userSelectableValues.index(of: clockOverlaySettings.fieldType) {
            fieldTypeSegment.selectedSegmentIndex = typeSegmentIndex
        }
       
    }
    
    @IBAction func itemSizeSliderValueDidChange(sender: UISlider ) {
        //debugPrint("slider value:" + String( sender.value ) )
        guard let clockOverlaySettings = SettingsViewController.currentClockSetting.clockOverlaySettings else { return }
        
        let roundedValue = Float(round(50*sender.value)/50)
        if roundedValue != clockOverlaySettings.itemSize {
            //debugPrint("new value:" + String( roundedValue ) )
            //add to undo stack for actions to be able to undo
            SettingsViewController.addToUndoStack()
            
            clockOverlaySettings.itemSize = roundedValue
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:nil)
            NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil,
                                            userInfo:["cellId": self.cellId , "settingType":"faceForegroundOption"])
        }
        
    }
    
    @IBAction func typeSegmentValueDidChange ( sender: UISegmentedControl) {
        guard let clockOverlaySettings = SettingsViewController.currentClockSetting.clockOverlaySettings else { return }
        
        clockOverlaySettings.fieldType = PhysicsFieldTypes.userSelectableValues[sender.selectedSegmentIndex]
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:nil)
        NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil,
                                        userInfo:["cellId": self.cellId , "settingType":"faceForegroundOption"])
    }
    
    @IBAction func shapeSegmentValueDidChange ( sender: UISegmentedControl) {
        guard let clockOverlaySettings = SettingsViewController.currentClockSetting.clockOverlaySettings else { return }
        
        clockOverlaySettings.shapeType = OverlayShapeTypes.userSelectableValues[sender.selectedSegmentIndex]
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:nil)
        NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil,
                                            userInfo:["cellId": self.cellId , "settingType":"faceForegroundOption"])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func awakeFromNib() {
        
        itemSizeSlider.minimumValue = AppUISettings.foregroundItemSizeSettingsSliderSpacerMin
        itemSizeSlider.maximumValue = AppUISettings.foregroundItemSizeSettingsSliderSpacerMax
        
        //set up segment
        shapeTypeSegment.removeAllSegments()
        for (index, description) in ClockOverlaySetting.overlayShapeTypeDescriptions().enumerated() {
            shapeTypeSegment.insertSegment(withTitle: description, at: index, animated: false)
        }
        
        fieldTypeSegment.removeAllSegments()
        for (index, description) in FaceForegroundNode.physicFieldsTypeDescriptions().enumerated() {
            fieldTypeSegment.insertSegment(withTitle: description, at: index, animated: false)
        }
        
//        effectWidthSecondHandSlider.minimumValue = AppUISettings.handEffectSettigsSliderSpacerMin
//        effectWidthSecondHandSlider.maximumValue = AppUISettings.handEffectSettigsSliderSpacerMax
//
    }
    
}

