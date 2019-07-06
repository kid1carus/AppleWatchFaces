//
//  FaceBackgroundNode.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 11/17/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import SpriteKit
import SceneKit
import UIKit

enum FaceBackgroundTypes: String {
    case FaceBackgroundTypeFilled, FaceBackgroundTypeDiagonalSplit, FaceBackgroundTypeCircle, FaceBackgroundTypeVerticalSplit, FaceBackgroundTypeHorizontalSplit,
        FaceBackgroundTypeFaceCircleCutout,
        FaceBackgroundTypeRoundedCircleCutout,
        FaceBackgroundTypeVerticalGradient, FaceBackgroundTypeHorizontalGradient, FaceBackgroundTypeDiagonalGradient,
        FaceBackgroundTypeNone
    
    static var userSelectableValues = [
        FaceBackgroundTypeCircle,
        FaceBackgroundTypeFilled,
        FaceBackgroundTypeDiagonalSplit,
        FaceBackgroundTypeVerticalSplit,
        FaceBackgroundTypeHorizontalSplit,
        FaceBackgroundTypeFaceCircleCutout,
        FaceBackgroundTypeRoundedCircleCutout
    ]
    
    static let randomizableValues = userSelectableValues //short cut, but will get none
    
    static func random() -> FaceBackgroundTypes {
        let randomIndex = Int(arc4random_uniform(UInt32(randomizableValues.count)))
        return randomizableValues[randomIndex]
    }
}

enum GradientBackgroundDirectionTypes: String {
    case Vertical, Horizontal, Diagonal
    
    static var userSelectableValues = [Vertical, Horizontal, Diagonal]
}

class FaceBackgroundNode: SKSpriteNode {
    
    var backgroundType:FaceBackgroundTypes = .FaceBackgroundTypeNone
    
