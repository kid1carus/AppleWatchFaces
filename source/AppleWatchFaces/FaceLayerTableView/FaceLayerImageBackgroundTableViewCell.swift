//
//  FaceLayerColorBackgroundTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/11/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit

class FaceLayerImageBackgroundTableViewCell: FaceLayerTableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var imageSelectionCollectionView: UICollectionView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var filenameLabel: UILabel!
    @IBOutlet var hasTransparencySwitch: UISwitch!
    @IBOutlet var rotationSpeedSlider: UISlider!
    
    @IBOutlet var shapeButton: UIButton!
    @IBOutlet var shapeNameLabel: UILabel!
    
    let settingTypeString = "imageBackground"
    
    @IBAction func hasTransparencySwitchFlipped( sender: UISwitch ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? ImageBackgroundLayerOptions else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        layerOptions.hasTransparency = sender.isOn
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    override func returnFromAction( actionName: String, itemChosen: Int) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? ImageBackgroundLayerOptions else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        if actionName == "chooseTypeAction" {
            layerOptions.backgroundType = FaceBackgroundTypes.userSelectableValues[itemChosen]
            shapeNameLabel.text = FaceBackgroundNode.descriptionForType(layerOptions.backgroundType)
        }
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
        //debugPrint("returnFromAction action:" + actionName + " item: " + itemChosen.description)
    }
    
    @IBAction func buttonTapped( sender: UIButton ) {
        SettingsViewController.actionCell = self
        
        if sender == shapeButton {
            SettingsViewController.actionsArray = FaceBackgroundNode.typeDescriptions()
            SettingsViewController.actionCellMedthodName = "chooseTypeAction"
            SettingsViewController.actionsTitle = "Choose Shape Type"
        }
        
        NotificationCenter.default.post(name: SettingsViewController.settingsCallActionSheet, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    @IBAction func cameraButtonTapped( sender: UIButton) {
        NotificationCenter.default.post(name: SettingsViewController.settingsGetCameraImageNotificationName, object: nil, userInfo:["layerIndex":myLayerIndex()!])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppUISettings.materialFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "settingsColorCell", for: indexPath) as! ColorSettingCollectionViewCell
        
        //buffer
        let buffer:CGFloat = CGFloat(Int(cell.frame.size.width / 10))
        let corner:CGFloat = CGFloat(Int(buffer / 2))
        cell.circleView.frame = CGRect.init(x: corner, y: corner, width: cell.frame.size.width-buffer, height: cell.frame.size.height-buffer)
        
        if let image = UIImage.init(named: AppUISettings.materialFiles[indexPath.row] ) {
            cell.circleView.layer.cornerRadius = 0
            //TODO: if this idea sticks, resize this on app start and cache them so they arent built on-demand
            let scaledImage = AppUISettings.imageWithImage(image: image, scaledToSize: CGSize.init(width: cell.frame.size.width-buffer, height: cell.frame.size.height-buffer))
            cell.circleView.backgroundColor = SKColor.init(patternImage: scaledImage)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? ImageBackgroundLayerOptions else { return }
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        faceLayer.filenameForImage = "" //clear this out
        
        layerOptions.filename = AppUISettings.materialFiles[indexPath.row]
        filenameLabel.text = layerOptions.filename
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    @IBAction func speedSliderValueDidChange(sender: UISlider ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? ImageBackgroundLayerOptions else { return }
        
        let roundedValue = Float(round(50*sender.value)/50)
        if roundedValue != layerOptions.anglePerSec {
            //add to undo stack for actions to be able to undo
            SettingsViewController.addToUndoStack()
            
            debugPrint("slider value:" + String( roundedValue ) )
            layerOptions.anglePerSec = roundedValue
            let layerIndex = myLayerIndex() ?? 0
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil,
                                            userInfo:["settingType":settingTypeString ,"layerIndex":layerIndex])
        }
    }
    
    override func setupUIForFaceLayer(faceLayer: FaceLayer) {
        super.setupUIForFaceLayer(faceLayer: faceLayer) // needs title outlet to function
        
        guard let layerOptions = faceLayer.layerOptions as? ImageBackgroundLayerOptions else { return }
        
        rotationSpeedSlider.minimumValue = AppUISettings.imageRotationSpeedSettigsSliderMin
        rotationSpeedSlider.maximumValue = AppUISettings.imageRotationSpeedSettigsSliderMax
        rotationSpeedSlider.value = layerOptions.anglePerSec
            
        shapeNameLabel.text = FaceBackgroundNode.descriptionForType(layerOptions.backgroundType)
        
        hasTransparencySwitch.isOn = layerOptions.hasTransparency
        
        if faceLayer.filenameForImage != "" {
            filenameLabel.text = faceLayer.filenameForImage
        } else {
            if let meterialsIndex = AppUISettings.materialFiles.index(of: layerOptions.filename) {
                filenameLabel.text = layerOptions.filename
                let indexPath = IndexPath.init(row: meterialsIndex, section: 0)
                imageSelectionCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
            }
        }
        
    }
    
    
}
