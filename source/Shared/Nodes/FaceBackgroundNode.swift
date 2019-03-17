//
//  FaceBackgroundNode.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 11/17/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import SpriteKit
import SceneKit
import WatchKit
import UIKit

enum FaceBackgroundTypes: String {
    case FaceBackgroundTypeFilled, FaceBackgroundTypeDiagonalSplit, FaceBackgroundTypeCircle, FaceBackgroundTypeVerticalSplit, FaceBackgroundTypeHorizontalSplit, FaceBackgroundTypeVerticalGradient, FaceBackgroundTypeHorizontalGradient,
        FaceBackgroundTypeDiagonalGradient, FaceBackgroundTypeAnimatedPong, FaceIndicatorTypeAnimatedStarField, FaceIndicatorTypeAnimatedPhysicsField, FaceIndicatorTypeAnimatedSnowField,
        FaceBackgroundTypeNone
    
    static let userSelectableValues = [FaceBackgroundTypeCircle, FaceBackgroundTypeFilled, FaceBackgroundTypeDiagonalSplit,
                                     FaceBackgroundTypeVerticalSplit, FaceBackgroundTypeHorizontalSplit, FaceBackgroundTypeVerticalGradient, FaceBackgroundTypeHorizontalGradient, FaceBackgroundTypeDiagonalGradient,
                                     FaceBackgroundTypeAnimatedPong, FaceIndicatorTypeAnimatedStarField, FaceIndicatorTypeAnimatedSnowField, FaceIndicatorTypeAnimatedPhysicsField,
                                     
                                     FaceBackgroundTypeNone]
    
    static let randomizableValues = [FaceBackgroundTypeCircle, FaceBackgroundTypeFilled, FaceBackgroundTypeDiagonalSplit,
                                     FaceBackgroundTypeVerticalSplit, FaceBackgroundTypeHorizontalSplit, FaceBackgroundTypeVerticalGradient, FaceBackgroundTypeHorizontalGradient, FaceBackgroundTypeDiagonalGradient,
                                     FaceBackgroundTypeNone]
    
    static func random() -> FaceBackgroundTypes {
        let randomIndex = Int(arc4random_uniform(UInt32(randomizableValues.count)))
        return randomizableValues[randomIndex]
    }
}

class FaceBackgroundNode: SKSpriteNode {
    
    var backgroundType:FaceBackgroundTypes = .FaceBackgroundTypeNone
    
