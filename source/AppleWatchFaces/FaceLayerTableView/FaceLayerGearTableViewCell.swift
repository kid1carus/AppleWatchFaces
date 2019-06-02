//
//  FaceLayerGearTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/11/19.
//  Copyright © 2019 Michael Hill. All rights reserved.

import UIKit

class FaceLayerGearTableViewCell: FaceLayerTableViewCell, UICollectionViewDelegate {
    
    @IBOutlet var colorSelectionCollectionView: UICollectionView!
    @IBOutlet var outlineColorSelectionCollectionView: UICollectionView!
    
    @IBOutlet var typeButton: UIButton!
    @IBOutlet var typeNameLabel: UILabel!
    
    @IBOutlet var outlineWidthSlider: UISlider!
    //@IBOutlet var effectSlider: UISlider!
    
    @IBOutlet var rotationSpeedFaster: UIButton!
    @IBOutlet var rotationSpeedLower: UIButton!
    @IBOutlet var rotationSpeedLabel: UILabel!
    
    let settingTypeString = "gear"
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let faceLayer = myFaceLayer()
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        if collectionView == colorSelectionCollectionView {
            faceLayer.desiredThemeColorIndex = indexPath.row
        }
        if collectionView == outlineColorSelectionCollectionView {
            guard let layerOptions = faceLayer.layerOptions as? GearLayerOptions else { return }
            layerOptions.desiredThemeColorIndexForOutline = indexPath.row
        }
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    override func returnFromAction( actionName: String, itemChosen: Int) {
        let faceLayer = myFaceLayer()
    
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        if actionName == "chooseTypeAction" {
            if myFaceLayer().layerType == .Gear {
                guard let layerOptions = faceLayer.layerOptions as? GearLayerOptions else { return }
                layerOptions.gearType = GearTypes.userSelectableValues[itemChosen]
                typeNameLabel.text = GearNode.descriptionForType(layerOptions.gearType)
            }
        }
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
        //debugPrint("returnFromAction action:" + actionName + " item: " + itemChosen.description)
    }
    
    @IBAction func buttonTapped( sender: UIButton ) {
        SettingsViewController.actionCell = self
        if sender == typeButton {
            
            SettingsViewController.actionsArray = GearNode.typeDescriptions()
            SettingsViewController.actionCellMedthodName = "chooseTypeAction"
            SettingsViewController.actionsTitle = "Choose Type"
        }
        
        NotificationCenter.default.post(name: SettingsViewController.settingsCallActionSheet, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    @IBAction func widthSliderValueDidChange(sender: UISlider ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? GearLayerOptions else { return }
        
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
    
//    @IBAction func effectSliderValueDidChange(sender: UISlider ) {
//        let faceLayer = myFaceLayer()
//        guard let layerOptions = faceLayer.layerOptions as? GearLayerOptions else { return }
//
//        let roundedValue = Float(round(50*sender.value)/50)
//        if roundedValue != layerOptions.effectsStrength {
//            //add to undo stack for actions to be able to undo
//            SettingsViewController.addToUndoStack()
//
//            self.selectThisCell()
//            debugPrint("slider value:" + String( roundedValue ) )
//            layerOptions.effectsStrength = roundedValue
//            let layerIndex = myLayerIndex() ?? 0
//            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil,
//                                            userInfo:["settingType":settingTypeString,"layerIndex":layerIndex])
//        }
//    }
    
    @IBAction func speedButtonPressed(sender: UIButton) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? GearLayerOptions else { return }
        
        let valueToAdd:Float = 0.1
        let originalSpeed = layerOptions.anglePerSec
        var newSpeed = originalSpeed
        
        func roundedValue(val:Float) -> Float {
            return Float(round(50*val)/50)
        }
        if sender == rotationSpeedLower {
            if roundedValue(val: originalSpeed - valueToAdd) > AppUISettings.imageRotationSpeedSettigsSliderMin {
                newSpeed = roundedValue(val: originalSpeed - valueToAdd)
            } else {
                newSpeed = AppUISettings.imageRotationSpeedSettigsSliderMin
            }
        }
        if sender == rotationSpeedFaster {
            if roundedValue(val: originalSpeed + valueToAdd) < AppUISettings.imageRotationSpeedSettigsSliderMax {
                newSpeed = roundedValue(val: originalSpeed + valueToAdd)
            } else {
                newSpeed = AppUISettings.imageRotationSpeedSettigsSliderMax
            }
        }
        
        if (newSpeed != originalSpeed) {
            //add to undo stack for actions to be able to undo
            SettingsViewController.addToUndoStack()
            
            layerOptions.anglePerSec = newSpeed
            rotationSpeedLabel.text = String(layerOptions.anglePerSec)
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
        }
    }
    
    override func setupUIForFaceLayer(faceLayer: FaceLayer) {
        super.setupUIForFaceLayer(faceLayer: faceLayer) // needs title outlet to function
        
        outlineWidthSlider.minimumValue = AppUISettings.layerSettingsOutlineWidthMin
        outlineWidthSlider.maximumValue = AppUISettings.layerSettingsOutlineWidthMax
        
        redrawColorsForColorCollectionView( colorCollectionView: colorSelectionCollectionView)
        selectColorForColorCollectionView( colorCollectionView: colorSelectionCollectionView, desiredIndex: faceLayer.desiredThemeColorIndex)
        
        redrawColorsForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView)
        
        guard let layerOptions = faceLayer.layerOptions as? GearLayerOptions else { return }
        
        rotationSpeedLabel.text = String(layerOptions.anglePerSec)
        
        selectColorForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView, desiredIndex: layerOptions.desiredThemeColorIndexForOutline)
        outlineWidthSlider.value = layerOptions.outlineWidth
        //effectSlider.value = layerOptions.effectsStrength
        
        typeNameLabel.text = GearNode.descriptionForType(layerOptions.gearType)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
}
