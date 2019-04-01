//
//  UIBrightnessViewController.swift
//  Clockology
//
//  Created by Michael Hill on 3/31/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit

class UIBrightnessViewController: UIViewController {
    
    var timeSinceLastBrightNessUpdate:UInt64 = DispatchTime.now().uptimeNanoseconds
    var usersBrightness = UIScreen.main.brightness // save user brightness when we enter to restore on exit
    var clockBrightness = UIScreen.main.brightness // save temp brightness when lighting up for settings
    
    func storeBrightness() {
        debugPrint("storeBrightness")
        usersBrightness = UIScreen.main.brightness
    }
    
    func restoreBrightness(level: CGFloat) {
        debugPrint("REstoreBrightness")
        UIScreen.main.animateBrightness(to: level)
        //UIScreen.main.brightness = usersBrightness
    }
    
    func setBrightness( bright:CGFloat) {
        var level:CGFloat = bright
        if bright>1.0 {
            level = 1.0
        }
        if bright<0 {
            level = 0.0
        }
        //debugPrint("bright:" + level.description)
        UIScreen.main.brightness = level
    }
    
    @objc func applicationWillEnterForeground() {
        storeBrightness()
    }
    
    @objc func applicationWillResignActive() {
        restoreBrightness(level: usersBrightness)
    }
}

extension UIScreen {
    
    public func animateBrightness(to value: CGFloat) {
        let step: CGFloat = 0.1
        
        guard abs(UIScreen.main.brightness - value) > step else { return }
        
        let delta = UIScreen.main.brightness > value ? -step : step
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            UIScreen.main.brightness += delta
            self.animateBrightness(to: value)
        }
    }
}

