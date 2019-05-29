//
//  FaceLayerGradientBackgroundTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/11/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit

class FaceLayerGradientBackgroundTableViewCell: FaceLayerTableViewCell, UICollectionViewDelegate {
    
    @IBOutlet var colorSelectionCollectionView: UICollectionView!
    @IBOutlet var destinationColorSelectionCollectionView: UICollectionView!
    
    @IBOutlet var directionButton: UIButton!
    @IBOutlet var directionNameLabel: UILabel!
    
    let settingTypeString = "colorBackground"
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let faceLayer = myFaceLayer()
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        if collectionView == colorSelectionCollectionView {
            faceLayer.desiredThemeColorIndex = indexPath.row
        }
        if collectionView == destinationColorSelectionCollectionView {
            guard let layerOptions = faceLayer.layerOptions as? GradientBackgroundLayerOptions else { return }
            layerOptions.desiredThemeColorIndexForDestination = indexPath.row
        }
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    override func returnFromAction( actionName: String, itemChosen: Int) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? GradientBackgroundLayerOptions else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        if actionName == "chooseDirectionAction" {
            layerOptions.directionType = GradientBackgroundDirectionTypes.userSelectableValues[itemChosen]
            directionNameLabel.text = FaceBackgroundNode.descriptionForGradientDirections(layerOptions.directionType)
        }
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
        //debugPrint("returnFromAction action:" + actionName + " item: " + itemChosen.description)
    }
    
    @IBAction func buttonTapped( sender: UIButton ) {
        SettingsViewController.actionCell = self
        if sender == directionButton {
            SettingsViewController.actionsArray = FaceBackgroundNode.gradientDirectionDescriptions()
            SettingsViewController.actionCellMedthodName = "chooseDirectionAction"
            SettingsViewController.actionsTitle = "Choose Direction"
        }
        NotificationCenter.default.post(name: SettingsViewController.settingsCallActionSheet, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    override func setupUIForFaceLayer(faceLayer: FaceLayer) {
        super.setupUIForFaceLayer(faceLayer: faceLayer) // needs title outlet to function
        
        redrawColorsForColorCollectionView( colorCollectionView: colorSelectionCollectionView)
        selectColorForColorCollectionView( colorCollectionView: colorSelectionCollectionView, desiredIndex: faceLayer.desiredThemeColorIndex)
        
        redrawColorsForColorCollectionView( colorCollectionView: destinationColorSelectionCollectionView)
        guard let layerOptions = faceLayer.layerOptions as? GradientBackgroundLayerOptions else { return }
        selectColorForColorCollectionView( colorCollectionView: destinationColorSelectionCollectionView, desiredIndex: layerOptions.desiredThemeColorIndexForDestination)
        directionNameLabel.text = FaceBackgroundNode.descriptionForGradientDirections(layerOptions.directionType)
    }
    
    
}
