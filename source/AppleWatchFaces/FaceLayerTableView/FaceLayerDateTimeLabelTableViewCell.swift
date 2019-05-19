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
    @IBOutlet var outlineWidthSlider: UISlider!
    
    let settingTypeString = "dateTimeLabel"
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let faceLayer = myFaceLayer()
        
        if collectionView == colorSelectionCollectionView {
            faceLayer.desiredThemeColorIndex = indexPath.row
        }
        if collectionView == outlineColorSelectionCollectionView {
            guard let shapeOptions = faceLayer.layerOptions as? DigitalTimeLayerOptions else { return }
            shapeOptions.desiredThemeColorIndexForOutline = indexPath.row
        }
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
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
        guard let shapeOptions = faceLayer.layerOptions as? DigitalTimeLayerOptions else { return }
        selectColorForColorCollectionView( colorCollectionView: outlineColorSelectionCollectionView, desiredIndex: shapeOptions.desiredThemeColorIndexForOutline)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    
}
