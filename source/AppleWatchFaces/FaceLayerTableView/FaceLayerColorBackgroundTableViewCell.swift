//
//  FaceLayerColorBackgroundTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/11/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit

class FaceLayerColorBackgroundTableViewCell: FaceLayerTableViewCell {
    
    @IBOutlet var colorSegment: UISegmentedControl!
    @IBOutlet var sizeSlider: UISlider!
    
    //    @IBAction func totalSegmentDidChange(sender: UISegmentedControl ) {
    //        self.selectThisCell()
    //
    //        let clockRingSetting = myClockRingSetting()
    //        clockRingSetting.ringPatternTotal = Int(ClockRingSetting.ringTotalOptions()[sender.selectedSegmentIndex])!
    //        clockRingSetting.ringPattern = [1] // all on for now
    //        NotificationCenter.default.post(name: DecoratorPreviewController.ringSettingsChangedNotificationName, object: nil,
    //                                        userInfo:["settingType":"ringPatternTotal" ])
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
        
        let faceLayer = myFaceLayer()
        guard let shapeOptions = faceLayer.layerOptions as? ShapeLayerOptions else { return }
        
        sizeSlider.minimumValue = 0.0
        sizeSlider.maximumValue = 1.0
        
        sizeSlider.value = shapeOptions.indicatorSize
            //            let totalString = String(shapeOptions.patternTotal)
            //            if let segmentIndex = ShapeLayerOptions.ringTotalOptions().index(of: totalString) {
            //                self.totalNumbersSegment.selectedSegmentIndex = segmentIndex
            //            }
            // }
        
        //
        //        self.materialSegment.selectedSegmentIndex = clockRingSetting.ringMaterialDesiredThemeColorIndex
        //
        
        
    }
    
    
}
