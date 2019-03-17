//
//  PhysicsNode.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 3/16/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit

class PhysicsNode: SKSpriteNode {

    init(size: CGSize, material: String, strokeColor: SKColor, lineWidth: CGFloat) {
        super.init(texture: nil, color: SKColor.clear, size: size)
        
        let size = FaceBackgroundNode.getScreenBoundsForImages()
        
        //draw shapes
        for _ in 0 ... 150 {
            let r = CGFloat(Double(arc4random()) / 0xFFFFFFFF)
            let xPos = r * size.width
            let r2 = CGFloat(Double(arc4random()) / 0xFFFFFFFF)
            let yPos = r2 * size.height
            
            let newShape = SKShapeNode.init(circleOfRadius: 2.0)
            newShape.fillColor = SKColor.init(hexString: material)
            newShape.lineWidth = 0.0
            
            let physicsBody = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 3.0, height: 3.0))
            physicsBody.restitution = 1.0
            
            newShape.physicsBody = physicsBody
            //newShape.physicsBody?.isDynamic = false
            
            newShape.position = CGPoint.init(x: xPos - size.width/2, y: yPos - size.height/2)
            
            self.addChild(newShape)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationFrameUpdate(notification:)), name: SKWatchScene.sceneSlowFrameUpdateNotificationName, object: nil)
        
    }
    
    @objc func onNotificationFrameUpdate(notification:Notification) {
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
