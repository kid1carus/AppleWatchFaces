//
//  FaceForegroundSettingCollectionViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 11/17/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit

class FaceForegroundSettingCollectionViewCell: UICollectionViewCell, SKViewDelegate {
    
    @IBOutlet weak var skView : SKView!
    var faceForegroundType: FaceForegroundTypes = .None
    
    var lastRenderTime: TimeInterval = 0
    
    let fps: TimeInterval = 5
    
    public func view(_ view: SKView, shouldRenderAtTime time: TimeInterval) -> Bool {
        
        if time - lastRenderTime >= 1 / fps {
            lastRenderTime = time
            return true
        }
        else {
            return false
        }
        
    }
    
    func redrawScene() {
        if let scene = skView.scene {
            //debugPrint("old scene")
            scene.backgroundColor = SKColor.black
            scene.removeAllChildren()
            
            let scaleMultiplier:CGFloat = 0.0020
        
            if !self.isSelected {
                //use linewidt > 0 to cause it to clip
                let handNode = FaceForegroundNode.init(foregroundType: faceForegroundType, material: "#ddddddff", material2: "#ddddddff", strokeColor: SKColor.clear, lineWidth: 1.0, shapeType: .Circle, itemSize: 8.0, itemStrength: 0)
                handNode.setScale(scaleMultiplier)
                handNode.position = CGPoint.init(x: scene.size.width/2, y: scene.size.width/2)
                scene.addChild(handNode)
            } else {
                let highlightLineWidth = AppUISettings.settingLineWidthBeforeScale * 5.0
                let strokeColor = SKColor.init(hexString: AppUISettings.settingHighlightColor)
                let selectedHandNode = FaceForegroundNode.init(foregroundType: faceForegroundType, material: "#ddddddff", material2: "#ddddddff", strokeColor: strokeColor, lineWidth: highlightLineWidth, shapeType: .Circle, itemSize: 8.0, itemStrength:0)
                
                selectedHandNode.name = "selectedNode"
                selectedHandNode.setScale(scaleMultiplier)
                selectedHandNode.position = CGPoint.init(x: scene.size.width/2, y: scene.size.width/2)
                scene.addChild(selectedHandNode)
            }
        
            //selectedHandNode.isHidden = !cell.isSelected
        
            //try to prevent these from running any simultation
            scene.physicsWorld.speed = 0.0
            scene.isPaused = true
        }
    }
    
    override var isSelected: Bool {
        didSet {
            redrawScene()
        }
    }
    
}

