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
//    @IBOutlet var totalNumbersSegment: UISegmentedControl!
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
        layerOptions.fontType = NumberTextTypes.userSelectableValues[itemChosen]
        
        fontNameLabel.text = NumberTextNode.descriptionForType(layerOptions.fontType)
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
        //debugPrint("returnFromAction action:" + actionName + " item: " + itemChosen.description)
    }
    
    @IBAction func buttonTapped( sender: UIButton ) {
        if sender == fontButton {
            SettingsViewController.actionsArray = NumberTextNode.typeDescriptions()
            SettingsViewController.actionCell = self
            SettingsViewController.actionCellMedthodName = "chooseFontAction"
            SettingsViewController.actionsTitle = "Choose Font"
            NotificationCenter.default.post(name: SettingsViewController.settingsCallActionSheet, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
        }
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
        
        outlineWidthSlider.maximumValue = 10.0
        outlineWidthSlider.minimumValue = 0.0
        
        redrawColorsForColorCollectionView( colorCollectionView: colorSelectionCollectionView)
        selectColorForColorCollectionView( colorCollectionView: colorSelectionCollectionView, desiredIndex: faceLayer.desiredThemeColorIndex)
        
        redrawColorsForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView)
        guard let layerOptions = faceLayer.layerOptions as? DigitalTimeLayerOptions else { return }
        selectColorForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView, desiredIndex: layerOptions.desiredThemeColorIndexForOutline)
        fontNameLabel.text = NumberTextNode.descriptionForType(layerOptions.fontType)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    
}
