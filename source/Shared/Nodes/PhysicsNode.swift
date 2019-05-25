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
    
    init(size: CGSize, material: String, strokeColor: SKColor, lineWidth: CGFloat, physicsShapeSize: CGSize, shapeType: OverlayShapeTypes) {
        super.init(texture: nil, color: SKColor.clear, size: size)
        
        let size = AppUISettings.getScreenBoundsForImages()
        
        //draw shapes
        for _ in 0 ... 100 {
            let r = CGFloat(Double(arc4random()) / 0xFFFFFFFF)
            let xPos = r * size.width
            let r2 = CGFloat(Double(arc4random()) / 0xFFFFFFFF)
            let yPos = r2 * size.height
            
            let newShape:SKNode = SKNode.init()

            let labelNode = SKLabelNode.init(text: ParticleFieldLayerOptions.descriptionForOverlayShapeType(shapeType) )
            labelNode.fontColor = SKColor.init(hexString: material)
            labelNode.xScale = physicsShapeSize.width * ParticleFieldLayerOptions.multiplierForOverlayShape(shapeType: shapeType)
            labelNode.yScale = physicsShapeSize.height * ParticleFieldLayerOptions.multiplierForOverlayShape(shapeType: shapeType)
            newShape.addChild(labelNode)
            
            let physicsBody = SKPhysicsBody.init(rectangleOf: physicsShapeSize)
            //physicsBody.mass = 2.0
            physicsBody.restitution = 1.0
            //clamp mass to make it push
            if physicsBody.mass < 0.0004 {
                physicsBody.mass = 0.0004
            }
            
            newShape.physicsBody = physicsBody
            //newShape.physicsBody?.isDynamic = false
            
            newShape.position = CGPoint.init(x: xPos - size.width/2, y: yPos - size.height/2)
            
            self.addChild(newShape)
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationFrameUpdate(notification:)), name: SKWatchScene.sceneSlowFrameUpdateNotificationName, object: nil)
        
    }
    
//    @objc func onNotificationFrameUpdate(notification:Notification) {
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
