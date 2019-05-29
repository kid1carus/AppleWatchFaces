//
//  FaceLayerShapeTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/5/19
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit

class FaceLayerFieldTableViewCell: FaceLayerTableViewCell, UICollectionViewDelegate {

    @IBOutlet var colorSelectionCollectionView: UICollectionView!
    @IBOutlet var sizeSlider: UISlider!
    
    @IBOutlet var nodeTypeButton: UIButton!
    @IBOutlet var nodeTypeNameLabel: UILabel!
    
    @IBOutlet var shapeTypeButton: UIButton!
    @IBOutlet var shapeTypeNameLabel: UILabel!
    
    let settingTypeString = "physicField"
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let faceLayer = myFaceLayer()
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        faceLayer.desiredThemeColorIndex = indexPath.row
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    override func returnFromAction( actionName: String, itemChosen: Int) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? ParticleFieldLayerOptions else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        if actionName == "chooseNodeAction" {
            layerOptions.nodeType = FaceForegroundTypes.userSelectableValues[itemChosen]
            nodeTypeNameLabel.text = FaceForegroundNode.descriptionForType(layerOptions.nodeType)
        }
        
        if actionName == "chooseShapeAction" {
            layerOptions.shapeType  = OverlayShapeTypes.userSelectableValues[itemChosen]
            shapeTypeNameLabel.text = ParticleFieldLayerOptions.descriptionForOverlayShapeType(layerOptions.shapeType)
        }
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
        //debugPrint("returnFromAction action:" + actionName + " item: " + itemChosen.description)
    }
    
    @IBAction func buttonTapped( sender: UIButton ) {
        SettingsViewController.actionCell = self

        if sender == nodeTypeButton {
            SettingsViewController.actionsArray = FaceForegroundNode.typeDescriptions()
            SettingsViewController.actionCellMedthodName = "chooseNodeAction"
            SettingsViewController.actionsTitle = "Choose Field Type"
        }
        if (sender == shapeTypeButton) {
            SettingsViewController.actionsArray = ParticleFieldLayerOptions.overlayShapeTypeDescriptions()
            SettingsViewController.actionCellMedthodName = "chooseShapeAction"
            SettingsViewController.actionsTitle = "Choose Shape Type"
        }
        NotificationCenter.default.post(name: SettingsViewController.settingsCallActionSheet, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    @IBAction func sizeSliderValueDidChange(sender: UISlider ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? ParticleFieldLayerOptions else { return }
        
        let roundedValue = Float(round(50*sender.value)/50)
        if roundedValue != layerOptions.itemSize {
            //add to undo stack for actions to be able to undo
            SettingsViewController.addToUndoStack()
            
            //debugPrint("slider value:" + String( roundedValue ) )
            layerOptions.itemSize = roundedValue
            let layerIndex = myLayerIndex() ?? 0
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil,
                                            userInfo:["settingType":settingTypeString ,"layerIndex":layerIndex])
        }
    }
    
    override func setupUIForFaceLayer(faceLayer: FaceLayer) {
        super.setupUIForFaceLayer(faceLayer: faceLayer) // needs title outlet to function
        
        redrawColorsForColorCollectionView( colorCollectionView: colorSelectionCollectionView)
        selectColorForColorCollectionView( colorCollectionView: colorSelectionCollectionView, desiredIndex: faceLayer.desiredThemeColorIndex)
        
        sizeSlider.minimumValue = AppUISettings.foregroundItemSizeSettingsSliderSpacerMin
        sizeSlider.maximumValue = AppUISettings.foregroundItemSizeSettingsSliderSpacerMax
        
        if let layerOptions = faceLayer.layerOptions as? ParticleFieldLayerOptions {
            sizeSlider.value = layerOptions.itemSize
            
            shapeTypeNameLabel.text = ParticleFieldLayerOptions.descriptionForOverlayShapeType(layerOptions.shapeType)
            
            nodeTypeNameLabel.text = FaceForegroundNode.descriptionForType(layerOptions.nodeType
            )
        }
        
    }

    
}
