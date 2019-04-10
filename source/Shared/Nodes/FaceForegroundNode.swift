//
//  FaceForegroundNode.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 3/20/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import SpriteKit
import SceneKit
import WatchKit
import UIKit

enum PhysicsFieldTypes: String {
    case Spring,
    Noise,
    LinearGravity,
    RadialGravity,
    None
    
    static let userSelectableValues = [Spring, Noise, LinearGravity, None]
}

enum FaceForegroundTypes: String {
    case AnimatedPong, AnimatedStarField, AnimatedSnowField, AnimatedPhysicsField,
    None
    
    static let userSelectableValues = [AnimatedPong, AnimatedStarField, AnimatedSnowField, AnimatedPhysicsField, None]
    
    static let randomizableValues = [None]
    
    static func random() -> FaceForegroundTypes {
        let randomIndex = Int(arc4random_uniform(UInt32(randomizableValues.count)))
        return randomizableValues[randomIndex]
    }
}

class FaceForegroundNode: SKSpriteNode {
    
    var foregroundType:FaceForegroundTypes = .None
    
    func isPhysicsField(type : FaceForegroundTypes) -> Bool {
        return (type == .AnimatedPhysicsField)
    }
    
    static func getFieldTypeForForegroundType( foregroundType: FaceForegroundTypes) -> PhysicsFieldTypes {
        return .Spring
    }

    static func descriptionForPhysicsFields(_ fieldType: PhysicsFieldTypes) -> String {
        var typeDescription = ""
        
        if (fieldType == .LinearGravity)  { typeDescription = "Push" }
        if (fieldType == .Noise)  { typeDescription = "Noise" }
        if (fieldType == .RadialGravity)  { typeDescription = "GravIn" }
        if (fieldType == .Spring)  { typeDescription = "Magnet" }
        if (fieldType == .None)  { typeDescription = "None" }
        
        return typeDescription
    }
    
    static func descriptionForType(_ nodeType: FaceForegroundTypes) -> String {
        var typeDescription = ""
        
        if (nodeType == .AnimatedPong)  { typeDescription = "Animated: Pong Game" }
        if (nodeType == .AnimatedStarField)  { typeDescription = "Animated: Starfield" }
        if (nodeType == .AnimatedSnowField)  { typeDescription = "Animated: Snow Falling" }
        if (nodeType == .AnimatedPhysicsField)  { typeDescription = "Animated: Physics Field" }
        if (nodeType == .None)  { typeDescription = "None" }
        
        return typeDescription
    }
    
    static func physicFieldsTypeDescriptions() -> [String] {
        var typeDescriptionsArray = [String]()
        for nodeType in PhysicsFieldTypes.userSelectableValues {
            typeDescriptionsArray.append(descriptionForPhysicsFields(nodeType))
        }
        
        return typeDescriptionsArray
    }
    
    static func typeDescriptions() -> [String] {
        var typeDescriptionsArray = [String]()
        for nodeType in FaceForegroundTypes.userSelectableValues {
            typeDescriptionsArray.append(descriptionForType(nodeType))
        }
        
        return typeDescriptionsArray
    }
    
    static func typeKeys() -> [String] {
        var typeKeysArray = [String]()
        for nodeType in FaceForegroundTypes.userSelectableValues {
            typeKeysArray.append(nodeType.rawValue)
        }
        
        return typeKeysArray
    }
    
    func positionHands( min: CGFloat, hour: CGFloat, force: Bool ) {
        
        if self.foregroundType == .AnimatedPong {
            if force {
                if let pongNode = self.childNode(withName: "pongGameNode") as? PongGameNode {
                    pongNode.updateTime()
                    pongNode.resetLevel() // makes it jiggle in time travelling
                }
            }
        }
    }
    