    static func descriptionForType(_ nodeType: FaceBackgroundTypes) -> String {
        var typeDescription = ""
        
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeCircle)  { typeDescription = "Circle" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeFilled)  { typeDescription = "Filled" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeDiagonalSplit)  { typeDescription = "Split Diagonal" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeVerticalSplit)  { typeDescription = "Vertical Split" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeHorizontalSplit)  { typeDescription = "Horizontal Split" }
        if (nodeType == .FaceBackgroundTypeFaceCircleCutout) { typeDescription = "Square with Cutout" }
        if (nodeType == .FaceBackgroundTypeRoundedCircleCutout) { typeDescription = "Circle with Cutouts"}
        
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeVerticalGradient)  { typeDescription = "Vertical Gradient" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeHorizontalGradient)  { typeDescription = "Horizonal Gradient" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeDiagonalGradient)  { typeDescription = "Diagonal Gradient" }
        
        //if (nodeType == .FaceBackgroundTypeImage) { typeDescription = "Image Shape" }
        
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
    
    static func descriptionForGradientDirections(_ nodeType: GradientBackgroundDirectionTypes) -> String {
        var typeDescription = ""
        
        if (nodeType == .Diagonal)  { typeDescription = "Diagonal" }
        if (nodeType == .Horizontal)  { typeDescription = "Horizontal" }
        if (nodeType == .Vertical)  { typeDescription = "Vertical" }
        
        return typeDescription
    }
    
    static func gradientDirectionDescriptions() -> [String] {
        var typeDescriptionsArray = [String]()
        for nodeType in GradientBackgroundDirectionTypes.userSelectableValues {
            typeDescriptionsArray.append(descriptionForGradientDirections(nodeType))
        }
        
        return typeDescriptionsArray
    }
    
    static func filledShapeNode(material: String, size: CGSize) -> SKShapeNode {
        let xBounds = size.width
        let yBounds = size.height
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
    
    static func filledShapeNode(material: String) -> SKShapeNode {
        let screenSize = AppUISettings.getScreenBoundsForImages()
        let xBounds = (screenSize.width / 2.0).rounded()
        let yBounds = (screenSize.height / 2.0).rounded()
        
        let newShapeSize = CGSize.init(width: xBounds, height: yBounds)
        return filledShapeNode(material: material, size: newShapeSize)
    }
    
    func positionHands( min: CGFloat, hour: CGFloat, force: Bool ) {
        //
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
        let screenSize = AppUISettings.getScreenBoundsForImages()
        let xBounds = (screenSize.width / 2.0).rounded()
        let yBounds = (screenSize.height / 2.0).rounded()
        
        func getImageNode( material: String) -> SKNode? {
            return getImageNode(material: material, tryBundle: false)
        }
        
        func getImageNode( material: String, tryBundle: Bool) -> SKNode? {
            
            var customImage = UIImage.getImageFor(imageName: material)
            if (tryBundle) {
                customImage = UIImage.init(named: material)
            }
            
            //load image
            if let image = customImage  {
                let texture = SKTexture.init(image: image)
                let scaledSize = CGSize.init(width: image.size.width * image.scale, height: image.size.height * image.scale)
                let imageNode = SKSpriteNode.init(texture: texture, size: scaledSize)
                return imageNode
            }
            
            return nil
        }
        func maskImageIntoShape( materialToUse: String, shapeNode: SKShapeNode) -> SKNode {
            
            var imageNode = SKNode()
            var checkInBundle = false
            
            if AppUISettings.overlayMaterialFiles.contains(materialToUse) {
                checkInBundle = true
            }
            
            if let cameraImage = getImageNode(material: material, tryBundle: checkInBundle) {
                //wont fill to baxkground size (best for pngs / overlays )
                imageNode = cameraImage
            } else {
                //will fill perfectly to size ( for backgrounds )
                imageNode = FaceBackgroundNode.filledShapeNode(material: materialToUse)
            }
            
            //needed to properly be able to set alpha
            let effectsNodeWrapper = SKEffectNode.init()
            
            shapeNode.fillColor = SKColor.white //needed for crop to mask properly
            shapeNode.lineWidth = 0.0
            let cropNode = SKCropNode()
            
            //let filledNode = FaceBackgroundNode.filledShapeNode(material: materialToUse)
            cropNode.addChild(imageNode)
            cropNode.maskNode = shapeNode
            
            effectsNodeWrapper.addChild(cropNode)
            effectsNodeWrapper.shouldRasterize = true
            return effectsNodeWrapper
        }
        
//        if (backgroundType == .FaceBackgroundTypeImage) {
//
//            if let imageNode = getImageNode(material: material) {
//                self.addChild(imageNode)
//            }
//
//        }
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeFilled) {
            
            let screenSize = AppUISettings.getScreenBoundsForImages()
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
            
            if AppUISettings.materialIsColor(materialName: material) {
                shape.fillColor = SKColor.init(hexString: material)
                shape.strokeColor = strokeColor
                shape.lineWidth = lineWidth
                self.addChild(shape)
            } else {
                
                //for pngs force to bundle
                
                if let imageNode = getImageNode(material: material) {
                    // imported camera image, dont bound to fill size
                    self.addChild(imageNode)
                } else {
                    // bundle image, bound to fill ( shape ) size
                    self.addChild( maskImageIntoShape(materialToUse: material, shapeNode: shape) )
                }
            }

        }
        
        if backgroundType == .FaceBackgroundTypeFaceCircleCutout {
            let backgroundPath = UIBezierPath()
            backgroundPath.move(to: CGPoint(x: 52, y: -127))
            backgroundPath.addLine(to: CGPoint(x: -52, y: -127))
            backgroundPath.addLine(to: CGPoint(x: -52, y: -93))
            backgroundPath.addLine(to: CGPoint(x: 52, y: -93))
            backgroundPath.addLine(to: CGPoint(x: 52, y: -127))
            backgroundPath.close()
            backgroundPath.move(to: CGPoint(x: 56, y: 65))
            backgroundPath.addCurve(to: CGPoint(x: 21, y: 100), controlPoint1: CGPoint(x: 36.67, y: 65), controlPoint2: CGPoint(x: 21, y: 80.67))
            backgroundPath.addCurve(to: CGPoint(x: 56, y: 135), controlPoint1: CGPoint(x: 21, y: 119.33), controlPoint2: CGPoint(x: 36.67, y: 135))
            backgroundPath.addCurve(to: CGPoint(x: 91, y: 100), controlPoint1: CGPoint(x: 75.33, y: 135), controlPoint2: CGPoint(x: 91, y: 119.33))
            backgroundPath.addCurve(to: CGPoint(x: 61.36, y: 65.41), controlPoint1: CGPoint(x: 91, y: 82.49), controlPoint2: CGPoint(x: 78.15, y: 67.99))
            backgroundPath.addCurve(to: CGPoint(x: 56, y: 65), controlPoint1: CGPoint(x: 59.61, y: 65.14), controlPoint2: CGPoint(x: 57.82, y: 65))
            backgroundPath.close()
            backgroundPath.move(to: CGPoint(x: -56, y: 65))
            backgroundPath.addCurve(to: CGPoint(x: -91, y: 100), controlPoint1: CGPoint(x: -75.33, y: 65), controlPoint2: CGPoint(x: -91, y: 80.67))
            backgroundPath.addCurve(to: CGPoint(x: -56, y: 135), controlPoint1: CGPoint(x: -91, y: 119.33), controlPoint2: CGPoint(x: -75.33, y: 135))
            backgroundPath.addCurve(to: CGPoint(x: -21, y: 100), controlPoint1: CGPoint(x: -36.67, y: 135), controlPoint2: CGPoint(x: -21, y: 119.33))
            backgroundPath.addCurve(to: CGPoint(x: -33.75, y: 72.98), controlPoint1: CGPoint(x: -21, y: 89.12), controlPoint2: CGPoint(x: -25.96, y: 79.4))
            backgroundPath.addCurve(to: CGPoint(x: -56, y: 65), controlPoint1: CGPoint(x: -39.8, y: 68), controlPoint2: CGPoint(x: -47.55, y: 65))
            backgroundPath.close()
            backgroundPath.move(to: CGPoint(x: 156, y: -195))
            backgroundPath.addCurve(to: CGPoint(x: 156, y: 195), controlPoint1: CGPoint(x: 156, y: -195), controlPoint2: CGPoint(x: 156, y: 195))
            backgroundPath.addLine(to: CGPoint(x: -156, y: 195))
            backgroundPath.addLine(to: CGPoint(x: -156, y: -195))
            backgroundPath.addLine(to: CGPoint(x: 156, y: -195))
            backgroundPath.addLine(to: CGPoint(x: 156, y: -195))
            backgroundPath.close()

            //transform to work for us
            backgroundPath.apply(CGAffineTransform.init(scaleX: 0.71, y: -0.71))
            
            let shape = SKShapeNode.init(path: backgroundPath.cgPath)
            
            if AppUISettings.materialIsColor(materialName: material) {
                shape.fillColor = SKColor.init(hexString: material)
                shape.strokeColor = strokeColor
                shape.lineWidth = lineWidth
                self.addChild(shape)
            } else {
                self.addChild( maskImageIntoShape(materialToUse: material, shapeNode: shape) )
            }

        }
        
        if (backgroundType == .FaceBackgroundTypeRoundedCircleCutout) {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 50, y: 0))
            bezierPath.addCurve(to: CGPoint(x: 23, y: 10.49), controlPoint1: CGPoint(x: 39.59, y: 0), controlPoint2: CGPoint(x: 30.12, y: 3.97))
            bezierPath.addCurve(to: CGPoint(x: 10, y: 40), controlPoint1: CGPoint(x: 15.01, y: 17.8), controlPoint2: CGPoint(x: 10, y: 28.32))
            bezierPath.addCurve(to: CGPoint(x: 50, y: 80), controlPoint1: CGPoint(x: 10, y: 62.09), controlPoint2: CGPoint(x: 27.91, y: 80))
            bezierPath.addCurve(to: CGPoint(x: 90, y: 40), controlPoint1: CGPoint(x: 72.09, y: 80), controlPoint2: CGPoint(x: 90, y: 62.09))
            bezierPath.addCurve(to: CGPoint(x: 50, y: 0), controlPoint1: CGPoint(x: 90, y: 17.91), controlPoint2: CGPoint(x: 72.09, y: 0))
            bezierPath.close()
            bezierPath.move(to: CGPoint(x: -50, y: 0))
            bezierPath.addCurve(to: CGPoint(x: -90, y: 40), controlPoint1: CGPoint(x: -72.09, y: 0), controlPoint2: CGPoint(x: -90, y: 17.91))
            bezierPath.addCurve(to: CGPoint(x: -50, y: 80), controlPoint1: CGPoint(x: -90, y: 62.09), controlPoint2: CGPoint(x: -72.09, y: 80))
            bezierPath.addCurve(to: CGPoint(x: -10, y: 40), controlPoint1: CGPoint(x: -27.91, y: 80), controlPoint2: CGPoint(x: -10, y: 62.09))
            bezierPath.addCurve(to: CGPoint(x: -49, y: 0.01), controlPoint1: CGPoint(x: -10, y: 18.24), controlPoint2: CGPoint(x: -27.37, y: 0.55))
            bezierPath.addCurve(to: CGPoint(x: -50, y: 0), controlPoint1: CGPoint(x: -49.33, y: 0), controlPoint2: CGPoint(x: -49.66, y: 0))
            bezierPath.close()
            bezierPath.move(to: CGPoint(x: 155, y: 0))
            bezierPath.addCurve(to: CGPoint(x: -0, y: 155), controlPoint1: CGPoint(x: 155, y: 85.6), controlPoint2: CGPoint(x: 85.6, y: 155))
            bezierPath.addCurve(to: CGPoint(x: -155, y: -0), controlPoint1: CGPoint(x: -85.6, y: 155), controlPoint2: CGPoint(x: -155, y: 85.6))
            bezierPath.addCurve(to: CGPoint(x: 0, y: -155), controlPoint1: CGPoint(x: -155, y: -85.6), controlPoint2: CGPoint(x: -85.6, y: -155))
            bezierPath.addCurve(to: CGPoint(x: 155, y: 0), controlPoint1: CGPoint(x: 85.6, y: -155), controlPoint2: CGPoint(x: 155, y: -85.6))
            bezierPath.close()
            
            //transform to work for us
            bezierPath.apply(CGAffineTransform.init(scaleX: 0.71, y: -0.71))
            
            let shape = SKShapeNode.init(path: bezierPath.cgPath)
            
            if AppUISettings.materialIsColor(materialName: material) {
                shape.fillColor = SKColor.init(hexString: material)
                shape.strokeColor = strokeColor
                shape.lineWidth = lineWidth
                self.addChild(shape)
            } else {
                self.addChild( maskImageIntoShape(materialToUse: material, shapeNode: shape) )
            }
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeDiagonalSplit) {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: xBounds, y: yBounds))
            bezierPath.addLine(to: CGPoint(x: -xBounds, y: -yBounds))
            bezierPath.addLine(to: CGPoint(x: xBounds, y: -yBounds))
            bezierPath.close()
            
            let shape = SKShapeNode.init(path: bezierPath.cgPath)
            
            if AppUISettings.materialIsColor(materialName: material) {
                shape.fillColor = SKColor.init(hexString: material)
                shape.strokeColor = strokeColor
                shape.lineWidth = lineWidth
                self.addChild(shape)
            } else {
                self.addChild( maskImageIntoShape(materialToUse: material, shapeNode: shape) )
            }

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
                self.addChild( maskImageIntoShape(materialToUse: material, shapeNode: shape) )
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
                self.addChild( maskImageIntoShape(materialToUse: material, shapeNode: shape) )
            }
        
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeCircle) {
            
            let r = CGFloat(1.1)
            let shape = SKShapeNode.init(circleOfRadius: r * sizeMultiplier)
            
            if AppUISettings.materialIsColor(materialName: material) {
                shape.fillColor = SKColor.init(hexString: material)
                shape.strokeColor = strokeColor
                shape.lineWidth = lineWidth
                self.addChild(shape)
            } else {
               self.addChild( maskImageIntoShape(materialToUse: material, shapeNode: shape) )
            }
            
        }
        
        func isGradientNode(backgroundType: FaceBackgroundTypes)->Bool {
             return (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeVerticalGradient || backgroundType == FaceBackgroundTypes.FaceBackgroundTypeHorizontalGradient || backgroundType == FaceBackgroundTypes.FaceBackgroundTypeDiagonalGradient)
        }
        
        if isGradientNode(backgroundType: backgroundType) {
            
            let size = AppUISettings.getScreenBoundsForImages()
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
