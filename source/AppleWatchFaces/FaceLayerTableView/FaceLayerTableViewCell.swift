//
//  DecoratorTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 12/2/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit

class FaceLayerTableViewCell: UITableViewCell {
    
    //var rowIndex:Int=0
    var parentTableview : UITableView?
    @IBOutlet weak var titleLabel: UILabel!
    
    func myLayerIndex()->Int? {
        let myLayer = myFaceLayer()
        return SettingsViewController.currentFaceSetting.faceLayers.index(of: myLayer)
    }
    
    func myFaceLayer()->FaceLayer {
        if let tableView = parentTableview, let indexPath = tableView.indexPath(for: self) {
            return (SettingsViewController.currentFaceSetting.faceLayers[indexPath.row])
        } else {
            debugPrint("** CANT GET index for layer tableCell, might be out of view?")
            return FaceLayer.defaults()
        }
    }
    
    func getColorIndexForColorButton( colorArray: [String], buttonSize: CGSize, position: CGPoint) -> Int {
        let buttonW = buttonSize.width / CGFloat(colorArray.count)
        
        let region = Int(position.x / buttonW)
        return region
    }
    
   func getColoredImage(colorArray: [String], size: CGSize) -> UIImage {
        let rect = CGRect.init(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
    
        let buttonW = size.width / CGFloat(colorArray.count)
    
        for (index,hexString) in colorArray.enumerated() {
            let color = UIColor.init(hexString: hexString)
            context!.setFillColor(color.cgColor)
            
            let buttonRect = CGRect.init(x: buttonW*CGFloat(index), y: 0, width: buttonW, height: size.height)
            
            context!.fill(buttonRect)
        }
    
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    func handleColorButton( colorButton: UIButton, event: UIEvent, settingType: String) {
        let touches = event.touches(for: colorButton)
        let firstTouch = touches?.first
        if let position = firstTouch?.location(in: colorButton) {
            let desiredColorIndex = getColorIndexForColorButton(colorArray: SettingsViewController.currentFaceSetting.faceColors, buttonSize: colorButton.frame.size, position: position)
            
            let faceLayer = myFaceLayer()
            faceLayer.desiredThemeColorIndex = desiredColorIndex
            
            NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:["settingType":settingType,"layerIndex":myLayerIndex()!])
        }
    }
    
    func setupButtonBackgroundForColors( button: UIButton) {
        let coloredImage = getColoredImage(colorArray: SettingsViewController.currentFaceSetting.faceColors, size: button.frame.size )
        button.setBackgroundImage(coloredImage, for: .normal)
    }
    
    func titleText( faceLayer: FaceLayer ) -> String {
        return FaceLayer.descriptionForType(faceLayer.layerType)
    }
    
    func setupUIForFaceLayer( faceLayer: FaceLayer ) {
        //to be implemented by subClasses
        self.titleLabel.text = titleText(faceLayer: faceLayer)
    }
    
    //    override func didMoveToSuperview() {
    //        self.setupUIForClockRingSetting()
    //    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    
    func selectThisCell() {
        if let tableView = parentTableview, let indexPath = tableView.indexPath(for: self) {
            
            if let selectedPath = tableView.indexPathForSelectedRow {
                if selectedPath == indexPath { return } //already selected -- exit early
            }
            
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.none)
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected == true {
            //self.contentView.backgroundColor = UIColor.blue
            self.backgroundColor = UIColor.init(white: 0.1, alpha: 1.0)
        } else {
            //self.contentView.backgroundColor = UIColor.black
            self.backgroundColor = UIColor.init(white: 0.0, alpha: 1.0)
        }
    }
    
}