    init(foregroundType: FaceForegroundTypes, material: String, material2: String, strokeColor: SKColor, lineWidth: CGFloat, shapeType: OverlayShapeTypes, itemSize: CGFloat, itemStrength: CGFloat ) {
        
        super.init(texture: nil, color: SKColor.clear, size: CGSize.init())
        
        self.foregroundType = foregroundType
        
        let screenSize = AppUISettings.getScreenBoundsForImages()
        //let xBounds = (screenSize.width / 2.0).rounded()
        let yBounds = (screenSize.height / 2.0).rounded()
        
        let mainColor = SKColor.init(hexString: material)
        let medColor = mainColor.withAlphaComponent(0.65)
        let darkColor = mainColor.withAlphaComponent(0.3)
        
        if (isPhysicsField(type: foregroundType)) {
            //A layer of a physic blobs
            let fieldNode = SKCropNode()
            fieldNode.name = "physicsFieldNode"
            let physicsShapeSize:CGSize = CGSize.init(width: itemSize, height: itemSize)
            let physicsNode = PhysicsNode.init(size: screenSize, material: material, strokeColor: strokeColor, lineWidth: lineWidth, physicsShapeSize: physicsShapeSize, shapeType: shapeType )
            fieldNode.addChild(physicsNode)
            
            let width = screenSize.width+lineWidth
            let height = screenSize.height+lineWidth
            let frameNodeRect =  CGRect.init(x: -width/2, y: -height/2, width: width, height: height)
            let frameNode = SKShapeNode.init(rect:frameNodeRect)
            
            //green frame for settings UI
            if (lineWidth>0) {
                //draw it as a shape, no background!
                frameNode.fillColor = SKColor.black
                frameNode.strokeColor = strokeColor
                frameNode.lineWidth = lineWidth
                frameNode.zPosition = CGFloat(WatchFaceNode.PartsZPositions.background.rawValue)
                
                fieldNode.maskNode = frameNode //TODO: this works ouside of this if block but stops backgrounds
                fieldNode.addChild(frameNode)
            }
            
            self.addChild(fieldNode)
        }
        
        if (foregroundType == .AnimatedStarField) {
            //A layer of a star field
            let starfieldNode = SKCropNode()
            starfieldNode.name = "starfieldNode"
    
            let mult = itemSize / 4
            
            starfieldNode.addChild(starfieldEmitterNode(speed: -28 * itemStrength, lifetime: yBounds / 5 / (itemStrength+0.1), scale: 0.17 * mult, birthRate: 2, color: mainColor))
            
            //A second layer of stars
            var emitterNode = starfieldEmitterNode(speed: -22 * itemStrength, lifetime: yBounds / 3 / (itemStrength+0.1), scale: 0.12 * mult, birthRate: 4, color: medColor)
            emitterNode.zPosition = CGFloat(WatchFaceNode.PartsZPositions.background.rawValue-2)
            starfieldNode.addChild(emitterNode)
            
            //A third layer
            emitterNode = starfieldEmitterNode(speed: -13 * itemStrength, lifetime: yBounds / (itemStrength+0.1), scale: 0.09 * mult, birthRate: 12, color: darkColor)
            starfieldNode.addChild(emitterNode)
            
            let width = screenSize.width+lineWidth
            let height = screenSize.height+lineWidth
            
            let frameNodeRect =  CGRect.init(x: -width/2, y: -height/2, width: width, height: height)
            let frameNode = SKShapeNode.init(rect:frameNodeRect)
            
            //green frame for settings UI
            if (lineWidth>0) {
                //draw it as a shape, no background!
                frameNode.fillColor = SKColor.black
                frameNode.strokeColor = strokeColor
                frameNode.lineWidth = lineWidth
                frameNode.zPosition = CGFloat(WatchFaceNode.PartsZPositions.background.rawValue-2)
                
                starfieldNode.addChild(frameNode)
                
                starfieldNode.maskNode = frameNode
            }
            
            self.addChild(starfieldNode)
        }
        
        if (foregroundType == .AnimatedSnowField) {
            //A layer of a snow
            let fieldNode = SKCropNode()
            fieldNode.name = "snowfieldNode"
            
            let mult = itemSize / 4
            fieldNode.addChild(snowfieldEmitterNode(speed: -35 * itemStrength, lifetime: yBounds / 5 / (itemStrength+0.1), scale: 0.17 * mult, birthRate: 4, color: mainColor))
            
            //A second layer of stars
            var emitterNode = snowfieldEmitterNode(speed: -30 * itemStrength, lifetime: yBounds / 3 / (itemStrength+0.1), scale: 0.12 * mult, birthRate: 8, color: medColor)
            emitterNode.zPosition = -10
            fieldNode.addChild(emitterNode)
            
            //A third layer
            emitterNode = snowfieldEmitterNode(speed: -19 * itemStrength, lifetime: yBounds / (itemStrength+0.1), scale: 0.09 * mult, birthRate: 16, color: darkColor)
            fieldNode.addChild(emitterNode)
            
            let width = screenSize.width+lineWidth
            let height = screenSize.height+lineWidth
            let frameNodeRect =  CGRect.init(x: -width/2, y: -height/2, width: width, height: height)
            let frameNode = SKShapeNode.init(rect:frameNodeRect)
            
            //green frame for settings UI
            if (lineWidth>0) {
                //draw it as a shape, no background!
                frameNode.fillColor = SKColor.black
                frameNode.strokeColor = strokeColor
                frameNode.lineWidth = lineWidth
                frameNode.zPosition = CGFloat(WatchFaceNode.PartsZPositions.background.rawValue-2)
                
                fieldNode.maskNode = frameNode //TODO: this works ouside of this if block but stops backgrounds
                fieldNode.addChild(frameNode)
            }
            
            self.addChild(fieldNode)
        }
        
        if (foregroundType == .AnimatedPong) {
            
            let pongGameNode = PongGameNode.init(size: AppUISettings.getScreenBoundsForImages(), material: material, strokeColor: strokeColor, lineWidth: lineWidth)
            pongGameNode.name = "pongGameNode"
            pongGameNode.zPosition = CGFloat(WatchFaceNode.PartsZPositions.foreground.rawValue)
            
            if (lineWidth>0) {
                let size = AppUISettings.getScreenBoundsForImages()
                let width = size.width+lineWidth
                let height = size.height+lineWidth
                let frameNodeRect =  CGRect.init(x: -width/2, y: -height/2, width: width, height: height)
                let frameNode = SKShapeNode.init(rect:frameNodeRect)
                
                //draw it as a shape, no background!
                frameNode.fillColor = SKColor.black
                frameNode.strokeColor = strokeColor
                frameNode.lineWidth = lineWidth
                //frameNode.zPosition = CGFloat(WatchFaceNode.PartsZPositions.foreground.rawValue)
                
                pongGameNode.addChild(frameNode)
            }
            
            self.addChild(pongGameNode)
        }
        
    }
    
