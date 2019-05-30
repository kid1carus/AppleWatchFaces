//
//  WatchPreviewViewController.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 10/28/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import Foundation
import SpriteKit

class WatchPreviewViewController: UIViewController {

    @IBOutlet var skView: SKView!
    
    var timeTravelTimer = Timer()
    var timeTravelSpeed:CGFloat = 0.0
    
    static let settingsNudgedNotificationName = Notification.Name("settingsNudged")
    static let settingsLayerAdjustNotificationName = Notification.Name("settingsLayerAdjusted")
    
    static let settingsSelectedLayerNotificationName = Notification.Name("settingsSelectedLayer")
    
    @IBAction func respondToTapGesture(gesture: UITapGestureRecognizer) {
        //determine which layer is highlighted
        guard gesture.state == .ended else { return }
        let tapLoc = gesture.location(in: skView)
        let convert = self.skView.convert(tapLoc, to: skView.scene!)
        guard let nodesAtLoc = skView.scene?.nodes(at: convert) else { return }
        guard let topNode = nodesAtLoc.first else { return }
        guard let watchNode = skView.scene?.childNode(withName: "watchFaceNode") else { return }
        
        for (index,layerNode) in watchNode.children.enumerated() {
            if topNode.inParentHierarchy(layerNode) {
                //debugPrint("tapped on layer item:" + index.description + " name: " + layerNode.name!)
                NotificationCenter.default.post(name: WatchPreviewViewController.settingsSelectedLayerNotificationName, object: nil, userInfo:["faceLayerIndex":index])
            }
        }
    }
    
    @objc func onSettingsNudgedNotification(notification:Notification)
    {
        //update values
        if let data = notification.userInfo as? [String: Int] {
            if let index = data["faceLayerIndex"] {
                //do conditional drawing if needed
                if let scene = skView.scene {
                    if let watchFaceNode = scene.childNode(withName: "watchFaceNode") as? WatchFaceNode {
                        let faceSetting = SettingsViewController.currentFaceSetting
                        watchFaceNode.positionLayer(faceSetting: faceSetting, index:index )
                    }
                }
            }
        }
    }
    
    @objc func onSettingsLayerAdjustedNotification(notification:Notification) {
        //update values
        if let data = notification.userInfo as? [String: Int], let index = data["faceLayerIndex"], let adjustmentTypeRaw = data["adjustmentType"],
            let adjustmentType = WatchFaceNode.LayerAdjustmentType(rawValue: adjustmentTypeRaw) {
            //do conditional drawing if needed
            if let scene = skView.scene, let watchFaceNode = scene.childNode(withName: "watchFaceNode") as? WatchFaceNode {
                    let faceSetting = SettingsViewController.currentFaceSetting
                    watchFaceNode.adjustLayer(faceSetting: faceSetting, index:index, adjustmentType: adjustmentType )
                }
            }
    }
    
    @objc func timeTravelMovementTick() {
        let timeInterval = TimeInterval.init(exactly: Int(timeTravelSpeed))!
        ClockTimer.currentDate.addTimeInterval(timeInterval)
        
        if let skWatchScene = self.skView.scene as? SKWatchScene {
            skWatchScene.forceToTime()
        }
    }
    
    
    @IBAction func respondToPanGesture(gesture: UIPanGestureRecognizer) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let clockTimer = appDelegate.clockTimer
        
        if gesture.state == .began {
            clockTimer.stopTimer()
            let duration = 1.0/24 //smaller = faster updates
            
            timeTravelTimer.invalidate()
            timeTravelTimer = Timer.scheduledTimer( timeInterval: duration, target:self, selector: #selector(WatchPreviewViewController.timeTravelMovementTick), userInfo: nil, repeats: true)
        }
        if gesture.state == .changed {
            let translationPoint = gesture.translation(in: skView)
            timeTravelSpeed = translationPoint.y * 10.0
        }
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            clockTimer.startTimer()
            
            timeTravelTimer.invalidate()
            
            ClockTimer.currentDate = Date()
            if let skWatchScene = self.skView.scene as? SKWatchScene {
                skWatchScene.forceToTime()
            }
        }
    }
    
    func stopTimeForScreenShot() {
//        if let watchScene = skView.scene as? SKWatchScene {
//            watchScene.stopTimeForScreenShot()
//        }
    }
    
    func resumeTime() {
//        if let watchScene = skView.scene as? SKWatchScene {
//            watchScene.resumeTime()
//        }
    }
    
    func makeThumb( imageName:String, cornerCrop: Bool ) -> Bool {
        //let newView = skView.snapshotView(afterScreenUpdates: true)
        if let newImage = skView?.snapshot {
            return newImage.save(imageName: imageName, cornerCrop: cornerCrop)
        } else {
            return false
        }
    }
    
    func redraw() {
        if let watchScene = skView.scene as? SKWatchScene {
            watchScene.redraw(faceSetting: SettingsViewController.currentFaceSetting)
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
                switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.right:
                    print("Swiped right")
                    NotificationCenter.default.post(name: SettingsViewController.settingsPreviewSwipedNotificationName, object: nil, userInfo:["action":"prevClock"])
                    //settingsViewController?.prevClock()
                case UISwipeGestureRecognizer.Direction.left:
                    print("Swiped left")
                    NotificationCenter.default.post(name: SettingsViewController.settingsPreviewSwipedNotificationName, object: nil, userInfo:["action":"nextClock"])
                    //settingsViewController?.nextClock()
                case UISwipeGestureRecognizer.Direction.up:
                    print("Swiped up")
                    NotificationCenter.default.post(name: SettingsViewController.settingsPreviewSwipedNotificationName, object: nil, userInfo:["action":"sendSetting"])
                    //settingsViewController?.sendSettingAction(sender: UIButton() )
                default:
                    break
                }
        }
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        // Application is back in the foreground
        
        // force watch to correct time without any animation after resuming
        //  https://github.com/orff/AppleWatchFaces/issues/12
        if let watchScene = skView.scene as? SKWatchScene {
            watchScene.forceToTime()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //make the watch frame look
        skView.layer.cornerRadius = AppUISettings.watchFrameCornerRadius
        skView.layer.borderWidth = AppUISettings.watchFrameBorderWidth
        skView.layer.borderColor = AppUISettings.watchFrameBorderColor
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(WatchPreviewViewController.respondToSwipeGesture(gesture:) ))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(WatchPreviewViewController.respondToSwipeGesture(gesture:) ))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(WatchPreviewViewController.respondToSwipeGesture(gesture:) ))
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        self.view.addGestureRecognizer(swipeUp)
        
        // Load the SKScener
        if let scene = SKWatchScene(fileNamed: "SKWatchScene") {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            skView.presentScene(scene)
        }
        
        //debug options
        skView.showsFPS = false
        skView.showsNodeCount = false
    
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSettingsNudgedNotification(notification:)),
                                               name: WatchPreviewViewController.settingsNudgedNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSettingsLayerAdjustedNotification(notification:)),
                                               name: WatchPreviewViewController.settingsLayerAdjustNotificationName, object: nil)
        
    }

}
