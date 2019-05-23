//
//  FaceLayerShapeTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/5/19
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit

class FaceLayerShapeTableViewCell: FaceLayerTableViewCell, UICollectionViewDelegate {

    @IBOutlet var colorSelectionCollectionView: UICollectionView!
    @IBOutlet var materialSegment: UISegmentedControl!
    @IBOutlet var totalNumbersSegment: UISegmentedControl!
    @IBOutlet var valueSlider: UISlider!
    
    @IBOutlet var shapeButton: UIButton!
    @IBOutlet var shapeNameLabel: UILabel!
    
    @IBOutlet var patternButton: UIButton!
    @IBOutlet var patternNameLabel: UILabel!
    
    let settingTypeString = "shapeRing"
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let faceLayer = myFaceLayer()
        faceLayer.desiredThemeColorIndex = indexPath.row
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    override func returnFromAction( actionName: String, itemChosen: Int) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? ShapeLayerOptions else { return }
        
        if actionName == "chooseTypeAction" {
            layerOptions.indicatorType = FaceIndicatorTypes.userSelectableValues[itemChosen]
            shapeNameLabel.text = FaceIndicatorNode.descriptionForType(layerOptions.indicatorType)
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

        if sender == shapeButton {
            SettingsViewController.actionsArray = FaceIndicatorNode.typeDescriptions()
            SettingsViewController.actionCellMedthodName = "chooseTypeAction"
            SettingsViewController.actionsTitle = "Choose Shape Type"
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
        guard let layerOptions = faceLayer.layerOptions as? ShapeLayerOptions else { return }

        layerOptions.patternTotal = Int(ClockRingSetting.ringTotalOptions()[sender.selectedSegmentIndex])!
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil,
                                        userInfo:["settingType":settingTypeString ,"layerIndex":myLayerIndex()!])
    }

    
    @IBAction func sliderValueDidChange(sender: UISlider ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? ShapeLayerOptions else { return }
        
        let roundedValue = Float(round(50*sender.value)/50)
        if roundedValue != layerOptions.indicatorSize {
            self.selectThisCell()
            debugPrint("slider value:" + String( roundedValue ) )
            layerOptions.indicatorSize = roundedValue
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
        
        if let shapeOptions = faceLayer.layerOptions as? ShapeLayerOptions {
            valueSlider.value = shapeOptions.indicatorSize
            
            shapeNameLabel.text = FaceIndicatorNode.descriptionForType(shapeOptions.indicatorType)
            patternNameLabel.text =  ShapeLayerOptions.descriptionForRingPattern(shapeOptions.patternArray)
            
            let totalString = String(shapeOptions.patternTotal)
            if let segmentIndex = ShapeLayerOptions.ringTotalOptions().index(of: totalString) {
                self.totalNumbersSegment.selectedSegmentIndex = segmentIndex
            }
        }
        
    }

    
}