    //Creates a new star field
    func starfieldEmitterNode(speed: CGFloat, lifetime: CGFloat, scale: CGFloat, birthRate: CGFloat, color: SKColor) -> SKEmitterNode {
        
        let size = AppUISettings.getScreenBoundsForImages()
        let starImage = UIImage.init(named: "StarForEmitter.png")!
        
        let texture = SKTexture.init(image: starImage)
        texture.filteringMode = .nearest
        
        let emitterNode = SKEmitterNode()
        emitterNode.particleTexture = texture
        emitterNode.particleBirthRate = birthRate
        emitterNode.particleColor = color
        emitterNode.particleLifetime = lifetime
        emitterNode.particleSpeed = speed
        emitterNode.particleScale = scale
        emitterNode.particleColorBlendFactor = 1
        emitterNode.position = CGPoint(x: -size.width/2, y: 0)
        emitterNode.particlePositionRange = CGVector(dx: size.height, dy: 0)
        emitterNode.particleSpeedRange = 16.0
        
        //Rotates the stars
        emitterNode.particleAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.rotate(byAngle: CGFloat(-Double.pi/4), duration: 1),
            SKAction.rotate(byAngle: CGFloat(Double.pi/4), duration: 1)]))
        
        //Causes the stars to twinkle
        let twinkles = 20
        let colorSequence = SKKeyframeSequence(capacity: twinkles*2)
        let twinkleTime:CGFloat = 0.25
        for i in 0..<twinkles {
            colorSequence.addKeyframeValue(color,time: CGFloat(i) * 2 * twinkleTime / 2)
            colorSequence.addKeyframeValue(color.withAlphaComponent(0.7), time: (CGFloat(i) * 2 + 1) * twinkleTime / 2)
        }
        emitterNode.particleColorSequence = colorSequence
        
        emitterNode.advanceSimulationTime(TimeInterval(lifetime))
        emitterNode.zRotation = CGFloat(Double.pi/2)
        return emitterNode
    }
    
    //Creates a new snow field
    func snowfieldEmitterNode(speed: CGFloat, lifetime: CGFloat, scale: CGFloat, birthRate: CGFloat, color: SKColor) -> SKEmitterNode {
        
        let size = AppUISettings.getScreenBoundsForImages()
        let starImage = UIImage.init(named: "SnowForEmitter.png")!
        
        let texture = SKTexture.init(image: starImage)
        texture.filteringMode = .nearest
        
        let emitterNode = SKEmitterNode()
        emitterNode.particleTexture = texture
        emitterNode.particleBirthRate = birthRate
        emitterNode.particleColor = color
        emitterNode.particleLifetime = lifetime
        emitterNode.particleSpeed = speed
        emitterNode.emissionAngleRange = 4.0 // causes it to fall side-to-side
        emitterNode.particleScale = scale
        emitterNode.particleColorBlendFactor = 1
        emitterNode.position = CGPoint(x: 0, y: size.height/2)
        emitterNode.particlePositionRange = CGVector(dx: size.width, dy: 0)
        emitterNode.particleSpeedRange = 16.0
        
        emitterNode.advanceSimulationTime(TimeInterval(lifetime))
        return emitterNode
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

