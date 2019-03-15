//
//  GenerateThumbnailsViewController.swift
//  AppleWatchFaces
//
//  Created by Hill, Michael on 1/30/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit

class GenerateThumbnailsViewController: UIViewController {

    @IBOutlet var skView: SKView!
    @IBOutlet var progressView: UIProgressView!
    var settingsWithoutThumbs:[ClockSetting] = []
    //used when generating thumbnails / etc
    var timerClockIndex = 0
    var timer = Timer()
    var shouldGenerateThemeThumbs:Bool = false
    
    func makeThumb( fileName: String) {
        _ = makeThumb(imageName: fileName, cornerCrop: false)
    }
    
    func makeThumb( imageName:String, cornerCrop: Bool ) -> Bool {
        //let newView = skView.snapshotView(afterScreenUpdates: true)
        if let newImage = skView?.snapshot {
            return newImage.save(imageName: imageName, cornerCrop: cornerCrop)
        } else {
            return false
        }
    }
    
    func generateMissingThumbs() {
        settingsWithoutThumbs = UserClockSetting.settingsWithoutThumbNails()
        if settingsWithoutThumbs.count == 0 {
            // generate all !
            settingsWithoutThumbs = UserClockSetting.sharedClockSettings
        }
    
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(screenshotThumbActionFromTimer), userInfo: nil, repeats: true)
    }
    
    func generateColorThemeThumbs() {
        timerClockIndex = 0
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(screenshotColorThemeActionFromTimer), userInfo: nil, repeats: true)
    }
    
    func generateDecoratorThemeThumbs() {
        timerClockIndex = 0
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(screenshotDecoratorThemeActionFromTimer), userInfo: nil, repeats: true)
    }
    
    // called every time interval from the timer
    @objc func screenshotColorThemeActionFromTimer() {
    
        if (timerClockIndex < UserClockSetting.sharedColorThemeSettings.count) {
            
            let progress = Float(Float(timerClockIndex) / Float(UserClockSetting.sharedColorThemeSettings.count))
            progressView.progress = progress
        
            let setting = ClockSetting.defaults()
            if let firstSetting = UserClockSetting.sharedDecoratorThemeSettings.last {
                setting.applyDecoratorTheme(firstSetting)
            }
            
            let colorTheme = UserClockSetting.sharedColorThemeSettings[timerClockIndex]
            setting.applyColorTheme(colorTheme)
            
            if let watchScene = skView.scene as? SKWatchScene {
                watchScene.redraw(clockSetting: setting)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                _ = self.makeThumb(imageName: colorTheme.filename(), cornerCrop:true )
            })
            timerClockIndex += 1
        } else {
            timer.invalidate()
            
            generateDecoratorThemeThumbs()
        }
    }
    
    // called every time interval from the timer
    @objc func screenshotDecoratorThemeActionFromTimer() {
        
        if (timerClockIndex < UserClockSetting.sharedDecoratorThemeSettings.count) {
            
            let progress = Float(Float(timerClockIndex) / Float(UserClockSetting.sharedDecoratorThemeSettings.count))
            progressView.progress = progress
            
            let setting = ClockSetting.defaults()
            if let firstSetting = UserClockSetting.sharedColorThemeSettings.first {
                setting.applyColorTheme(firstSetting)
            }
            
            let decoratorTheme = UserClockSetting.sharedDecoratorThemeSettings[timerClockIndex]
            setting.applyDecoratorTheme(decoratorTheme)
            
            if let watchScene = skView.scene as? SKWatchScene {
                watchScene.redraw(clockSetting: setting)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                _ = self.makeThumb(imageName: decoratorTheme.filename(), cornerCrop:true )
            })
            timerClockIndex += 1
        } else {
            timer.invalidate()
            
            self.dismiss(animated: true) {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.resumeTimer()
                }
            }
        }
    }
    
    // called every time interval from the timer
    @objc func screenshotThumbActionFromTimer() {
        
        if (timerClockIndex < settingsWithoutThumbs.count) {
            let progress = Float(Float(timerClockIndex) / Float(settingsWithoutThumbs.count))
            progressView.progress = progress
            
            let setting = settingsWithoutThumbs[timerClockIndex]
            if let watchScene = skView.scene as? SKWatchScene {
                watchScene.redraw(clockSetting: setting)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                self.makeThumb(fileName: setting.uniqueID)
            })
            
            timerClockIndex += 1
            
        } else {
            timer.invalidate()
            
            //needs some time to save this so next screen can load it
            delay(0.5) {
                self.dismiss(animated: false) {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.resumeTimer()
                    }
                }
            }
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make the watch frame look
        skView.layer.cornerRadius = AppUISettings.watchFrameCornerRadius
        skView.layer.borderWidth = AppUISettings.watchFrameBorderWidth
        skView.layer.borderColor = AppUISettings.watchFrameBorderColor

        // Load the SKScene
        if let scene = SKWatchScene(fileNamed: "SKWatchScene") {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.stopTimerForScreenShot()
            }
            
            // Present the scene
            skView.presentScene(scene)
        }
        
        //debug options
        skView.showsFPS = false
        skView.showsNodeCount = false

        if shouldGenerateThemeThumbs == true {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.stopTimerForThemeShots()
            }
            generateColorThemeThumbs()
        } else {
            generateMissingThumbs()
        }
    }

}
