//
//  DecoratorPreviewController.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 12/2/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit

class DecoratorPreviewController: UIViewController {

    @IBOutlet var skView: SKView!
    //var editBarButton: UIBarButtonItem = UIBarButtonItem()
    weak var decoratorsTableViewController: DecoratorsTableViewController?
    
    static let ringSettingsChangedNotificationName = Notification.Name("ringSettingsChanged")
    static let ringSettingsEditDetailNotificationName = Notification.Name("ringSettingsEditDetail")
    
    func highlightRing( ringNumber: Int) {
        guard let scene = skView.scene else { return }
        guard let watchFaceNode = scene.childNode(withName: "watchFaceNode") else { return }
    
        var ringChildren:[SKNode] = []
        for childnode in watchFaceNode.children {
            
            if childnode.name == "ringNode" || childnode.name == "textRingNode" {
                //debugPrint("ringNode!" + (childnode.name ?? "") )
                ringChildren.append(childnode)
            }
        }
        
        guard let ringNode = ringChildren[safe: ringNumber] else { return }
        
        for childNode in ringNode.children {
            let bloomUpAction = SKAction.scale(to: 1.5, duration: 0.25)
            bloomUpAction.timingMode = .easeIn
            let bloomDownAction = SKAction.scale(to: 1.0, duration: 0.125)
            bloomUpAction.timingMode = .easeOut
            let combinedAction = SKAction.sequence([bloomUpAction, bloomDownAction])
            
            if ringNode.name == "ringNode" {
                if let indicatorNode = childNode.childNode(withName: "indicatorNode" ) {
                    indicatorNode.run(combinedAction)
                }
            } else {
                childNode.run(combinedAction)
            }
        }
        
    }
    
    func redraw(clockSetting: ClockSetting) {
        
        self.title = String( clockSetting.clockFaceSettings!.ringSettings.count ) + " parts"
        
        let newWatchFaceNode = WatchFaceNode.init(clockSetting: clockSetting, size: CGSize.init(width: 100, height: 100) )
        
        //TODO: figure out whay this is needed
        newWatchFaceNode.position = CGPoint.init(x: 0.5, y: 0.5)
        newWatchFaceNode.setScale(0.0035)
        newWatchFaceNode.hideHands()
        
        if let scene = skView.scene {
            if let oldNode = scene.childNode(withName: "watchFaceNode") {
                oldNode.removeFromParent()
            }
            scene.addChild(newWatchFaceNode)
        }
        
    }
    
    @objc func onSettingChangedNotification(notification:Notification)
    {
        //update values
        if let data = notification.userInfo as? [String: String] {
            if data["settingType"] == "sliderValue" {
                //do conditional drawing if needed
            }
        }
        
        redraw(clockSetting: SettingsViewController.currentClockSetting)
    }
    
    @objc func onSettingEditDetailNotification(notification:Notification)
    {
        
        func showSettingsAlert( title: String, alertActions: [UIAlertAction]) {
            let optionMenu = UIAlertController(title: nil, message: title, preferredStyle: .actionSheet)
            optionMenu.view.tintColor = UIColor.black
            
            for action in alertActions {
                optionMenu.addAction(action)
            }
        
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            optionMenu.addAction(cancelAction)
            
            self.present(optionMenu, animated: true, completion: nil)
        }
        
        if let settingType = notification.userInfo?["settingType"] as? String, settingType == "indicatorType", let decoratorShapeTableViewCell = notification.userInfo?["decoratorShapeTableViewCell"] as? DecoratorShapeTableViewCell  {
            
            var actions:[UIAlertAction] = []
            
            for shapeType in FaceIndicatorTypes.userSelectableValues {
                let newAction = UIAlertAction(title: FaceIndicatorNode.descriptionForType(shapeType), style: .default, handler: { action in
                    decoratorShapeTableViewCell.shapeChosen(shapeType: shapeType)
                } )
                actions.append(newAction)
            }
            
            showSettingsAlert( title: "Choose Shape", alertActions: actions )
        }
        
        if let settingType = notification.userInfo?["settingType"] as? String, settingType == "textType", let decoratorDigitalTimeTableViewCell = notification.userInfo?["decoratorDigitalTimeTableViewCell"] as? DecoratorDigitalTimeTableViewCell  {
            
            var actions:[UIAlertAction] = []
            
            for textType in NumberTextTypes.userSelectableValues {
                let newAction = UIAlertAction(title: NumberTextNode.descriptionForType(textType), style: .default, handler: { action in
                    decoratorDigitalTimeTableViewCell.fontChosen(textType: textType)
                } )
                actions.append(newAction)
            }
            
            showSettingsAlert( title: "Choose Font For Time", alertActions: actions )
        }
        
        if let settingType = notification.userInfo?["settingType"] as? String, settingType == "effectType", let decoratorTextTableViewCell = notification.userInfo?["decoratorDigitalTimeTableViewCell"] as? DecoratorDigitalTimeTableViewCell  {
            
            var actions:[UIAlertAction] = []
            
            for effectType in DigitalTimeEffects.userSelectableValues {
                let newAction = UIAlertAction(title: DigitalTimeNode.descriptionForTimeEffects(effectType), style: .default, handler: { action in
                    decoratorTextTableViewCell.effectChosen(effectType: effectType)
                } )
                actions.append(newAction)
            }
            
            showSettingsAlert( title: "Choose Effect", alertActions: actions )
        }
        
        if let settingType = notification.userInfo?["settingType"] as? String, settingType == "formatType", let decoratorTextTableViewCell = notification.userInfo?["decoratorDigitalTimeTableViewCell"] as? DecoratorDigitalTimeTableViewCell  {
            
            var actions:[UIAlertAction] = []
            
            for formatType in DigitalTimeFormats.userSelectableValues {
                let newAction = UIAlertAction(title: DigitalTimeNode.descriptionForTimeFormats(formatType), style: .default, handler: { action in
                    decoratorTextTableViewCell.formatChosen(formatType: formatType)
                } )
                actions.append(newAction)
            }
            
            showSettingsAlert( title: "Choose Format", alertActions: actions )
        }
        
        if let settingType = notification.userInfo?["settingType"] as? String, settingType == "textType", let decoratorTextTableViewCell = notification.userInfo?["decoratorTextTableViewCell"] as? DecoratorTextTableViewCell  {
            
            var actions:[UIAlertAction] = []
            
            for textType in NumberTextTypes.userSelectableValues {
                let newAction = UIAlertAction(title: NumberTextNode.descriptionForType(textType), style: .default, handler: { action in
                    decoratorTextTableViewCell.fontChosen(textType: textType)
                } )
                actions.append(newAction)
            }
            
            showSettingsAlert( title: "Choose Font", alertActions: actions )
        }
        
        
        
        
    }
    
