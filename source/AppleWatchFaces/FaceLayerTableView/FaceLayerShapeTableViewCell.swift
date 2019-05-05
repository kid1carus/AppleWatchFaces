//
//  FaceLayerShapeTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/5/19
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit

class FaceLayerShapeTableViewCell: FaceLayerTableViewCell {

    @IBOutlet var materialSegment: UISegmentedControl!
    @IBOutlet var totalNumbersSegment: UISegmentedControl!
    @IBOutlet var valueSlider: UISlider!
    
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
//        let roundedValue = Float(round(50*sender.value)/50)
//        if roundedValue != clockRingSetting.indicatorSize {
//            self.selectThisCell()
//            debugPrint("slider value:" + String( roundedValue ) )
//            clockRingSetting.indicatorSize = roundedValue
//            NotificationCenter.default.post(name: DecoratorPreviewController.ringSettingsChangedNotificationName, object: nil,
//                                            userInfo:["settingType":"indicatorSize" ])
//        }
//    }
    
    func titleText( faceLayer: FaceLayer ) -> String {
        return FaceLayer.descriptionForType(faceLayer.layerType) //+ " : " + FaceIndicatorNode.descriptionForType(clockRingSetting.indicatorType)
    }

    override func setupUIForFaceLayer(faceLayer: FaceLayer) {
        super.setupUIForFaceLayer(faceLayer: faceLayer)
        
        self.titleLabel.text = titleText(faceLayer: faceLayer)
        
        valueSlider.minimumValue = AppUISettings.ringSettigsSliderShapeMin
        valueSlider.maximumValue = AppUISettings.ringSettigsSliderShapeMax
        
//        valueSlider.value = clockRingSetting.indicatorSize
//
//        self.materialSegment.selectedSegmentIndex = clockRingSetting.ringMaterialDesiredThemeColorIndex
//
//        let totalString = String(clockRingSetting.ringPatternTotal)
//        if let segmentIndex = ClockRingSetting.ringTotalOptions().index(of: totalString) {
//            self.totalNumbersSegment.selectedSegmentIndex = segmentIndex
//        }
        
    }

    
}
