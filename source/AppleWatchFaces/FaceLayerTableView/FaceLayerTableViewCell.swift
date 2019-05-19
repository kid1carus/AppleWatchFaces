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
    
    func returnFromAction( actionName: String, itemChosen: Int) {
        debugPrint("returnFromAction not overriden")
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
    
    func redrawColorsForColorCollectionView( colorCollectionView: UICollectionView) {
        if let cdc = colorCollectionView.dataSource as? ColorCollectionDataSource {
            //reset the colors
            cdc.faceColors = SettingsViewController.currentFaceSetting.faceColors
            colorCollectionView.reloadData()
        }
    }
    
    func selectColorForColorCollectionView( colorCollectionView: UICollectionView, desiredIndex: Int) {
        //select current item
        let indexPath = IndexPath.init(row: desiredIndex, section: 0)
        colorCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
    }
    
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
