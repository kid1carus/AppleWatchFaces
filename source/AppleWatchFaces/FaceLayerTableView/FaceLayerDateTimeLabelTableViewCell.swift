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
    
    @IBOutlet var colorButton: UIButton!
    @IBOutlet var outlineColorButton: UIButton!
//    @IBOutlet var totalNumbersSegment: UISegmentedControl!
//    @IBOutlet var valueSlider: UISlider!
    
    let settingTypeString = "dateTimeLabel"
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let faceLayer = myFaceLayer()
        
        if collectionView == colorSelectionCollectionView {
            faceLayer.desiredThemeColorIndex = indexPath.row
        }
        if collectionView == outlineColorSelectionCollectionView {
            guard let shapeOptions = faceLayer.layerOptions as? ShapeLayerDigitalTimeOptions else { return }
            shapeOptions.desiredThemeColorIndexForOutline = indexPath.row
        }
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
//    let desiredColorIndex = getColorIndexForColorButton(colorArray: SettingsViewController.currentFaceSetting.faceColors, buttonSize: colorButton.frame.size, position: position)
//
//    let faceLayer = myFaceLayer()
//    faceLayer.desiredThemeColorIndex = desiredColorIndex
//
//    NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingType,"layerIndex":myLayerIndex()!])
    
    //    func shapeChosen( shapeType: FaceIndicatorTypes ) {
    //        //debugPrint("fontChosen" + NumberTextNode.descriptionForType(textType))
    //
    //        let faceLayerSetting = myFaceLayer()
    //        faceLayerSetting.
    //        self.titleLabel.text = titleText(clockRingSetting: clockRingSetting)
    //
    //        NotificationCenter.default.post(name: DecoratorPreviewController.ringSettingsChangedNotificationName, object: nil,
    //                                        userInfo:["settingType":"indicatorType" ])
    //    }
    //
    //    @IBAction func editShape(sender: UIButton ) {
    //        self.selectThisCell()
    //
    //        NotificationCenter.default.post(name: DecoratorPreviewController.ringSettingsEditDetailNotificationName, object: nil,
    //                                        userInfo:["settingType":"indicatorType", "decoratorShapeTableViewCell":self ])
    //    }
    //
    //    @IBAction func totalSegmentDidChange(sender: UISegmentedControl ) {
    //        self.selectThisCell()
    //
    //        let clockRingSetting = myClockRingSetting()
    //        clockRingSetting.ringPatternTotal = Int(ClockRingSetting.ringTotalOptions()[sender.selectedSegmentIndex])!
    //        clockRingSetting.ringPattern = [1] // all on for now
    //        NotificationCenter.default.post(name: DecoratorPreviewController.ringSettingsChangedNotificationName, object: nil,
    //                                        userInfo:["settingType":"ringPatternTotal" ])
    //    }
    //
    //    @IBAction func segmentDidChange(sender: UISegmentedControl ) {
    //        self.selectThisCell()
    //
    //        //debugPrint("segment value:" + String( sender.selectedSegmentIndex ) )
    //        let clockRingSetting = myClockRingSetting()
    //        clockRingSetting.ringMaterialDesiredThemeColorIndex = sender.selectedSegmentIndex
    //        NotificationCenter.default.post(name: DecoratorPreviewController.ringSettingsChangedNotificationName, object: nil,
    //                                        userInfo:["settingType":"ringMaterialDesiredThemeColorIndex" ])
    //    }
    
//    @IBAction func sliderValueDidChange(sender: UISlider ) {
//        let faceLayer = myFaceLayer()
//        guard let shapeOptions = faceLayer.layerOptions as? ShapeLayerOptions else { return }
//
//        let roundedValue = Float(round(50*sender.value)/50)
//        if roundedValue != shapeOptions.indicatorSize {
//            self.selectThisCell()
//            debugPrint("slider value:" + String( roundedValue ) )
//            shapeOptions.indicatorSize = roundedValue
//            let layerIndex = myLayerIndex() ?? 0
//            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil,
//                                            userInfo:["settingType":"shapeRing","layerIndex":layerIndex])
//        }
//    }
    
    override func setupUIForFaceLayer(faceLayer: FaceLayer) {
        super.setupUIForFaceLayer(faceLayer: faceLayer)
        
        redrawColorsForColorCollectionView( colorCollectionView: colorSelectionCollectionView)
        selectColorForColorCollectionView( colorCollectionView: colorSelectionCollectionView, desiredIndex: faceLayer.desiredThemeColorIndex)
        
        redrawColorsForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView)
        guard let shapeOptions = faceLayer.layerOptions as? ShapeLayerDigitalTimeOptions else { return }
        selectColorForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView, desiredIndex: shapeOptions.desiredThemeColorIndexForOutline)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    
}
