//
//  HourIndicatorNode.swift
//  AppleWatchFaces
//
//  Created by Mike Hill on 11/11/15.
//  Copyright © 2015 Mike Hill. All rights reserved.
//

import SpriteKit
import SceneKit

enum FaceIndicatorTypes: String {
    case FaceIndicatorTypeTube, FaceIndicatorTypeSphere, FaceIndicatorTypeBox,
    FaceIndicatorTypeMediumBox, FaceIndicatorTypeFatBox, FaceIndicatorTypeCircle,
    FaceIndicatorTypeTriangle, FaceIndicatorTypeFlippedTriangle, FaceIndicatorTypeNone
    
    static let randomizableValues = [FaceIndicatorTypeTube, FaceIndicatorTypeSphere, FaceIndicatorTypeBox, FaceIndicatorTypeMediumBox, FaceIndicatorTypeFatBox, FaceIndicatorTypeTriangle, FaceIndicatorTypeFlippedTriangle]
    static let userSelectableValues = [FaceIndicatorTypeTube, FaceIndicatorTypeSphere, FaceIndicatorTypeBox, FaceIndicatorTypeTriangle, FaceIndicatorTypeFlippedTriangle, FaceIndicatorTypeMediumBox, FaceIndicatorTypeFatBox]
    
    static func random() -> FaceIndicatorTypes {
        let randomIndex = Int(arc4random_uniform(UInt32(randomizableValues.count)))
        return randomizableValues[randomIndex]
    }
}

class FaceIndicatorNode: SKSpriteNode {
    
    static func descriptionForType(_ nodeType: FaceIndicatorTypes) -> String {
        var typeDescription = ""
        
        if (nodeType == .FaceIndicatorTypeTube)  { typeDescription = "Tube" }
        if (nodeType == .FaceIndicatorTypeSphere)  { typeDescription = "Circle" }
        if (nodeType == .FaceIndicatorTypeTriangle)  { typeDescription = "Triangle" }
        if (nodeType == .FaceIndicatorTypeFlippedTriangle) { typeDescription = "Flipped Triangle" }
        if (nodeType == .FaceIndicatorTypeBox)  { typeDescription = "Thin Box" }
        if (nodeType == .FaceIndicatorTypeMediumBox )  { typeDescription = "Medium Box" }
        if (nodeType == .FaceIndicatorTypeFatBox)  { typeDescription = "Fat Box" }
        
        return typeDescription
    }
    
    static func typeDescriptions() -> [String] {
        var typeDescriptionsArray = [String]()
        for nodeType in FaceIndicatorTypes.userSelectableValues {
            typeDescriptionsArray.append(descriptionForType(nodeType))
        }
        
        return typeDescriptionsArray
    }
    
    static func typeKeys() -> [String] {
        var typeKeysArray = [String]()
        for nodeType in FaceIndicatorTypes.userSelectableValues {
            typeKeysArray.append(nodeType.rawValue)
        }
        
        return typeKeysArray
    }
    
//    override init() {
//        super.init(texture: nil, color: SKColor.clear, size: CGSize.init())
//    }
    
