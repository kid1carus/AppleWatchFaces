//
//  FaceLayerSecondHandTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/11/19.
//  Copyright © 2019 Michael Hill. All rights reserved.

import UIKit

class FaceLayerHandTableViewCell: FaceLayerTableViewCell, UICollectionViewDelegate {
    
    @IBOutlet var colorSelectionCollectionView: UICollectionView!
    @IBOutlet var outlineColorSelectionCollectionView: UICollectionView!
    
    @IBOutlet var typeButton: UIButton!
    @IBOutlet var typeNameLabel: UILabel!
    
    @IBOutlet var physicsFieldTypeButton: UIButton!
    @IBOutlet var physicFieldTypeNameLabel: UILabel!
    
    @IBOutlet var animationButton: UIButton!
    @IBOutlet var animationNameLabel: UILabel!
    
    @IBOutlet var outlineWidthSlider: UISlider!
    @IBOutlet var effectSlider: UISlider!
    
    let settingTypeString = "secondHand"
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let faceLayer = myFaceLayer()
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        if collectionView == colorSelectionCollectionView {
            faceLayer.desiredThemeColorIndex = indexPath.row
        }
        if collectionView == outlineColorSelectionCollectionView {
            guard let layerOptions = faceLayer.layerOptions as? HandLayerOptions else { return }
            layerOptions.desiredThemeColorIndexForOutline = indexPath.row
        }
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    override func returnFromAction( actionName: String, itemChosen: Int) {
        let faceLayer = myFaceLayer()
    
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        if actionName == "chooseTypeAction" {
            if myFaceLayer().layerType == .SecondHand {
                guard let layerOptions = faceLayer.layerOptions as? SecondHandLayerOptions else { return }
                layerOptions.handType = SecondHandTypes.userSelectableValues[itemChosen]
                typeNameLabel.text = SecondHandNode.descriptionForType(layerOptions.handType)
            }
            if myFaceLayer().layerType == .MinuteHand {
                guard let layerOptions = faceLayer.layerOptions as? MinuteHandLayerOptions else { return }
                layerOptions.handType = MinuteHandTypes.userSelectableValues[itemChosen]
                typeNameLabel.text = MinuteHandNode.descriptionForType(layerOptions.handType)
            }
            if myFaceLayer().layerType == .HourHand {
                guard let layerOptions = faceLayer.layerOptions as? HourHandLayerOptions else { return }
                layerOptions.handType = HourHandTypes.userSelectableValues[itemChosen]
                typeNameLabel.text = HourHandNode.descriptionForType(layerOptions.handType)
            }
        }
        
        if actionName == "choosePhysicsFieldTypeAction" {
            if myFaceLayer().layerType == .SecondHand {
                guard let layerOptions = faceLayer.layerOptions as? SecondHandLayerOptions else { return }
                layerOptions.physicsFieldType = PhysicsFieldTypes.userSelectableValues[itemChosen]
                physicFieldTypeNameLabel.text = FaceForegroundNode.descriptionForPhysicsFields(layerOptions.physicsFieldType)
            }
        }
        if actionName == "chooseAnimationAction" {
            if myFaceLayer().layerType == .SecondHand {
                guard let layerOptions = faceLayer.layerOptions as? SecondHandLayerOptions else { return }
                layerOptions.handAnimation = SecondHandMovements.userSelectableValues[itemChosen]
                animationNameLabel.text = SecondHandNode.descriptionForMovement(layerOptions.handAnimation)
            }
        }
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
        //debugPrint("returnFromAction action:" + actionName + " item: " + itemChosen.description)
    }
    
