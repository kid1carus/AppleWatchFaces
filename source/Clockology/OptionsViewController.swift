//
//  SettingsViewController.swift
//  Clockology
//
//  Created by Michael Hill on 4/6/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {

    weak var screenSaverController:ScreenSaverController?
    @IBOutlet var optionShowAdvanced: UISwitch!
    
//    @IBAction func regenerateThumbs() {
//        
//        if let ssVC = screenSaverController {
//            ssVC.currentNavDesination = .EditList
//            self.navigationController?.popViewController(animated: true)
//        }
//    
//    }
    
    @IBAction func showAdvancedOptionsSwitchDidChange( sender: UISwitch ) {
        Defaults.saveAdvancedOption(showAdvanced: sender.isOn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let options = Defaults.getOptions()
        
        if let showAdvanced = options.showAdvancedOptionsKey {
            optionShowAdvanced.isOn = showAdvanced
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