    init(indicatorType: FaceIndicatorTypes, size: Float, fillColor: SKColor) {
        
        super.init(texture: nil, color: SKColor.clear, size: CGSize.init())
        
        self.name = "FaceIndicator"
        let sizeMultiplier:CGFloat = SKWatchScene.sizeMulitplier
        
        if (indicatorType == FaceIndicatorTypes.FaceIndicatorTypeBox) {
            let w = CGFloat( size * Float(0.1) )
            let h = CGFloat( size * Float(0.7) )
            let rect = CGRect.init(x: 0, y: 0, width: w * sizeMultiplier, height: h * sizeMultiplier)
            let shapeNode = SKShapeNode.init(rect: rect)
            shapeNode.fillColor = fillColor
            shapeNode.strokeColor = fillColor
            shapeNode.lineWidth = 1.0
            shapeNode.position = CGPoint.init(x: -(w * sizeMultiplier)/2, y: -(h * sizeMultiplier)/2)
            
            let phy = SKPhysicsBody.init(rectangleOf: rect.size, center: CGPoint.init(x: rect.midX, y: rect.midY))
            phy.isDynamic = false
            shapeNode.physicsBody = phy
            
            self.addChild(shapeNode)
            
            //self.geometry = SCNBox.init(width: w, height: h, length: 0.002, chamferRadius: 0)
        }
        
        if (indicatorType == FaceIndicatorTypes.FaceIndicatorTypeMediumBox) {
            let w = CGFloat( size * Float(0.2) )
            let h = CGFloat( size * Float(0.7) )
            let rect = CGRect.init(x: 0, y: 0, width: w * sizeMultiplier, height: h * sizeMultiplier)
            let shapeNode = SKShapeNode.init(rect: rect)
            shapeNode.fillColor = fillColor
            shapeNode.strokeColor = fillColor
            shapeNode.lineWidth = 1.0
            shapeNode.position = CGPoint.init(x: -(w * sizeMultiplier)/2, y: -(h * sizeMultiplier)/2)
            
            let phy = SKPhysicsBody.init(rectangleOf: rect.size, center: CGPoint.init(x: rect.midX, y: rect.midY))
            phy.isDynamic = false
            shapeNode.physicsBody = phy
            
            self.addChild(shapeNode)
            
            //self.geometry = SCNBox.init(width: w, height: h, length: 0.002, chamferRadius: 0)
        }
        
        if (indicatorType == FaceIndicatorTypes.FaceIndicatorTypeFatBox) {
            let w = CGFloat( size * Float(0.25) )
            let h = CGFloat( size * Float(0.7) )
            let rect = CGRect.init(x: 0, y: 0, width: w * sizeMultiplier, height: h * sizeMultiplier)
            let shapeNode = SKShapeNode.init(rect: rect)
            shapeNode.fillColor = fillColor
            shapeNode.strokeColor = fillColor
            shapeNode.lineWidth = 1.0
            shapeNode.position = CGPoint.init(x: -(w * sizeMultiplier)/2, y: -(h * sizeMultiplier)/2)
            
            let phy = SKPhysicsBody.init(rectangleOf: rect.size, center: CGPoint.init(x: rect.midX, y: rect.midY))
            phy.isDynamic = false
            shapeNode.physicsBody = phy
            
            self.addChild(shapeNode)
            
            //self.geometry = SCNBox.init(width: w, height: h, length: 0.002, chamferRadius: 0)
        }
        
        if (indicatorType == .FaceIndicatorTypeTriangle) {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 44, y: 0.5))
            bezierPath.addLine(to: CGPoint(x: 87.73, y: 76.25))
            bezierPath.addLine(to: CGPoint(x: 0.27, y: 76.25))
            bezierPath.close()
            
            let scaledSize = CGFloat(size) * ( sizeMultiplier / 200 )
            bezierPath.apply(CGAffineTransform.init(translationX: -44, y: -38)) //repos
            bezierPath.apply(CGAffineTransform.init(scaleX: scaledSize, y:-scaledSize))  //scale/stratch
            
            let shapeNode = SKShapeNode.init(path: bezierPath.cgPath)
            shapeNode.fillColor = fillColor
            shapeNode.strokeColor = fillColor
            shapeNode.lineWidth = 1.0
            
            let phy =  SKPhysicsBody.init(polygonFrom: bezierPath.cgPath)
            phy.isDynamic = false
            shapeNode.physicsBody = phy
            
