//
//  FaceLayerDigitalTimeLabel.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/11/19.
//  Copyright © 2019 Michael Hill. All rights reserved.

import UIKit

class FaceLayerDateTimeLabelTableViewCell: FaceLayerTableViewCell, UICollectionViewDelegate {
    
    @IBOutlet var colorSelectionCollectionView: UICollectionView!
    @IBOutlet var outlineColorSelectionCollectionView: UICollectionView!
    
    @IBOutlet var fontButton: UIButton!
    @IBOutlet var fontNameLabel: UILabel!
    
    @IBOutlet var formatButton: UIButton!
    @IBOutlet var formatNameLabel: UILabel!
    
    @IBOutlet var effectButton: UIButton!
    @IBOutlet var effectNameLabel: UILabel!
    
    @IBOutlet var outlineWidthSlider: UISlider!
    
    let settingTypeString = "dateTimeLabel"
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let faceLayer = myFaceLayer()
        
        if collectionView == colorSelectionCollectionView {
            faceLayer.desiredThemeColorIndex = indexPath.row
        }
        if collectionView == outlineColorSelectionCollectionView {
            guard let layerOptions = faceLayer.layerOptions as? DigitalTimeLayerOptions else { return }
            layerOptions.desiredThemeColorIndexForOutline = indexPath.row
        }
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    override func returnFromAction( actionName: String, itemChosen: Int) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? DigitalTimeLayerOptions else { return }
        
        if actionName == "chooseFontAction" {
            layerOptions.fontType = NumberTextTypes.userSelectableValues[itemChosen]
            fontNameLabel.text = NumberTextNode.descriptionForType(layerOptions.fontType)
        }
        
        if actionName == "chooseFormatAction" {
            layerOptions.formatType  = DigitalTimeFormats.userSelectableValues[itemChosen]
            formatNameLabel.text = DigitalTimeNode.descriptionForTimeFormats(layerOptions.formatType)
        }
        
        if actionName == "chooseEffectAction" {
            layerOptions.effectType  = DigitalTimeEffects.userSelectableValues[itemChosen]
            effectNameLabel.text = DigitalTimeNode.descriptionForTimeEffects(layerOptions.effectType)
        }
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
        //debugPrint("returnFromAction action:" + actionName + " item: " + itemChosen.description)
    }
    
    @IBAction func buttonTapped( sender: UIButton ) {
        SettingsViewController.actionCell = self
        if sender == fontButton {
            SettingsViewController.actionsArray = NumberTextNode.typeDescriptions()
            SettingsViewController.actionCellMedthodName = "chooseFontAction"
            SettingsViewController.actionsTitle = "Choose Font"
        }
        if sender == formatButton {
            SettingsViewController.actionsArray = DigitalTimeNode.timeFormatsDescriptions()
            SettingsViewController.actionCellMedthodName = "chooseFormatAction"
            SettingsViewController.actionsTitle = "Choose Format"
        }
        if sender == effectButton {
            SettingsViewController.actionsArray = DigitalTimeNode.timeEffectsDescriptions()
            SettingsViewController.actionCellMedthodName = "chooseEffectAction"
            SettingsViewController.actionsTitle = "Choose Effect"
        }
        NotificationCenter.default.post(name: SettingsViewController.settingsCallActionSheet, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    @IBAction func widthSliderValueDidChange(sender: UISlider ) {
        let faceLayer = myFaceLayer()
        guard let shapeOptions = faceLayer.layerOptions as? DigitalTimeLayerOptions else { return }

        let roundedValue = Float(round(1*sender.value)/1)
        if roundedValue != shapeOptions.outlineWidth {
            self.selectThisCell()
            debugPrint("slider value:" + String( roundedValue ) )
            shapeOptions.outlineWidth = roundedValue
            let layerIndex = myLayerIndex() ?? 0
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil,
                                            userInfo:["settingType":settingTypeString,"layerIndex":layerIndex])
        }
    }
    
    override func setupUIForFaceLayer(faceLayer: FaceLayer) {
        super.setupUIForFaceLayer(faceLayer: faceLayer)
        
        outlineWidthSlider.minimumValue = AppUISettings.layerSettingsOutlineWidthMin
        outlineWidthSlider.maximumValue = AppUISettings.layerSettingsOutlineWidthMax
        
        redrawColorsForColorCollectionView( colorCollectionView: colorSelectionCollectionView)
        selectColorForColorCollectionView( colorCollectionView: colorSelectionCollectionView, desiredIndex: faceLayer.desiredThemeColorIndex)
        
        redrawColorsForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView)
        guard let layerOptions = faceLayer.layerOptions as? DigitalTimeLayerOptions else { return }
        selectColorForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView, desiredIndex: layerOptions.desiredThemeColorIndexForOutline)
        
        fontNameLabel.text = NumberTextNode.descriptionForType(layerOptions.fontType)
        formatNameLabel.text = DigitalTimeNode.descriptionForTimeFormats(layerOptions.formatType)
        effectNameLabel.text = DigitalTimeNode.descriptionForTimeEffects(layerOptions.effectType)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    
}
