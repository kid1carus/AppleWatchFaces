//
//  FaceOptionsTitleTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/26/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit

class FaceOptionsTitleTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var titleTextField: UITextField!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        //force to always black
        self.contentView.backgroundColor = self.backgroundColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //hello!
        let fullSet = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
        let cleanedText = textField.text?.components(separatedBy: fullSet.inverted).joined()
        let newTitle = cleanedText ?? ""
        
        titleTextField.text = newTitle
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        debugPrint("did end editing title:" + newTitle)
        SettingsViewController.currentFaceSetting.title = newTitle
        
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleTextField.delegate = self
    }

}