            self.addChild(shapeNode)
        }
        
        if (indicatorType == .FaceIndicatorTypeFlippedTriangle) {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 44, y: 0.5))
            bezierPath.addLine(to: CGPoint(x: 87.73, y: 76.25))
            bezierPath.addLine(to: CGPoint(x: 0.27, y: 76.25))
            bezierPath.close()
            
            let scaledSize = CGFloat(size) * ( sizeMultiplier / 200 )
            bezierPath.apply(CGAffineTransform.init(translationX: -44, y: -38)) //repos
            bezierPath.apply(CGAffineTransform.init(scaleX: scaledSize, y:scaledSize))  //scale/stratch
            
            let shapeNode = SKShapeNode.init(path: bezierPath.cgPath)
            shapeNode.fillColor = fillColor
            shapeNode.strokeColor = fillColor
            shapeNode.lineWidth = 1.0
            
            let phy =  SKPhysicsBody.init(polygonFrom: bezierPath.cgPath)
            phy.isDynamic = false
            shapeNode.physicsBody = phy
            
            self.addChild(shapeNode)
        }
        
        if (indicatorType == FaceIndicatorTypes.FaceIndicatorTypeTube) {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 35.99, y: 18))
            bezierPath.addCurve(to: CGPoint(x: 36, y: 18.5), controlPoint1: CGPoint(x: 36, y: 18), controlPoint2: CGPoint(x: 36, y: 18.17))
            bezierPath.addCurve(to: CGPoint(x: 36, y: 74), controlPoint1: CGPoint(x: 36, y: 24.04), controlPoint2: CGPoint(x: 36, y: 74))
            bezierPath.addCurve(to: CGPoint(x: 36, y: 74.5), controlPoint1: CGPoint(x: 36, y: 74.17), controlPoint2: CGPoint(x: 36, y: 74.33))
            bezierPath.addCurve(to: CGPoint(x: 18, y: 93), controlPoint1: CGPoint(x: 36, y: 84.72), controlPoint2: CGPoint(x: 27.94, y: 93))
            bezierPath.addCurve(to: CGPoint(x: 0, y: 74.5), controlPoint1: CGPoint(x: 8.06, y: 93), controlPoint2: CGPoint(x: 0, y: 84.72))
            bezierPath.addCurve(to: CGPoint(x: 0.01, y: 74), controlPoint1: CGPoint(x: 0, y: 74.33), controlPoint2: CGPoint(x: 0, y: 74.17))
            bezierPath.addCurve(to: CGPoint(x: 0, y: 18.5), controlPoint1: CGPoint(x: 0, y: 74), controlPoint2: CGPoint(x: 0, y: 24.05))
            bezierPath.addCurve(to: CGPoint(x: 0, y: 18), controlPoint1: CGPoint(x: 0, y: 18.17), controlPoint2: CGPoint(x: 0, y: 18))
            bezierPath.addCurve(to: CGPoint(x: 1.24, y: 11.75), controlPoint1: CGPoint(x: 0.06, y: 15.8), controlPoint2: CGPoint(x: 0.49, y: 13.69))
            bezierPath.addCurve(to: CGPoint(x: 18, y: 0), controlPoint1: CGPoint(x: 3.86, y: 4.87), controlPoint2: CGPoint(x: 10.38, y: 0))
            bezierPath.addCurve(to: CGPoint(x: 35.99, y: 18), controlPoint1: CGPoint(x: 27.78, y: 0), controlPoint2: CGPoint(x: 35.74, y: 8.01))
            bezierPath.close()
            
            //translate and scale
            let scaledSize = CGFloat(size) * ( sizeMultiplier / 200 )
            bezierPath.apply(CGAffineTransform.init(translationX: -18, y: -47)) //repos
            bezierPath.apply(CGAffineTransform.init(scaleX: scaledSize, y:scaledSize))  //scale/stratch
            
            let shapeNode = SKShapeNode.init(path: bezierPath.cgPath)
            shapeNode.fillColor = fillColor
            shapeNode.strokeColor = fillColor
            shapeNode.lineWidth = 1.0
            
            let phy =  SKPhysicsBody.init(polygonFrom: bezierPath.cgPath)
            phy.isDynamic = false
            shapeNode.physicsBody = phy
            
            self.addChild(shapeNode)
        }
        
        if (indicatorType == FaceIndicatorTypes.FaceIndicatorTypeSphere) {
            let r = CGFloat( size * Float(0.1) )
            let shapeNode = SKShapeNode.init(circleOfRadius: r * sizeMultiplier)
            shapeNode.fillColor = fillColor
            shapeNode.strokeColor = fillColor
            shapeNode.lineWidth = 1.0
            
            let rad = r * sizeMultiplier
            if r > 0 {
                let phy = SKPhysicsBody.init(circleOfRadius: rad)
                phy.isDynamic = false
                shapeNode.physicsBody = phy
            }
            
            self.addChild(shapeNode)
                
            //self.geometry = SCNSphere.init(radius: r)
            //self.scale = SCNVector3Make( 1.0, 1.0, 0.2)
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
