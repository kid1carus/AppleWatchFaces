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
    //@IBOutlet var filenameLabel: UILabel!
    @IBOutlet var hasTransparencySwitch: UISwitch!
    //@IBOutlet var rotationSpeedSlider: UISlider!
    @IBOutlet var rotationSpeedFaster: UIButton!
    @IBOutlet var rotationSpeedLower: UIButton!
    @IBOutlet var rotationSpeedLabel: UILabel!
    
    @IBOutlet var shapeButton: UIButton!
    @IBOutlet var shapeNameLabel: UILabel!
    
    let settingTypeString = "imageBackground"
    
    let materialFiles = AppUISettings.materialFiles + AppUISettings.overlayMaterialFiles
    
    @IBAction func hasTransparencySwitchFlipped( sender: UISwitch ) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? ImageBackgroundLayerOptions else { return }
        
        layerOptions.hasTransparency = sender.isOn
        hasTransparencySwitch.isEnabled = layerOptions.hasTransparency
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        if (layerOptions.hasTransparency) {
            //re import from camera
            NotificationCenter.default.post(name: SettingsViewController.settingsGetCameraImageNotificationName, object: nil, userInfo:["layerIndex":myLayerIndex()!])
        } else {
            // remake thumb
            if let image = UIImage.getImageFor(imageName: faceLayer.filenameForImage)  {
                //downgrade image and get new filename
                faceLayer.filenameForImage = image.downgradePNGtoJPG(imageName: faceLayer.filenameForImage)
                //filenameLabel.text = faceLayer.filenameForImage
            }
        }
        
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
        return materialFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "settingsColorCell", for: indexPath) as! ColorSettingCollectionViewCell
        
        //buffer
        let buffer:CGFloat = CGFloat(Int(cell.frame.size.width / 10))
        let corner:CGFloat = CGFloat(Int(buffer / 2))
        cell.circleView.frame = CGRect.init(x: corner, y: corner, width: cell.frame.size.width-buffer, height: cell.frame.size.height-buffer)
        
        if let image = UIImage.init(named: materialFiles[indexPath.row] ) {
            cell.circleView.layer.cornerRadius = 0
            //TODO: if this idea sticks, resize this on app start and cache them so they arent built on-demand
            let scaledImage = AppUISettings.imageWithImage(image: image, fitToSize: CGSize.init(width: cell.frame.size.width-buffer, height: cell.frame.size.height-buffer))
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
        unSelectCameraButton()
        
//        //if it was a camera image sized, fill it
//        if layerOptions.backgroundType == .FaceBackgroundTypeImage {
//            layerOptions.backgroundType = .FaceBackgroundTypeFilled
//        }
        layerOptions.filename = materialFiles[indexPath.row]
        
        if AppUISettings.overlayMaterialFiles.contains(layerOptions.filename) {
            layerOptions.hasTransparency = true
        } else {
            layerOptions.hasTransparency = false
        }
        //filenameLabel.text = layerOptions.filename
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
    }
    
    @IBAction func speedButtonPressed(sender: UIButton) {
        let faceLayer = myFaceLayer()
        guard let layerOptions = faceLayer.layerOptions as? ImageBackgroundLayerOptions else { return }
        
        let valueToAdd:Float = 0.1
        let originalSpeed = layerOptions.anglePerSec
        var newSpeed = originalSpeed
        
        func roundedValue(val:Float) -> Float {
            return Float(round(50*val)/50)
        }
        if sender == rotationSpeedLower {
            if roundedValue(val: originalSpeed - valueToAdd) > AppUISettings.imageRotationSpeedSettigsSliderMin {
                newSpeed = roundedValue(val: originalSpeed - valueToAdd)
            } else {
                newSpeed = AppUISettings.imageRotationSpeedSettigsSliderMin
            }
        }
        if sender == rotationSpeedFaster {
            if roundedValue(val: originalSpeed + valueToAdd) < AppUISettings.imageRotationSpeedSettigsSliderMax {
                newSpeed = roundedValue(val: originalSpeed + valueToAdd)
            } else {
                newSpeed = AppUISettings.imageRotationSpeedSettigsSliderMax
            }
        }
        
        if (newSpeed != originalSpeed) {
            //add to undo stack for actions to be able to undo
            SettingsViewController.addToUndoStack()
            
            layerOptions.anglePerSec = newSpeed
            rotationSpeedLabel.text = String(layerOptions.anglePerSec)
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingTypeString,"layerIndex":myLayerIndex()!])
        }
    }
    
//    @IBAction func speedSliderValueDidChange(sender: UISlider ) {
//        let faceLayer = myFaceLayer()
//        guard let layerOptions = faceLayer.layerOptions as? ImageBackgroundLayerOptions else { return }
//
//        let roundedValue = Float(round(50*sender.value)/50)
//        if roundedValue != layerOptions.anglePerSec {
//            //add to undo stack for actions to be able to undo
//            SettingsViewController.addToUndoStack()
//
//            debugPrint("slider value:" + String( roundedValue ) )
//            layerOptions.anglePerSec = roundedValue
//            let layerIndex = myLayerIndex() ?? 0
//            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil,
//                                            userInfo:["settingType":settingTypeString ,"layerIndex":layerIndex])
//        }
//    }
    
    func selectCameraButton() {
        cameraButton.layer.borderWidth = 2.0
        cameraButton.layer.borderColor = UIColor.init(hexString: AppUISettings.settingHighlightColor).cgColor
    }
    
    func unSelectCameraButton() {
        hasTransparencySwitch.isEnabled = false
        cameraButton.setBackgroundImage(UIImage.init(named: "cameraIcon"), for: UIControl.State.normal)
        cameraButton.layer.borderWidth = 0.0
        cameraButton.layer.borderColor = UIColor.clear.cgColor
    }
    
    override func setupUIForFaceLayer(faceLayer: FaceLayer) {
        super.setupUIForFaceLayer(faceLayer: faceLayer) // needs title outlet to function
        
        guard let layerOptions = faceLayer.layerOptions as? ImageBackgroundLayerOptions else { return }
        
//        rotationSpeedSlider.minimumValue = AppUISettings.imageRotationSpeedSettigsSliderMin
//        rotationSpeedSlider.maximumValue = AppUISettings.imageRotationSpeedSettigsSliderMax
//        rotationSpeedSlider.value = layerOptions.anglePerSec

        rotationSpeedLabel.text = String(layerOptions.anglePerSec)
        
        shapeNameLabel.text = FaceBackgroundNode.descriptionForType(layerOptions.backgroundType)
        
        hasTransparencySwitch.isOn = layerOptions.hasTransparency
        hasTransparencySwitch.isEnabled = layerOptions.hasTransparency
        
        if faceLayer.filenameForImage != "" {
            //filenameLabel.text = faceLayer.filenameForImage
            imageSelectionCollectionView.deselectAll(animated: true)
            if let cameraImage = UIImage.getImageFor(imageName: faceLayer.filenameForImage) {
                let resizedImage = AppUISettings.imageWithImage(image: cameraImage, fitToSize: cameraButton.frame.size)
                cameraButton.setBackgroundImage(resizedImage, for: UIControl.State.normal)
            }
            selectCameraButton()
        } else {
            unSelectCameraButton()
            
            if let meterialsIndex = materialFiles.index(of: layerOptions.filename) {
                //filenameLabel.text = layerOptions.filename
                let indexPath = IndexPath.init(row: meterialsIndex, section: 0)
                imageSelectionCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
            }
        }
        
    }
    
    
}
