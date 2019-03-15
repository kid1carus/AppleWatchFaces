//
//  ViewController.swift
//  Clockology
//
//  Created by Michael Hill on 3/11/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit

class ScreenSaverController: UIViewController, UIGestureRecognizerDelegate {

    var currentClockIndex = 0
    private var usersBrightness = UIScreen.main.brightness // save user brightness when we enter to restore on exit
    private var clockBrightness = UIScreen.main.brightness // save temp brightness when lighting up for settings
    
    weak var previewViewController:PreviewViewController?
    @IBOutlet var panGesture:UIPanGestureRecognizer?
    @IBOutlet var swipeGestureLeft:UISwipeGestureRecognizer?
    @IBOutlet var swipeGestureRight:UISwipeGestureRecognizer?
    
    @IBOutlet var buttonContainerView: UIView!
    
    @IBAction func showButtons() {
        if self.buttonContainerView.alpha < 1.0 {
            //showing button interface
            self.clockBrightness = UIScreen.main.brightness
            restoreBrightness(level: usersBrightness)
            UIView.animate(withDuration: 0.5) {
                self.buttonContainerView.alpha = 1.0
            }
        } else {
            //hiding button interface
            restoreBrightness(level: clockBrightness)
            UIView.animate(withDuration: 0.5) {
                self.buttonContainerView.alpha = 0.0
            }
        }
    }
    
    @IBAction func nextClock() {
        currentClockIndex = currentClockIndex + 1
        if (UserClockSetting.sharedClockSettings.count <= currentClockIndex) {
            currentClockIndex = 0
        }
        
        SettingsViewController.currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex].clone()!
        redrawPreviewClock(transition: true, direction: .right)
    }
    
    @IBAction func prevClock() {
        currentClockIndex = currentClockIndex - 1
        if (currentClockIndex<0) {
            currentClockIndex = UserClockSetting.sharedClockSettings.count - 1
        }
        
        SettingsViewController.currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex].clone()!
        redrawPreviewClock(transition: true, direction: .left)
    }
    
    func redrawPreviewClock(transition: Bool, direction: SKTransitionDirection) {
        //tell preview to reload
        if previewViewController != nil {
            previewViewController?.redraw(transition: transition, direction: direction)
            //self.showMessage( message: SettingsViewController.currentClockSetting.title)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        storeBrightness()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        restoreBrightness(level: usersBrightness)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storeBrightness()
        buttonContainerView?.alpha = 0.0
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScreenSaverController.showButtons)))
        
        SettingsViewController.currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex].clone()!
        redrawPreviewClock(transition: false, direction: .up)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is PreviewViewController {
            let vc = segue.destination as? PreviewViewController
            previewViewController = vc
        }
        
    }
    
    //hide the home indicator
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    //allow for both gestures at the same time
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panGesture &&
            (otherGestureRecognizer == self.swipeGestureLeft || otherGestureRecognizer == self.swipeGestureRight) {
            return true
        }
        return false
    }
    
    func setBrightness( bright:CGFloat) {
        var level:CGFloat = bright
        if bright>1.0 {
            level = 1.0
        }
        if bright<0 {
            level = 0.0
        }
        debugPrint("bright:" + level.description)
        UIScreen.main.brightness = level
    }
    
    //get brightness offset from PAN
    @IBAction func respondToPanGesture(gesture: UIPanGestureRecognizer) {
        
        //dont adjust levels when buttons are up
        guard buttonContainerView.alpha == 0 else { return }
        
        let mult:CGFloat = self.view.frame.size.height / 0.75
        let current = UIScreen.main.brightness
        
        if gesture.state == .began {
            
        }
        if gesture.state == .changed {
            let translationPoint = gesture.translation(in: self.view)
            let desiredBrightness = current - (translationPoint.y / mult)
            let diff = desiredBrightness-current
            let threshHold:CGFloat = 0.05
            if diff>threshHold || diff<threshHold {
                setBrightness(bright: desiredBrightness)
            }
        }
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            let translationPoint = gesture.translation(in: self.view)
            let desiredBrightness = current - (translationPoint.y / mult)
            setBrightness(bright: desiredBrightness)
        }
    }
    
    func storeBrightness() {
        debugPrint("storeBrightness")
        usersBrightness = UIScreen.main.brightness
    }
    
    func restoreBrightness(level: CGFloat) {
        debugPrint("REstoreBrightness")
        UIScreen.main.animateBrightness(to: level)
        //UIScreen.main.brightness = usersBrightness
    }
    
    @objc private func applicationWillEnterForeground() {
        storeBrightness()
    }
    
    @objc private func applicationWillResignActive() {
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
