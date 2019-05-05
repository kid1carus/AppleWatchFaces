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
    
    func myFaceLayer()->FaceLayer {
        if let tableView = parentTableview, let indexPath = tableView.indexPath(for: self) {
            return (SettingsViewController.currentFaceSetting.faceLayers[indexPath.row])
        } else {
            debugPrint("** CANT GET index for layer tableCell, might be out of view?")
            return FaceLayer.defaults()
        }
    }
    
    func setupUIForFaceLayer( faceLayer: FaceLayer ) {
        //to be implemented by subClasses
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
