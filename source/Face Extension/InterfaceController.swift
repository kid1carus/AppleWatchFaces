//
//  InterfaceController.swift
//  Face Extension
//
//  Created by Michael Hill on 10/17/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import WatchKit
import WatchConnectivity
import UIKit
import SpriteKit

class InterfaceController: WKInterfaceController, WCSessionDelegate, WKCrownDelegate {
    
    var clockTimer =  ClockTimer()
    @IBOutlet var skInterface: WKInterfaceSKScene!
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    let session = WCSession.default
    
    var currentClockSetting: ClockSetting = ClockSetting.defaults()
    var currentClockIndex: Int = 0
    var crownAccumulator = 0.0
    let crownThreshold = 0.4 // how much rotation is need to switch items
    
    var timeTravelTimer = Timer()
    var timeTravelSpeed:CGFloat = 0.0
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        crownAccumulator += rotationalDelta
        timeTravelSpeed = CGFloat(crownAccumulator) * 10.0
        //debugPrint("crownAcc: " + crownAccumulator.description + " timeSpeed:" + timeTravelSpeed.description)
        
        if !timeTravelTimer.isValid {
            startTimeTravel()
        }

    }
    
    func redrawCurrent(transition: Bool, direction: SKTransitionDirection) {
        
        if transition {
            if let watchScene = SKWatchScene(fileNamed: "SKWatchScene") {
                // Set the scale mode to scale to fit the window
                watchScene.scaleMode = .aspectFill
                watchScene.redraw(clockSetting: currentClockSetting)
                // Present the scene
                self.skInterface.presentScene(watchScene, transition: SKTransition.push(with: direction, duration: 0.35))
            }
        } else {
            if let skWatchScene = self.skInterface.scene as? SKWatchScene {
                skWatchScene.redraw(clockSetting: currentClockSetting)
            }
        }
        
    }
    
    @IBAction func nextClock() {
        currentClockIndex = currentClockIndex + 1
        if (UserClockSetting.sharedClockSettings.count <= currentClockIndex) {
            currentClockIndex = 0
        }
        
        currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex]
        redrawCurrent(transition: true, direction: .left)
    }
    
    @IBAction func prevClock() {
        currentClockIndex = currentClockIndex - 1
        if (currentClockIndex<0) {
            currentClockIndex = UserClockSetting.sharedClockSettings.count - 1
        }
        
        currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex]
        redrawCurrent(transition: true, direction: .right)
    }
    
    //sending the whole settings file
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        
        guard let metatdata = file.metadata else  { return } //ignore files sent without metadata
        guard let type = metatdata["type"] as? String else { return } //ignore files sent without metadata["type"]:String
        
        // Create a FileManager instance
        let fileManager = FileManager.default
    
        //handle meterial image sync
        if type == "clockFaceMaterialImage" || type == "clockFaceMaterialSync" {
            guard let filename = metatdata["filename"] as? String else { return }
            
            //always try to delete to allow for replace in place
            //TODO: check for file and same size?
            do {
                try fileManager.removeItem(at: UIImage.getImageURL(imageName: filename))
                //print("Existing image file deleted.")
            } catch {
                //print("Failed to delete existing file:\n\((error as NSError).description)")
            }
            
            do {
                let imageData = try Data(contentsOf: file.fileURL)
                if let newImage = UIImage.init(data: imageData) {
                    if newImage.save(imageName: filename) {
                        //only needed for one off test load, not sync
                        if type == "clockFaceMaterialImage" {
                            //reload existing watch face
                            //debugPrint("redrawing for material image")
                            //redrawCurrent(transition: false, direction: .up)
                        }
                    }
                }
            } catch let error as NSError {
                print("Cant copy fle -- Something went wrong: \(error)")
            }
        }
        
        //handle temporary settings
        if type == "currentClockSettingFile" {
            //try to load a clocksetting from single file sent
            
            var clockSettingsSerializedArray = [JSON]()
            clockSettingsSerializedArray = UserClockSetting.loadSettingArrayFromURL(url: file.fileURL)

            //only load the first one and exit!
            if let firstSerialized = clockSettingsSerializedArray.first {
                print("loaded title from sent file", firstSerialized["title"])
                currentClockSetting = ClockSetting.init(jsonObj: firstSerialized)
                self.redrawCurrent(transition: true, direction: .down)
            }
        }
        
        //handle json settings
        if type == "settingsFile" {
            
//            var imageCount = 0
//            if let imageCountString = metatdata["imageCount"] as? String {
//                imageCount = Int(imageCountString) ?? 0
//            }
            
            //always try to delete to allow for replace in place
            //TODO: check for file and same size?
            do {
                try fileManager.removeItem(at: UserClockSetting.ArchiveURL)
                //print("Existing settings file deleted.")
            } catch {
                //print("Failed to delete existing file:\n\((error as NSError).description)")
            }
            
            do {
                try fileManager.copyItem(at: file.fileURL, to: UserClockSetting.ArchiveURL)
            
                //give this some time to avoid concurrentcy crashes
                //TODO: try to remove this.. test with real watch and simulator
               delay(0.25) {
                    //reload userClockSettings
                    UserClockSetting.loadFromFile()
                    self.currentClockIndex = 0
                    self.currentClockSetting = UserClockSetting.sharedClockSettings[self.currentClockIndex]
                
                    debugPrint("redrawing for settings reload")
                    self.redrawCurrent(transition: true, direction: .up)
               }
            }
                
            catch let error as NSError {
                print("Cant copy new settings file: \(error)")
            }
            
        }

    }
    
    //got one new setting
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        do {
            let jsonObj = try JSON(data: messageData)
            if jsonObj != JSON.null {
                let newClockSetting = ClockSetting.init(jsonObj: jsonObj)
                currentClockSetting = newClockSetting
                self.redrawCurrent(transition: true, direction: .down)
                replyHandler("success".data(using: .utf8) ?? Data.init())
            }
        } catch {
                replyHandler("error".data(using: .utf8) ?? Data.init())
        }
    }
    
    @objc func timeTravelMovementTick() {
        let timeInterval = TimeInterval.init(exactly: Int(timeTravelSpeed))!
        ClockTimer.currentDate.addTimeInterval(timeInterval)
        
        if let skWatchScene = self.skInterface.scene as? SKWatchScene {
            skWatchScene.forceToTime()
        }
    }
    
    func startTimeTravel() {
        clockTimer.stopTimer()
        let duration = 1.0/24 //smaller = faster updates
        
        timeTravelTimer.invalidate()
        timeTravelTimer = Timer.scheduledTimer( timeInterval: duration, target:self, selector: #selector(InterfaceController.timeTravelMovementTick), userInfo: nil, repeats: true)
    }
    
    func stopTimeTravel() {
        clockTimer.startTimer()
        
        timeTravelTimer.invalidate()
        
        ClockTimer.currentDate = Date()
        if let skWatchScene = self.skInterface.scene as? SKWatchScene {
            skWatchScene.forceToTime()
        }
    }
    
    @IBAction func respondToTapGesture(gesture: WKTapGestureRecognizer) {
        if timeTravelTimer.isValid {
            crownAccumulator = 0
            timeTravelSpeed = 0
            stopTimeTravel()
        }
    }
    
    @IBAction func respondToPanGesture(gesture: WKPanGestureRecognizer) {
        
        if gesture.state == .began {
            clockTimer.stopTimer()
            let duration = 1.0/24 //smaller = faster updates
            
            timeTravelTimer.invalidate()
            timeTravelTimer = Timer.scheduledTimer( timeInterval: duration, target:self, selector: #selector(InterfaceController.timeTravelMovementTick), userInfo: nil, repeats: true)
        }
        if gesture.state == .changed {
            let translationPoint = gesture.translationInObject()
            timeTravelSpeed = translationPoint.x * 10.0
        }
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            clockTimer.startTimer()
            
            timeTravelTimer.invalidate()
            
            ClockTimer.currentDate = Date()
            if let skWatchScene = self.skInterface.scene as? SKWatchScene {
                skWatchScene.forceToTime()
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        //create folders to store data later
        AppUISettings.createFolders()
        
        //start timer
        clockTimer.startTimer()
        
        //capture crpwn events
        crownSequencer.delegate = self
        
        //load the last settings
        UserClockSetting.loadFromFile()
        currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex]
        
        setTitle(" ")
        
        // Configure interface objects here.
        session.delegate = self
        session.activate()
        
        
        // Load the SKScene
        if let scene = SKWatchScene(fileNamed: "SKWatchScene") {
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            self.skInterface.presentScene(scene)
            
            //first time draw
            redrawCurrent(transition: false, direction: .left)
        }
    }
    
    override func didAppear() {
        super.didAppear() // important for removing digital time display hack
        
        hideDigitalTime()
        
        //focus the crown to us at last possible moment
        crownSequencer.focus()
    }

    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        skInterface.isPaused = false
        
        // force watch to correct time without any animation
        //  https://github.com/orff/AppleWatchFaces/issues/12
        if let skWatchScene = self.skInterface.scene as? SKWatchScene {
            skWatchScene.forceToTime()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

// Hack in order to disable the digital time on the screen
extension WKInterfaceController{
    func hideDigitalTime(){
        guard let cls = NSClassFromString("SPFullScreenView") else {return}
        let viewControllers = (((NSClassFromString("UIApplication")?.value(forKey:"sharedApplication") as? NSObject)?.value(forKey: "keyWindow") as? NSObject)?.value(forKey:"rootViewController") as? NSObject)?.value(forKey:"viewControllers") as? [NSObject]
        viewControllers?.forEach{
            let views = ($0.value(forKey:"view") as? NSObject)?.value(forKey:"subviews") as? [NSObject]
            views?.forEach{
                if $0.isKind(of:cls){
                    (($0.value(forKey:"timeLabel") as? NSObject)?.value(forKey:"layer") as? NSObject)?.perform(NSSelectorFromString("setOpacity:"),with:CGFloat(0))
                }
            }
        }
    }
}