    static func descriptionForType(_ nodeType: FaceBackgroundTypes) -> String {
        var typeDescription = ""
        
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeCircle)  { typeDescription = "Circle" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeFilled)  { typeDescription = "Filled" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeDiagonalSplit)  { typeDescription = "Split Diagonal" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeVerticalSplit)  { typeDescription = "Vertical Split" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeHorizontalSplit)  { typeDescription = "Horizonatal Split" }
        
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeVerticalGradient)  { typeDescription = "Vertical Gradient" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeHorizontalGradient)  { typeDescription = "Horizonal Gradient" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeDiagonalGradient)  { typeDescription = "Diagonal Gradient" }
        
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeAnimatedPong)  { typeDescription = "Animated: Pong Game" }
        if (nodeType == FaceBackgroundTypes.FaceIndicatorTypeAnimatedStarField)  { typeDescription = "Animated: Starfield" }
        if (nodeType == FaceBackgroundTypes.FaceIndicatorTypeAnimatedSnowField)  { typeDescription = "Animated: Snow Falling" }
        if (nodeType == FaceBackgroundTypes.FaceIndicatorTypeAnimatedPhysicsField)  { typeDescription = "Animated: Physics Field" }
        
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeNone)  { typeDescription = "None" }
        
        return typeDescription
    }
    
    static func typeDescriptions() -> [String] {
        var typeDescriptionsArray = [String]()
        for nodeType in FaceBackgroundTypes.userSelectableValues {
            typeDescriptionsArray.append(descriptionForType(nodeType))
        }
        
        return typeDescriptionsArray
    }
    
    static func typeKeys() -> [String] {
        var typeKeysArray = [String]()
        for nodeType in FaceBackgroundTypes.userSelectableValues {
            typeKeysArray.append(nodeType.rawValue)
        }
        
        return typeKeysArray
    }
    
    static func getScreenBoundsForImages() -> CGSize {
        #if os(watchOS)
            let screenBounds = WKInterfaceDevice.current().screenBounds
        //this is needed * ratio to fit 320x390 images to 42 & 44mm
            let overscan:CGFloat = 1.17
            let mult = (390/(screenBounds.height*2)) * overscan
            let ratio = screenBounds.size.height / screenBounds.size.width
            let w = (screenBounds.size.width * mult * ratio).rounded()
            let h = (screenBounds.size.height * mult * ratio).rounded()
        #else
            let w = CGFloat( CGFloat(320) / 1.42 ).rounded()
            let h = CGFloat( CGFloat(390) / 1.42 ).rounded()
        #endif
        
        return CGSize.init(width: w, height: h)
    }
    
    static func filledShapeNode(material: String) -> SKShapeNode {
        let screenSize = FaceBackgroundNode.getScreenBoundsForImages()
        let xBounds = (screenSize.width / 2.0).rounded()
        let yBounds = (screenSize.height / 2.0).rounded()
        
        //rect != shape from path, so draw it from path
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: -xBounds, y: yBounds))
        bezierPath.addLine(to: CGPoint(x: xBounds, y: yBounds))
        bezierPath.addLine(to: CGPoint(x: xBounds, y: -yBounds))
        bezierPath.addLine(to: CGPoint(x: -xBounds, y: -yBounds))
        bezierPath.close()
        
        let shape = SKShapeNode.init(path: bezierPath.cgPath)
        
        //let shape = SKShapeNode.init(rect: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        shape.lineWidth = 0.0
        shape.setMaterial(material: material)
        return shape
    }
    
    func positionHands( min: CGFloat, hour: CGFloat, force: Bool ) {
        
        if self.backgroundType == .FaceBackgroundTypeAnimatedPong {
            if force {
                if let pongNode = self.childNode(withName: "pongGameNode") as? PongGameNode {
                    pongNode.updateTime()
                    pongNode.resetLevel() // makes it jiggle in time travelling
                }
            }
        }
    }
    
    convenience init(backgroundType: FaceBackgroundTypes, material: String) {
        self.init(backgroundType: backgroundType, material: material, material2: "", strokeColor: SKColor.clear, lineWidth: 0.0)
    }
    
    convenience init(backgroundType: FaceBackgroundTypes, material: String, material2: String) {
        self.init(backgroundType: backgroundType, material: material, material2: material2, strokeColor: SKColor.clear, lineWidth: 0.0)
    }
    
    init(backgroundType: FaceBackgroundTypes, material: String, material2: String, strokeColor: SKColor, lineWidth: CGFloat ) {
        
        super.init(texture: nil, color: SKColor.clear, size: CGSize.init())
        
        self.backgroundType = backgroundType
        self.name = "FaceBackground"
        let sizeMultiplier = CGFloat(SKWatchScene.sizeMulitplier)
        let screenSize = FaceBackgroundNode.getScreenBoundsForImages()
        let xBounds = (screenSize.width / 2.0).rounded()
        let yBounds = (screenSize.height / 2.0).rounded()
        
        let mainColor = SKColor.init(hexString: material)
        let medColor = mainColor.withAlphaComponent(0.65)
        let darkColor = mainColor.withAlphaComponent(0.3)
        
        if (backgroundType == FaceBackgroundTypes.FaceIndicatorTypeAnimatedPhysicsField) {
            //A layer of a snow
            let fieldNode = SKCropNode()
            fieldNode.name = "physicsFieldNode"
            fieldNode.addChild(PhysicsNode.init(size: screenSize, material: material, strokeColor: strokeColor, lineWidth: lineWidth))
            
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
                frameNode.zPosition = -2.0
                
                fieldNode.maskNode = frameNode //TODO: this works ouside of this if block but stops backgrounds
                fieldNode.addChild(frameNode)
            }
            
            self.addChild(fieldNode)
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceIndicatorTypeAnimatedStarField) {
            //A layer of a star field
            let starfieldNode = SKCropNode()
            starfieldNode.name = "starfieldNode"
            starfieldNode.addChild(starfieldEmitterNode(speed: -28, lifetime: yBounds / 10, scale: 0.17, birthRate: 2, color: mainColor))
            
            //A second layer of stars
            var emitterNode = starfieldEmitterNode(speed: -22, lifetime: yBounds / 5, scale: 0.12, birthRate: 4, color: medColor)
            emitterNode.zPosition = -10
            starfieldNode.addChild(emitterNode)
            
            //A third layer
            emitterNode = starfieldEmitterNode(speed: -13, lifetime: yBounds / 2, scale: 0.09, birthRate: 12, color: darkColor)
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
                frameNode.zPosition = -2.0
                
                starfieldNode.addChild(frameNode)
                
                starfieldNode.maskNode = frameNode
            }

            self.addChild(starfieldNode)
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceIndicatorTypeAnimatedSnowField) {
            //A layer of a snow
            let fieldNode = SKCropNode()
            fieldNode.name = "snowfieldNode"
            fieldNode.addChild(snowfieldEmitterNode(speed: -35, lifetime: yBounds / 10, scale: 0.17, birthRate: 4, color: mainColor))
            
            //A second layer of stars
            var emitterNode = snowfieldEmitterNode(speed: -30, lifetime: yBounds / 5, scale: 0.12, birthRate: 8, color: medColor)
            emitterNode.zPosition = -10
            fieldNode.addChild(emitterNode)
            
            //A third layer
            emitterNode = snowfieldEmitterNode(speed: -19, lifetime: yBounds / 2, scale: 0.09, birthRate: 16, color: darkColor)
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
                frameNode.zPosition = -2.0
                
                fieldNode.maskNode = frameNode //TODO: this works ouside of this if block but stops backgrounds
                fieldNode.addChild(frameNode)
            }
            
            self.addChild(fieldNode)
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeAnimatedPong) {
            
            let pongGameNode = PongGameNode.init(size: FaceBackgroundNode.getScreenBoundsForImages(), material: material, strokeColor: strokeColor, lineWidth: lineWidth)
            pongGameNode.name = "pongGameNode"
            
            if (lineWidth>0) {
                let size = FaceBackgroundNode.getScreenBoundsForImages()
                let width = size.width+lineWidth
                let height = size.height+lineWidth
                let frameNodeRect =  CGRect.init(x: -width/2, y: -height/2, width: width, height: height)
                let frameNode = SKShapeNode.init(rect:frameNodeRect)
                
                //draw it as a shape, no background!
                frameNode.fillColor = SKColor.black
                frameNode.strokeColor = strokeColor
                frameNode.lineWidth = lineWidth
                frameNode.zPosition = -2.0
                
                pongGameNode.addChild(frameNode)
            }
            
            self.addChild(pongGameNode)
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeFilled) {
            
            let effectsNode = SKEffectNode.init()
            
            if (lineWidth>0) {
                let width = screenSize.width //+lineWidth
                let height = screenSize.height  //+lineWidth
                let frameNodeRect =  CGRect.init(x: -width/2, y: -height/2, width: width, height: height)
                let frameNode = SKShapeNode.init(rect:frameNodeRect)
                
                //draw it as a shape, no background!
                frameNode.fillColor = SKColor.black
                frameNode.strokeColor = strokeColor
                frameNode.lineWidth = lineWidth*2
                
                effectsNode.addChild(frameNode)
            }
        
            let shape = FaceBackgroundNode.filledShapeNode(material: material)
            effectsNode.addChild(shape)
            
            effectsNode.shouldRasterize = true //speed 1 layer
            self.addChild(effectsNode)
            
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeDiagonalSplit) {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: xBounds, y: yBounds))
            bezierPath.addLine(to: CGPoint(x: -xBounds, y: -yBounds))
            bezierPath.addLine(to: CGPoint(x: xBounds, y: -yBounds))
            bezierPath.close()
            
            let shape = SKShapeNode.init(path: bezierPath.cgPath)
            shape.setMaterial(material: material)
            shape.strokeColor = strokeColor
            shape.lineWidth = lineWidth
            
            self.addChild(shape)
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeVerticalSplit) {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 0, y: yBounds))
            bezierPath.addLine(to: CGPoint(x: xBounds, y: yBounds))
            bezierPath.addLine(to: CGPoint(x: xBounds, y: -yBounds))
            bezierPath.addLine(to: CGPoint(x: 0, y: -yBounds))
            bezierPath.close()
            
            let shape = SKShapeNode.init(path: bezierPath.cgPath)
            
            if AppUISettings.materialIsColor(materialName: material) {
                shape.fillColor = SKColor.init(hexString: material)
                shape.strokeColor = strokeColor
                shape.lineWidth = lineWidth
                self.addChild(shape)
            } else {
                //has image, mask into shape!
                shape.fillColor = SKColor.white
                
                let cropNode = SKCropNode()
                let filledNode = FaceBackgroundNode.filledShapeNode(material: material)
                cropNode.addChild(filledNode)
                cropNode.maskNode = shape
                self.addChild(cropNode)
            }
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeHorizontalSplit) {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: xBounds, y: 0))
            bezierPath.addLine(to: CGPoint(x: xBounds, y: -yBounds))
            bezierPath.addLine(to: CGPoint(x: -xBounds, y: -yBounds))
            bezierPath.addLine(to: CGPoint(x: -xBounds, y: 0))
            bezierPath.close()
            
            let shape = SKShapeNode.init(path: bezierPath.cgPath)
            
            if AppUISettings.materialIsColor(materialName: material) {
                shape.fillColor = SKColor.init(hexString: material)
                shape.strokeColor = strokeColor
                shape.lineWidth = lineWidth
                self.addChild(shape)
            } else {
                //has image, mask into shape!
                shape.fillColor = SKColor.white
                
                let cropNode = SKCropNode()
                let filledNode = FaceBackgroundNode.filledShapeNode(material: material)
                cropNode.addChild(filledNode)
                cropNode.maskNode = shape
                self.addChild(cropNode)
            }
        
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeCircle) {
            
            let r = CGFloat(1.1)
            let circleNode = SKShapeNode.init(circleOfRadius: r * sizeMultiplier)
            
            if AppUISettings.materialIsColor(materialName: material) {
                //draw it as a shape, no background!
                circleNode.fillColor = SKColor.init(hexString: material)
                circleNode.strokeColor = strokeColor
                circleNode.lineWidth = lineWidth + 1.0
                self.addChild(circleNode)
            } else {
                //has image, mask into shape!
                let cropNode = SKCropNode()
                let filledNode = FaceBackgroundNode.filledShapeNode(material: material)
                cropNode.addChild(filledNode)
                circleNode.fillColor = SKColor.white
                cropNode.maskNode = circleNode
                self.addChild(cropNode)
            }
            
        }
        
        func isGradientNode(backgroundType: FaceBackgroundTypes)->Bool {
             return (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeVerticalGradient || backgroundType == FaceBackgroundTypes.FaceBackgroundTypeHorizontalGradient || backgroundType == FaceBackgroundTypes.FaceBackgroundTypeDiagonalGradient)
        }
        
        if isGradientNode(backgroundType: backgroundType) {
            
            let size = FaceBackgroundNode.getScreenBoundsForImages()
            let color1 = SKColor.init(hexString: material)
            let color2 = SKColor.init(hexString: material2)
            let colors = [ color2.cgColor, color1.cgColor ]
            
            let locations:[CGFloat] = [0.0,1.0]
            let startPoint = CGPoint.init(x: 0, y: 0)
            var endPoint = CGPoint.init(x: 0, y: size.height)
            
            if backgroundType == FaceBackgroundTypes.FaceBackgroundTypeHorizontalGradient {
                endPoint = CGPoint.init(x: size.width, y: 0)
            }
            if backgroundType == FaceBackgroundTypes.FaceBackgroundTypeDiagonalGradient {
                endPoint = CGPoint.init(x: size.width, y: size.height)
            }
            
            if let gradientImage = UIGradientImage.init(size: size, colors: colors,
                    locations: locations, startPoint: startPoint, endPoint: endPoint) {
                
                let tex = SKTexture.init(cgImage: gradientImage.cgImage!)
                let newNode = SKSpriteNode.init(texture: tex)
                
                let effectsNode = SKEffectNode.init()
                
                if (lineWidth>0) {
                    let width = size.width+lineWidth
                    let height = size.height+lineWidth
                    let frameNodeRect =  CGRect.init(x: -width/2, y: -height/2, width: width, height: height)
                    let frameNode = SKShapeNode.init(rect:frameNodeRect)
                    
                    //draw it as a shape, no background!
                    frameNode.fillColor = SKColor.black
                    frameNode.strokeColor = strokeColor
                    frameNode.lineWidth = lineWidth
                    
                    effectsNode.addChild(frameNode)
                }
                
                effectsNode.addChild(newNode)
                
                effectsNode.shouldRasterize = true //speed 1 layer
                self.addChild(effectsNode)
            }
           
        }
        
        
    }
    
    //Creates a new star field
    func starfieldEmitterNode(speed: CGFloat, lifetime: CGFloat, scale: CGFloat, birthRate: CGFloat, color: SKColor) -> SKEmitterNode {
        
        let size = FaceBackgroundNode.getScreenBoundsForImages()
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
        
        let size = FaceBackgroundNode.getScreenBoundsForImages()
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
