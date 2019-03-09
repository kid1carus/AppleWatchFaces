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

enum FaceBackgroundTypes: String {
    case FaceBackgroundTypeFilled, FaceBackgroundTypeDiagonalSplit, FaceBackgroundTypeCircle, FaceBackgroundTypeVerticalSplit, FaceBackgroundTypeHorizontalSplit, FaceBackgroundTypeVerticalGradient, FaceBackgroundTypeHorizontalGradient,
        FaceBackgroundTypeDiagonalGradient, FaceBackgroundTypeAnimatedPong, FaceBackgroundTypeNone
    
    static let userSelectableValues = [FaceBackgroundTypeCircle, FaceBackgroundTypeFilled, FaceBackgroundTypeDiagonalSplit,
                                     FaceBackgroundTypeVerticalSplit, FaceBackgroundTypeHorizontalSplit, FaceBackgroundTypeVerticalGradient, FaceBackgroundTypeHorizontalGradient, FaceBackgroundTypeDiagonalGradient,
                                     FaceBackgroundTypeAnimatedPong,
                                     
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
            let w = screenBounds.size.width * mult * ratio
            let h = screenBounds.size.height * mult * ratio
        #else
            let w = CGFloat( CGFloat(320) / 1.42 ) // 1.42
            let h = CGFloat( CGFloat(390) / 1.42 ) // 1.42
        #endif
        
        return CGSize.init(width: w, height: h)
    }
    
    static func filledShapeNode(material: String) -> SKShapeNode {
        let size = getScreenBoundsForImages()
        let shape = SKShapeNode.init(rect: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        shape.lineWidth = 0.0
        shape.setMaterial(material: material)
        shape.position = CGPoint.init(x: -size.width/2, y: -size.height/2)
        return shape
    }
    
    func positionHands( min: CGFloat, hour: CGFloat, force: Bool ) {
        
        if self.backgroundType == .FaceBackgroundTypeAnimatedPong {
            if force {
                if let pongNode = self.childNode(withName: "pongGameNode") as? PongGameNode {
                    pongNode.positionHands( hour: hour, min: min )
                }
            }
        }
    }
    
    convenience init(backgroundType: FaceBackgroundTypes, material: String) {
        self.init(backgroundType: backgroundType, material: material, material2: "", strokeColor: SKColor.clear, lineWidth: 1.0)
    }
    
    convenience init(backgroundType: FaceBackgroundTypes, material: String, material2: String) {
        self.init(backgroundType: backgroundType, material: material, material2: material2, strokeColor: SKColor.clear, lineWidth: 1.0)
    }
    
    init(backgroundType: FaceBackgroundTypes, material: String, material2: String, strokeColor: SKColor, lineWidth: CGFloat ) {
        
        super.init(texture: nil, color: SKColor.clear, size: CGSize.init())
        
        self.backgroundType = backgroundType
        self.name = "FaceBackground"
        let sizeMultiplier = CGFloat(SKWatchScene.sizeMulitplier)
        let xBounds = FaceBackgroundNode.getScreenBoundsForImages().width / 2.0
        let yBounds = FaceBackgroundNode.getScreenBoundsForImages().height / 2.0
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeAnimatedPong) {
            let pongGameNode = PongGameNode.init(size: FaceBackgroundNode.getScreenBoundsForImages(), material: material, strokeColor: strokeColor, lineWidth: lineWidth)
            pongGameNode.name = "pongGameNode"
            self.addChild(pongGameNode)
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeFilled) {
            
            let effectsNode = SKEffectNode.init()
            
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
                circleNode.lineWidth = lineWidth
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
