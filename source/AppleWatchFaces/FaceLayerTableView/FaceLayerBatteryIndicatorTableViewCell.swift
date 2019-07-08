//
//  FaceLayerBatteryIndicatorTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 7/7/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//
import UIKit

class FaceLayerBatteryIndicatorTableViewCell: FaceLayerTableViewCell, UICollectionViewDelegate {
    
    @IBOutlet var colorSelectionCollectionView: UICollectionView!
    @IBOutlet var outlineColorSelectionCollectionView: UICollectionView!
    
    @IBOutlet var autoBatterySwitch: UISwitch!
//    @IBOutlet var typeNameLabel: UILabel!
    
    @IBOutlet var outlineWidthSlider: UISlider!
    @IBOutlet var fillPaddingSlider: UISlider!
    
    let settingTypeString = "batteryIndicator"
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? BatteryIndicatorOptions else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        if collectionView == colorSelectionCollectionView {
            layerOptions.desiredThemeColorIndexForBatteryLevel = indexPath.row
        }
        if collectionView == outlineColorSelectionCollectionView {
            layerOptions.desiredThemeColorIndexForOutline = indexPath.row
        }
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    
    @IBAction func widthSliderValueDidChange(sender: UISlider ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? BatteryIndicatorOptions else { return }
        
        let roundedValue = Float(round(1*sender.value)/1)
        if roundedValue != layerOptions.outlineWidth {
            //add to undo stack for actions to be able to undo
            SettingsViewController.addToUndoStack()
            
            self.selectThisCell()
            debugPrint("slider value:" + String( roundedValue ) )
            
            layerOptions.outlineWidth = roundedValue
            let layerIndex = myLayerIndex() ?? 0
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil,
                                            userInfo:["settingType":settingTypeString,"layerIndex":layerIndex])
        }
    }
    
    @IBAction func paddingSliderValueDidChange(sender: UISlider ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? BatteryIndicatorOptions else { return }
        
        let roundedValue = Float(round(1*sender.value)/1)
        if roundedValue != layerOptions.innerPadding {
            //add to undo stack for actions to be able to undo
            SettingsViewController.addToUndoStack()
            
            self.selectThisCell()
            debugPrint("slider value:" + String( roundedValue ) )
            
            layerOptions.innerPadding = roundedValue
            let layerIndex = myLayerIndex() ?? 0
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil,
                                            userInfo:["settingType":settingTypeString,"layerIndex":layerIndex])
        }
    }
    
    @IBAction func autoBatteryColorSwitchValueDidChange(sender: UISwitch ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? BatteryIndicatorOptions else { return }
        
        layerOptions.autoBatteryColor = sender.isOn
        
        let layerIndex = myLayerIndex() ?? 0
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil,
                                        userInfo:["settingType":settingTypeString,"layerIndex":layerIndex])
    }
    

    override func setupUIForFaceLayer(faceLayer: FaceLayer) {
        super.setupUIForFaceLayer(faceLayer: faceLayer) // needs title outlet to function
        
        outlineWidthSlider.minimumValue = AppUISettings.layerSettingsOutlineWidthMin
        outlineWidthSlider.maximumValue = AppUISettings.layerSettingsOutlineWidthMax
        
        fillPaddingSlider.minimumValue = AppUISettings.batteryIndicatorLevelPaddingMin
        fillPaddingSlider.maximumValue = AppUISettings.batteryIndicatorLevelPaddingMax
        
        redrawColorsForColorCollectionView( colorCollectionView: colorSelectionCollectionView)
        selectColorForColorCollectionView( colorCollectionView: colorSelectionCollectionView, desiredIndex: faceLayer.desiredThemeColorIndex)
        
        redrawColorsForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView)
        
        guard let layerOptions = faceLayer.layerOptions as? BatteryIndicatorOptions else { return }
        
        selectColorForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView, desiredIndex: layerOptions.desiredThemeColorIndexForOutline)
        outlineWidthSlider.value = layerOptions.outlineWidth

        autoBatterySwitch.isOn = layerOptions.autoBatteryColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
}

