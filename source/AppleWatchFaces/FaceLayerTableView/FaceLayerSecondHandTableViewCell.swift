//
//  FaceLayerSecondHandTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/11/19.
//  Copyright © 2019 Michael Hill. All rights reserved.

import UIKit

class FaceLayerSecondHandTableViewCell: FaceLayerTableViewCell, UICollectionViewDelegate {
    
    @IBOutlet var colorSelectionCollectionView: UICollectionView!
    @IBOutlet var outlineColorSelectionCollectionView: UICollectionView!
    
    @IBOutlet var typeButton: UIButton!
    @IBOutlet var typeNameLabel: UILabel!
    
    @IBOutlet var animationButton: UIButton!
    @IBOutlet var animationNameLabel: UILabel!
    
    @IBOutlet var outlineWidthSlider: UISlider!
    @IBOutlet var effectSlider: UISlider!
    
    let settingTypeString = "secondHand"
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let faceLayer = myFaceLayer()
        
        if collectionView == colorSelectionCollectionView {
            faceLayer.desiredThemeColorIndex = indexPath.row
        }
        if collectionView == outlineColorSelectionCollectionView {
            guard let layerOptions = faceLayer.layerOptions as? SecondHandLayerOptions else { return }
            layerOptions.desiredThemeColorIndexForOutline = indexPath.row
        }
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    override func returnFromAction( actionName: String, itemChosen: Int) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? SecondHandLayerOptions else { return }
        
        if actionName == "chooseTypeAction" {
            layerOptions.handType = SecondHandTypes.userSelectableValues[itemChosen]
            typeNameLabel.text = SecondHandNode.descriptionForType(layerOptions.handType)
        }
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
        //debugPrint("returnFromAction action:" + actionName + " item: " + itemChosen.description)
    }
    
    @IBAction func buttonTapped( sender: UIButton ) {
        SettingsViewController.actionCell = self
        if sender == typeButton {
            SettingsViewController.actionsArray = SecondHandNode.typeDescriptions()
            SettingsViewController.actionCellMedthodName = "chooseTypeAction"
            SettingsViewController.actionsTitle = "Choose Type"
        }
        
        NotificationCenter.default.post(name: SettingsViewController.settingsCallActionSheet, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    @IBAction func widthSliderValueDidChange(sender: UISlider ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? SecondHandLayerOptions else { return }
        
        let roundedValue = Float(round(1*sender.value)/1)
        if roundedValue != layerOptions.outlineWidth {
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
        guard let layerOptions = faceLayer.layerOptions as? SecondHandLayerOptions else { return }
        
        let roundedValue = Float(round(50*sender.value)/50)
        if roundedValue != layerOptions.effectsStrength {
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
        
        guard let layerOptions = faceLayer.layerOptions as? SecondHandLayerOptions else { return }
        
        selectColorForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView, desiredIndex: layerOptions.desiredThemeColorIndexForOutline)
        outlineWidthSlider.value = layerOptions.outlineWidth
        effectSlider.value = layerOptions.effectsStrength
        
        typeNameLabel.text = SecondHandNode.descriptionForType(layerOptions.handType)
//        formatNameLabel.text = DigitalTimeNode.descriptionForTimeFormats(layerOptions.formatType)
//        effectNameLabel.text = DigitalTimeNode.descriptionForTimeEffects(layerOptions.effectType)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    
}
