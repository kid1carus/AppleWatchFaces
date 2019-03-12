//
//  ViewController.swift
//  Clockology
//
//  Created by Michael Hill on 3/11/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit

class ScreenSaverController: UIViewController {

    var currentClockIndex = 0
    
    weak var previewViewController:PreviewViewController?
    
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

}

