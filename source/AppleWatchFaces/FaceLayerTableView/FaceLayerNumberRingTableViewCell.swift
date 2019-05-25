//
//  FaceLayerShapeTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/5/19
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit

class FaceLayerNumberRingTableViewCell: FaceLayerTableViewCell, UICollectionViewDelegate {

    @IBOutlet var colorSelectionCollectionView: UICollectionView!
    @IBOutlet var outlineColorSelectionCollectionView: UICollectionView!
    
    @IBOutlet var materialSegment: UISegmentedControl!
    @IBOutlet var totalNumbersSegment: UISegmentedControl!
    @IBOutlet var valueSlider: UISlider!
    
    @IBOutlet var fontButton: UIButton!
    @IBOutlet var fontNameLabel: UILabel!
    
    @IBOutlet var patternButton: UIButton!
    @IBOutlet var patternNameLabel: UILabel!
    
    @IBOutlet var outlineWidthSlider: UISlider!
    
    let settingTypeString = "numberRing"
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let faceLayer = myFaceLayer()
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        if collectionView == colorSelectionCollectionView {
            faceLayer.desiredThemeColorIndex = indexPath.row
        }
        if collectionView == outlineColorSelectionCollectionView {
            guard let layerOptions = faceLayer.layerOptions as? NumberRingLayerOptions else { return }
            layerOptions.desiredThemeColorIndexForOutline = indexPath.row
        }
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    override func returnFromAction( actionName: String, itemChosen: Int) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? NumberRingLayerOptions else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        if actionName == "chooseFontAction" {
            layerOptions.fontType = NumberTextTypes.userSelectableValues[itemChosen]
            fontNameLabel.text = NumberTextNode.descriptionForType(layerOptions.fontType)
        }
        
        if actionName == "choosePatternAction" {
            layerOptions.patternArray = ShapeLayerOptions.ringPatterns()[itemChosen] as! [Int]
            patternNameLabel.text =  ShapeLayerOptions.ringPatternDescriptions()[itemChosen]
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
        if (sender == patternButton) {
            SettingsViewController.actionsArray = ShapeLayerOptions.ringPatternDescriptions()
            SettingsViewController.actionCellMedthodName = "choosePatternAction"
            SettingsViewController.actionsTitle = "Choose Pattern Type"
        }
        NotificationCenter.default.post(name: SettingsViewController.settingsCallActionSheet, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    

    @IBAction func totalSegmentDidChange(sender: UISegmentedControl ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? NumberRingLayerOptions else { return }

        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        layerOptions.patternTotal = Int(ShapeLayerOptions.ringTotalOptions()[sender.selectedSegmentIndex])!
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil,
                                        userInfo:["settingType":settingTypeString ,"layerIndex":myLayerIndex()!])
    }
    
    @IBAction func widthSliderValueDidChange(sender: UISlider ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? NumberRingLayerOptions else { return }
        
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

    
    @IBAction func sliderValueDidChange(sender: UISlider ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? NumberRingLayerOptions else { return }
        
        let roundedValue = Float(round(50*sender.value)/50)
        if roundedValue != layerOptions.textSize {
            //add to undo stack for actions to be able to undo
            SettingsViewController.addToUndoStack()
            
            self.selectThisCell()
            debugPrint("slider value:" + String( roundedValue ) )
            layerOptions.textSize = roundedValue
            let layerIndex = myLayerIndex() ?? 0
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil,
                                            userInfo:["settingType":settingTypeString ,"layerIndex":layerIndex])
        }
    }
    
    override func setupUIForFaceLayer(faceLayer: FaceLayer) {
        super.setupUIForFaceLayer(faceLayer: faceLayer) // needs title outlet to function
        
        redrawColorsForColorCollectionView( colorCollectionView: colorSelectionCollectionView)
        selectColorForColorCollectionView( colorCollectionView: colorSelectionCollectionView, desiredIndex: faceLayer.desiredThemeColorIndex)

        valueSlider.minimumValue = AppUISettings.ringSettigsSliderShapeMin
        valueSlider.maximumValue = AppUISettings.ringSettigsSliderShapeMax
        
        outlineWidthSlider.minimumValue = AppUISettings.layerSettingsOutlineWidthMin
        outlineWidthSlider.maximumValue = AppUISettings.layerSettingsOutlineWidthMax

        if let layerOptions = faceLayer.layerOptions as? NumberRingLayerOptions {
            redrawColorsForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView)
            selectColorForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView, desiredIndex: layerOptions.desiredThemeColorIndexForOutline)

            valueSlider.value = layerOptions.textSize
            outlineWidthSlider.value = layerOptions.outlineWidth
            
            fontNameLabel.text = NumberTextNode.descriptionForType(layerOptions.fontType)
            patternNameLabel.text =  ShapeLayerOptions.descriptionForRingPattern(layerOptions.patternArray)
            
            let totalString = String(layerOptions.patternTotal)
            if let segmentIndex = ShapeLayerOptions.ringTotalOptions().index(of: totalString) {
                self.totalNumbersSegment.selectedSegmentIndex = segmentIndex
            }
        }
        
    }

    
}
