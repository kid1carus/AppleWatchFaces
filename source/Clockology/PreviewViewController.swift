//
//  PreviewViewController.swift
//  Clockology
//
//  Created by Michael Hill on 3/11/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit

class PreviewViewController: UIViewController {
    
    @IBOutlet var skView: SKView!

    
    func redraw() {
        if let watchScene = skView.scene as? SKWatchScene {
            watchScene.redraw(clockSetting: SettingsViewController.currentClockSetting)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the SKScener
        if let watchScene = SKWatchScene(fileNamed: "SKWatchScene") {
            // Set the scale mode to scale to fit the window
            watchScene.scaleMode = .aspectFill
            
            // Present the scene
            skView.presentScene(watchScene)
            
            redraw()
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