    func addNewItem( ringType: RingTypes) {
        
        var newItem = ClockRingSetting.defaults()
        
        //TODO: eventually have better defaults for other types
        if ringType == .RingTypeDigitalTime {
            newItem = ClockRingSetting.defaultsDigitalTime()
        }
        
        //copy some things from last item for convenience
        if let lastItem = SettingsViewController.currentClockSetting.clockFaceSettings!.ringSettings.last {
            
            newItem.textType = lastItem.textType
            newItem.textSize = lastItem.textSize
            newItem.ringStaticEffects = lastItem.ringStaticEffects
            newItem.ringMaterialDesiredThemeColorIndex = lastItem.ringMaterialDesiredThemeColorIndex
            
        }
        
        newItem.ringType = ringType
        SettingsViewController.currentClockSetting.clockFaceSettings!.ringSettings.append(newItem)
        redraw(clockSetting: SettingsViewController.currentClockSetting)
        
        if let dtVC = decoratorsTableViewController {
            dtVC.addNewItem(ringType: ringType)
        }
        
    }
    
    @objc func newItem() {
        let optionMenu = UIAlertController(title: nil, message: "New Indicator Item", preferredStyle: .actionSheet)
        optionMenu.view.tintColor = UIColor.black
        
        for ringType in RingTypes.userSelectableValues {
            let newActionDescription = ClockRingSetting.descriptionForRingType(ringType)
            let newAction = UIAlertAction(title: newActionDescription, style: .default, handler: { action in
                self.addNewItem(ringType: ringType)
            } )
            optionMenu.addAction(newAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
//        decoratorsTableViewController.newItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let scene = skView.scene as? SKWatchScene {
            scene.cleanup()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let createButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.compose, target: self, action: #selector(newItem))
        
        if let dtVC = decoratorsTableViewController {
            //set editing mode here! not in controller
            dtVC.setEditing(true, animated: false)
            dtVC.editButtonItem.tintColor = UIColor.orange
            createButton.tintColor = UIColor.orange
            self.navigationItem.rightBarButtonItems = [dtVC.editButtonItem, createButton]
        }
        
        //round the preview watch SKView
        skView.layer.cornerRadius = 28.0
        skView.layer.borderWidth = 4.0
        skView.layer.borderColor = SKColor.darkGray.cgColor
        
        let scene = SKScene.init()
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        // Present the scene
        scene.isPaused = true //dont animate physics
        skView.presentScene(scene)
        
        redraw(clockSetting: SettingsViewController.currentClockSetting)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSettingChangedNotification(notification:)), name: DecoratorPreviewController.ringSettingsChangedNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSettingEditDetailNotification(notification:)), name: DecoratorPreviewController.ringSettingsEditDetailNotificationName, object: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DecoratorsTableViewController {
            decoratorsTableViewController = segue.destination as? DecoratorsTableViewController
            decoratorsTableViewController!.decoratorPreviewController = self
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
