//
//  ViewController.swift
//  Clockology
//
//  Created by Michael Hill on 3/11/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit

class ScreenSaverController: UIViewController, UIGestureRecognizerDelegate {

    var currentClockIndex = 0
    
    weak var previewViewController:PreviewViewController?
    @IBOutlet var panGesture:UIPanGestureRecognizer?
    @IBOutlet var swipeGestureLeft:UISwipeGestureRecognizer?
    @IBOutlet var swipeGestureRight:UISwipeGestureRecognizer?
    
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
        
        let mult:CGFloat = self.view.frame.size.height / 4
        
        if gesture.state == .began {
            
        }
        if gesture.state == .changed {
            let translationPoint = gesture.translation(in: self.view)
            let brightness = 1.0 - translationPoint.y / mult
            setBrightness(bright: brightness)
        }
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            let translationPoint = gesture.translation(in: self.view)
            let brightness = 1.0 - translationPoint.y / mult
            setBrightness(bright: brightness)
        }
    }
    
    @IBAction func nextClock() {
        currentClockIndex = currentClockIndex + 1
        if (UserClockSetting.sharedClockSettings.count <= currentClockIndex) {
            currentClockIndex = 0
        }
        
        SettingsViewController.currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex].clone()!
        redrawPreviewClock()
    }
    
    @IBAction func prevClock() {
        currentClockIndex = currentClockIndex - 1
        if (currentClockIndex<0) {
            currentClockIndex = UserClockSetting.sharedClockSettings.count - 1
        }
        
        SettingsViewController.currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex].clone()!
        redrawPreviewClock()
    }
    
    func redrawPreviewClock() {
        //tell preview to reload
        if previewViewController != nil {
            previewViewController?.redraw()
            //self.showMessage( message: SettingsViewController.currentClockSetting.title)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SettingsViewController.currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex].clone()!
        redrawPreviewClock()
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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

}
