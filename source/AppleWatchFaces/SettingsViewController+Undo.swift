//
//  SettingsViewController+Undo.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/17/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit
import WatchConnectivity

extension SettingsViewController {
    
    func setUndoRedoButtonStatus() {
        //debugPrint("undoArray count:" + SettingsViewController.undoArray.count.description)
        if SettingsViewController.undoArray.count>0 {
            undoButton.isEnabled = true
        } else {
            undoButton.isEnabled = false
        }
        if SettingsViewController.redoArray.count > 0 {
            redoButton.isEnabled = true
        } else {
            redoButton.isEnabled = false
        }
    }
    
    static func addToUndoStack() {
        undoArray.append(SettingsViewController.currentFaceSetting.clone()!)
        redoArray = []
    }
    
    static func clearUndoStack() {
        undoArray = []
        redoArray = []
    }
    
    func clearUndoAndUpdateButtons() {
        SettingsViewController.clearUndoStack()
        setUndoRedoButtonStatus()
    }
    
    @IBAction func redo() {
        guard let lastSettings = SettingsViewController.redoArray.popLast() else { return } //current setting
        SettingsViewController.undoArray.append(SettingsViewController.currentFaceSetting)
        
        SettingsViewController.currentFaceSetting = lastSettings
        redrawPreviewClock() //show correct clockr
        redrawSettingsTable() //show new title
        setUndoRedoButtonStatus()
    }
    
    @IBAction func undo() {
        guard let lastSettings = SettingsViewController.undoArray.popLast() else { return } //current setting
        SettingsViewController.redoArray.append(SettingsViewController.currentFaceSetting)
        
        SettingsViewController.currentFaceSetting = lastSettings
        redrawPreviewClock() //show correct clockr
        redrawSettingsTable() //show new data
        setUndoRedoButtonStatus()
    }
    
}