    @IBAction func buttonTapped( sender: UIButton ) {
        SettingsViewController.actionCell = self
        if sender == typeButton {
            if myFaceLayer().layerType == .SecondHand {
                SettingsViewController.actionsArray = SecondHandNode.typeDescriptions()
            }
            if myFaceLayer().layerType == .MinuteHand {
                SettingsViewController.actionsArray = MinuteHandNode.typeDescriptions()
            }
            if myFaceLayer().layerType == .HourHand {
                SettingsViewController.actionsArray = HourHandNode.typeDescriptions()
            }
            SettingsViewController.actionCellMedthodName = "chooseTypeAction"
            SettingsViewController.actionsTitle = "Choose Type"
        }
        if sender == physicsFieldTypeButton {
            SettingsViewController.actionsArray = FaceForegroundNode.physicFieldsTypeDescriptions()
            SettingsViewController.actionCellMedthodName = "choosePhysicsFieldTypeAction"
            SettingsViewController.actionsTitle = "Choose Physics Field Type"
        }
        if sender == animationButton {
            SettingsViewController.actionsArray = SecondHandNode.movementDescriptions()
            SettingsViewController.actionCellMedthodName = "chooseAnimationAction"
            SettingsViewController.actionsTitle = "Choose Animation"
        }
        
        NotificationCenter.default.post(name: SettingsViewController.settingsCallActionSheet, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    @IBAction func widthSliderValueDidChange(sender: UISlider ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? HandLayerOptions else { return }
        
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
    
    @IBAction func effectSliderValueDidChange(sender: UISlider ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? HandLayerOptions else { return }
        
        let roundedValue = Float(round(50*sender.value)/50)
        if roundedValue != layerOptions.effectsStrength {
            //add to undo stack for actions to be able to undo
            SettingsViewController.addToUndoStack()
            
            self.selectThisCell()
            debugPrint("slider value:" + String( roundedValue ) )
            layerOptions.effectsStrength = roundedValue
            let layerIndex = myLayerIndex() ?? 0
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil,
                                            userInfo:["settingType":settingTypeString,"layerIndex":layerIndex])
        }
    }
    
    override func setupUIForFaceLayer(faceLayer: FaceLayer) {
        super.setupUIForFaceLayer(faceLayer: faceLayer) // needs title outlet to function
        
        outlineWidthSlider.minimumValue = AppUISettings.layerSettingsOutlineWidthMin
        outlineWidthSlider.maximumValue = AppUISettings.layerSettingsOutlineWidthMax
        
        effectSlider.minimumValue = AppUISettings.handEffectSettigsSliderSpacerMin
        effectSlider.maximumValue = AppUISettings.handEffectSettigsSliderSpacerMax
        
        redrawColorsForColorCollectionView( colorCollectionView: colorSelectionCollectionView)
        selectColorForColorCollectionView( colorCollectionView: colorSelectionCollectionView, desiredIndex: faceLayer.desiredThemeColorIndex)
        
        redrawColorsForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView)
        
        guard let layerOptions = faceLayer.layerOptions as? HandLayerOptions else { return }
        
        selectColorForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView, desiredIndex: layerOptions.desiredThemeColorIndexForOutline)
        outlineWidthSlider.value = layerOptions.outlineWidth
        effectSlider.value = layerOptions.effectsStrength
        
        if faceLayer.layerType == .SecondHand {
            guard let secondHandLayerOptions = faceLayer.layerOptions as? SecondHandLayerOptions else { return }
            physicFieldTypeNameLabel.text = FaceForegroundNode.descriptionForPhysicsFields(secondHandLayerOptions.physicsFieldType)
            typeNameLabel.text = SecondHandNode.descriptionForType(secondHandLayerOptions.handType)
            animationNameLabel.text = SecondHandNode.descriptionForMovement(secondHandLayerOptions.handAnimation)
        }
        if faceLayer.layerType == .MinuteHand {
            guard let minuteHandLayerOptions = faceLayer.layerOptions as? MinuteHandLayerOptions else { return }
            typeNameLabel.text = MinuteHandNode.descriptionForType(minuteHandLayerOptions.handType)
        }
        if faceLayer.layerType == .HourHand {
            guard let hourHandLayerOptions = faceLayer.layerOptions as? HourHandLayerOptions else { return }
            typeNameLabel.text = HourHandNode.descriptionForType(hourHandLayerOptions.handType)
        }
        
//        formatNameLabel.text = DigitalTimeNode.descriptionForTimeFormats(layerOptions.formatType)
//        effectNameLabel.text = DigitalTimeNode.descriptionForTimeEffects(layerOptions.effectType)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    
}
