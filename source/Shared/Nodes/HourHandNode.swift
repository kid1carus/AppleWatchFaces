//
//  MinuteHandNode.swift
//  AppleWatchFaces
//
//  Created by Mike Hill on 11/11/15.
//  Copyright © 2015 Mike Hill. All rights reserved.
//

import SpriteKit

enum HourHandTypes: String {
    case HourHandTypeSwiss, HourHandTypeRounded, HourHandTypeRoman, HourHandTypeBoxy, HourHandTypeFatBoxy, HourHandTypeSquaredHole, HourHandTypeSphere, HourHandTypeCutout, HourHandTypeImageFancyWhite, HourHandTypeImageLightSaber, HourHandTypeImageMoon,
        HourHandTypeImageNumbers, HourHandTypeFlatDial, HourHandTypeThinDial, HourHandTypeRadar, HourHandTypeArrow, HourHandTypeCapeCod, HourHandTypeCapeCodFilled,
    HourHandTypePacMan, HourHandTypeMsPacMan, HourHandTypeNone
    
    static let randomizableValues = [HourHandTypeSwiss, HourHandTypeRounded, HourHandTypeBoxy, HourHandTypeFatBoxy, HourHandTypeSquaredHole, HourHandTypeRadar, HourHandTypeImageFancyWhite, HourHandTypeImageLightSaber, HourHandTypeThinDial, HourHandTypeNone]
    static let userSelectableValues = [HourHandTypeSwiss, HourHandTypeRounded, HourHandTypeBoxy, HourHandTypeFatBoxy, HourHandTypeSquaredHole, HourHandTypeRoman, HourHandTypeArrow, HourHandTypeCapeCod, HourHandTypeCapeCodFilled, HourHandTypeSphere, HourHandTypeCutout, HourHandTypeImageFancyWhite, HourHandTypeImageLightSaber, HourHandTypeImageMoon,
        HourHandTypeImageNumbers, HourHandTypeFlatDial, HourHandTypeThinDial, HourHandTypeRadar]
    
    static func random() -> HourHandTypes {
        let randomIndex = Int(arc4random_uniform(UInt32(randomizableValues.count)))
        return randomizableValues[randomIndex]
    }
    
    static func isDialType(type: HourHandTypes) -> Bool {
        return ([HourHandTypeFlatDial, HourHandTypeThinDial].lastIndex(of: type) != nil)
    }
}

class HourHandNode: SKSpriteNode {
    
    let sizeMultiplier = CGFloat(SKWatchScene.sizeMulitplier)
    var hourHandType:HourHandTypes = .HourHandTypeNone
    var material = ""
    var strokeColor:SKColor = SKColor.white
    var lineWidth: CGFloat = 0.0
    var cornerRadius:CGFloat = 0.0
    var glowWidth: CGFloat = 0.0
    
    //used for dials
    var innerRadius:CGFloat = 0.0
    var outerRadius:CGFloat = 0.0
    
    //positioning in pac man background
    let pacManPathSize = CGSize.init(width: 100.0, height: 65.0)
    let pacManOffsetPoint = CGPoint.init(x: 0.0, y: -5.0)
    
    let msPacManPathSize = CGSize.init(width: 83.0, height: 54.0)
    let msPacManOffsetPoint = CGPoint.init(x: 0.0, y: -1.0)
    
    static func descriptionForType(_ nodeType: HourHandTypes) -> String {
        var typeDescription = ""
        
        if (nodeType == .HourHandTypeNone)  { typeDescription = "None" }
        
        if (nodeType == .HourHandTypeSwiss)  { typeDescription = "Swiss" }
        if (nodeType == .HourHandTypeRounded)  { typeDescription = "Rounded" }
        if (nodeType == .HourHandTypeRoman)  { typeDescription = "Roman" }
        if (nodeType == .HourHandTypeSphere)  { typeDescription = "Magnetic Sphere" }
        if (nodeType == .HourHandTypeBoxy)  { typeDescription = "Boxy" }
        if (nodeType == .HourHandTypeFatBoxy)  { typeDescription = "Fat Boxy" }
        if (nodeType == .HourHandTypeSquaredHole)  { typeDescription = "Squared Hole" }
        if (nodeType == .HourHandTypeCutout)  { typeDescription = "Square Cutout" }
        if (nodeType == .HourHandTypeArrow) { typeDescription = "Arrow" }
        if (nodeType == .HourHandTypeCapeCod) { typeDescription = "Cape Cod" }
        if (nodeType == .HourHandTypeCapeCodFilled) { typeDescription = "Cape Cod Filled" }
        
        if (nodeType == .HourHandTypeFlatDial)  { typeDescription = "Flat Dial" }
        if (nodeType == .HourHandTypeThinDial)  { typeDescription = "Thin Dial" }
        if (nodeType == .HourHandTypeRadar)  { typeDescription = "Radar" }
        if (nodeType == .HourHandTypePacMan)  { typeDescription = "Dot Eater" }
        if (nodeType == .HourHandTypeMsPacMan)  { typeDescription = "Ms Dot Eater" }
        
        
        //image ex
        if (nodeType == .HourHandTypeImageFancyWhite)  { typeDescription = "Image: Fancy White" }
        if (nodeType == .HourHandTypeImageLightSaber)  { typeDescription = "Image: Light Saber" }
        if (nodeType == .HourHandTypeImageMoon) { typeDescription = "Image: Moon" }
        if (nodeType == .HourHandTypeImageNumbers) { typeDescription = "Image: Numbers" }
        
        return typeDescription
    }
    
    static func typeDescriptions() -> [String] {
        var typeDescriptionsArray = [String]()
        for nodeType in HourHandTypes.userSelectableValues {
            typeDescriptionsArray.append(descriptionForType(nodeType))
        }
        
        return typeDescriptionsArray
    }
    
    static func typeKeys() -> [String] {
        var typeKeysArray = [String]()
        for nodeType in HourHandTypes.userSelectableValues {
            typeKeysArray.append(nodeType.rawValue)
        }
        
        return typeKeysArray
    }
    
    func addArcNode(endAngle: CGFloat) {
        let newNode = ArcNode.init(cornerRadius: cornerRadius, innerRadius: innerRadius, outerRadius: outerRadius,
                            endAngle: endAngle, material: material, strokeColor: strokeColor, lineWidth: lineWidth, glowWidth: glowWidth)
        newNode.name = "arcNode"
        self.addChild(newNode)
    }
    
    func positionHands( min: CGFloat, hour: CGFloat, force: Bool ) {
        
        let newZAngle = 1 * MathFunctions.deg2rad((12-hour) * 30 - min/2)
        
        if hourHandType == .HourHandTypePacMan || hourHandType == .HourHandTypeMsPacMan {
            
            var movementPath = DotsNode.rectPath(pathHeight: pacManPathSize.height, pathWidth: pacManPathSize.width, xOffset: 0.0)
            if (hourHandType == .HourHandTypeMsPacMan) {
                movementPath = DotsNode.rectPath(pathHeight: msPacManPathSize.height, pathWidth: msPacManPathSize.width, xOffset: 0.0)
            }
            if let ghostNode = self.childNode(withName: "ghostNode") {
                let percent = CGFloat( (hour + min/60)/12 )
                
                if let ptOnPath =  movementPath.point(at: percent) {
                    if (hourHandType == .HourHandTypePacMan) {
                        ghostNode.position = CGPoint.init(x: ptOnPath.x + pacManOffsetPoint.x, y: ptOnPath.y + pacManOffsetPoint.y)
                    }
                    if (hourHandType == .HourHandTypeMsPacMan) {
                        ghostNode.position = CGPoint.init(x: ptOnPath.x + msPacManOffsetPoint.x, y: ptOnPath.y + msPacManOffsetPoint.y)
                    }
                } else {
                    debugPrint("error pacman hand h:" + hour.description + " m:" + min.description + " p:" + percent.description)
                }
            }
            
            //EXIT
            return
        }
        
        if HourHandTypes.isDialType(type: hourHandType) {
            self.removeAllChildren() //removing by name wasny cleaing up the init one *shrug*
            addArcNode(endAngle: newZAngle)
            
            //EXIT
            return
        }
        
        self.zRotation = newZAngle
    }
    
    convenience init(hourHandType: HourHandTypes) {
        self.init(hourHandType: hourHandType, material: "#ffffffff")
    }
    
    convenience init(hourHandType: HourHandTypes, material: String) {
        self.init(hourHandType: hourHandType, material: material, strokeColor: SKColor.clear, lineWidth: 2.0, glowWidth: 0)
    }
    
    init(hourHandType: HourHandTypes, material: String, strokeColor: SKColor, lineWidth: CGFloat, glowWidth: CGFloat) {
        
        super.init(texture: nil, color: SKColor.clear, size: CGSize())
        
        self.name = "hourHand"
        self.hourHandType = hourHandType
        self.material = material
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
        self.glowWidth = glowWidth
        
        if (hourHandType == .HourHandTypePacMan || hourHandType == .HourHandTypeMsPacMan) {
            //add a ghost sprite
            //make sure to position along the path
            
            let ghostNode = SKSpriteNode.init(imageNamed: "PacManRedGost")
            ghostNode.name = "ghostNode"
            if hourHandType == .HourHandTypePacMan {
                ghostNode.setScale(0.5)
            }
            if hourHandType == .HourHandTypeMsPacMan {
                ghostNode.setScale(0.45)
            }
            self.addChild(ghostNode)
        }
        
        if (HourHandTypes.isDialType(type: hourHandType) ) {
            //fat
            let radiusCenter:CGFloat = 35.0
            innerRadius = radiusCenter - ArcNode.fatRadiusWidth/2
            outerRadius = radiusCenter + ArcNode.fatRadiusWidth/2
            
            //skinny
            if hourHandType == .HourHandTypeThinDial {
                innerRadius = radiusCenter - ArcNode.skinnyRadiusWidth/2
                outerRadius = radiusCenter + ArcNode.skinnyRadiusWidth/2
            }
            
            addArcNode( endAngle: CGFloat.pi * 0.5)
        }
        
        if (hourHandType == .HourHandTypeImageNumbers) {
            let im = UIImage.init(named: "hourHand-Numbers.png")
            if let textureImage = im {
                let texture = SKTexture.init(image: textureImage)
                let textureNode = SKSpriteNode.init(texture: texture)
                textureNode.setScale(0.4)
                //textureNode.anchorPoint = CGPoint.init(x: 0.53, y: 0.1235)   //how far from center of image
                textureNode.color = SKColor.init(hexString: material)
                textureNode.colorBlendFactor = 1.0
                
                let phy = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 30, height: 70), center: CGPoint.init(x: 0, y: 35))
                phy.isDynamic = false
                textureNode.physicsBody = phy
                
                self.addChild(textureNode)
            }
        }
        
        if (hourHandType == .HourHandTypeImageMoon) {
            let im = UIImage.init(named: "hourHand-ImageMoon.png")
            if let textureImage = im {
                let texture = SKTexture.init(image: textureImage)
                let textureNode = SKSpriteNode.init(texture: texture)
                textureNode.setScale(1.6)
                textureNode.anchorPoint = CGPoint.init(x: 0.53, y: 0.1235)   //how far from center of image
                textureNode.color = SKColor.init(hexString: material)
                textureNode.colorBlendFactor = 1.0
                
                let phy = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 40, height: 60), center: CGPoint.init(x: 0, y: 29))
                phy.isDynamic = false
                textureNode.physicsBody = phy
                
                self.addChild(textureNode)
            }
        }
        
        if (hourHandType == .HourHandTypeImageFancyWhite) {
            let im = UIImage.init(named: "hourHand-fancyWhite.png")
            if let textureImage = im {
                let texture = SKTexture.init(image: textureImage)
                let textureNode = SKSpriteNode.init(texture: texture)
                
                //this one is generated too big, scale it down
                textureNode.setScale(0.165)
                //position it to center in for rotation with time
                textureNode.position = CGPoint.init(x: 0, y: 42.0)
                textureNode.color = SKColor.init(hexString: material)
                textureNode.colorBlendFactor = 1.0
                self.addChild(textureNode)
            }
        }
        
        if (hourHandType == HourHandTypes.HourHandTypeImageLightSaber) {
            let im = UIImage.init(named: "hourHand-lightSaberWhiteShort.png")
            if let textureImage = im {
                let texture = SKTexture.init(image: textureImage)
                let textureNode = SKSpriteNode.init(texture: texture)
                
                //this one is generated too big, scale it down
                textureNode.setScale(0.65)
                //position it to center in for rotation with time
                textureNode.position = CGPoint.init(x: 0, y: 40.0)
                textureNode.color = SKColor.init(hexString: material)
                textureNode.colorBlendFactor = 1.0
                self.addChild(textureNode)
            }
        }
        
        if (hourHandType == .HourHandTypeRadar) {
            let outerRingNode = SKShapeNode.init(circleOfRadius: 40.0)
            outerRingNode.fillColor = SKColor.clear
            outerRingNode.strokeColor = SKColor.init(hexString: material)
            outerRingNode.lineWidth = 1.0
            outerRingNode.glowWidth = glowWidth
            
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: -5, y: -10))
            bezierPath.addLine(to: CGPoint(x: 5, y: -10))
            bezierPath.addLine(to: CGPoint(x: 3, y: 54))
            bezierPath.addLine(to: CGPoint(x: -3, y: 54))
            bezierPath.addLine(to: CGPoint(x: -5, y: -10))
            bezierPath.close()
            bezierPath.apply(CGAffineTransform.init(scaleX: 0.4, y: -0.4))  //scale/stratch
            
            let tickNode = SKShapeNode.init(path: bezierPath.cgPath)
            tickNode.position = CGPoint.init(x: 0, y: 36)
            
            tickNode.fillColor = SKColor.clear
            tickNode.strokeColor = SKColor.init(hexString: material)
            tickNode.lineWidth = 1.0
            tickNode.glowWidth = glowWidth
            
            outerRingNode.addChild(tickNode)
            
            self.addChild(outerRingNode)
        }
        
        if (hourHandType == .HourHandTypeSphere) {
            
            let shape = SKShapeNode.init(circleOfRadius: 5)
            shape.position = CGPoint.init(x: 0, y: 53.0)
            
            shape.setMaterial(material: material)
            shape.strokeColor = strokeColor
            shape.lineWidth = lineWidth
            shape.glowWidth = glowWidth
            
            let phy = SKPhysicsBody.init(circleOfRadius: 5)
            phy.isDynamic = false
            shape.physicsBody = phy
            
            self.addChild(shape)
        }
        
        if (hourHandType == .HourHandTypeArrow) {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: -2.5, y: -308.5))
            bezierPath.addLine(to: CGPoint(x: 57.5, y: -195.5))
            bezierPath.addLine(to: CGPoint(x: 13.5, y: -201.5))
            bezierPath.addLine(to: CGPoint(x: 34.5, y: 1.5))
            bezierPath.addLine(to: CGPoint(x: -2.5, y: 84.5))
            bezierPath.addLine(to: CGPoint(x: -37.5, y: 1.5))
            bezierPath.addLine(to: CGPoint(x: -16.5, y: -201.5))
            bezierPath.addLine(to: CGPoint(x: -57.5, y: -195.5))
            bezierPath.addLine(to: CGPoint(x: -2.5, y: -308.5))
            bezierPath.close()
            
            let scaledSize = CGFloat(0.4) * ( sizeMultiplier / 200 )
            
            //bezierPath.apply(CGAffineTransform.init(translationX: 0, y: 0)) //repos
            bezierPath.apply(CGAffineTransform.init(scaleX: scaledSize, y:-scaledSize))  //scale/stratch
            
            let shape = SKShapeNode.init(path: bezierPath.cgPath)
            shape.setMaterial(material: material)
            shape.strokeColor = strokeColor
            shape.lineWidth = lineWidth
            shape.glowWidth = glowWidth
            
            let physicsBody = SKPhysicsBody.init(polygonFrom: bezierPath.cgPath)
            physicsBody.isDynamic = false
            shape.physicsBody = physicsBody

            self.addChild(shape)
        }
        
        if (hourHandType == .HourHandTypeCapeCod || hourHandType == .HourHandTypeCapeCodFilled) {
            let bezierPath = UIBezierPath()
            
            bezierPath.move(to: CGPoint(x: -11, y: -41.61))
            bezierPath.addCurve(to: CGPoint(x: -11, y: -41.38), controlPoint1: CGPoint(x: -11, y: -41.61), controlPoint2: CGPoint(x: -11, y: -41.38))
            bezierPath.addCurve(to: CGPoint(x: -11, y: -37.23), controlPoint1: CGPoint(x: -11, y: -40.02), controlPoint2: CGPoint(x: -11, y: -38.64))
            bezierPath.addCurve(to: CGPoint(x: -11, y: -41.38), controlPoint1: CGPoint(x: -11, y: -37.23), controlPoint2: CGPoint(x: -11, y: -40.48))
            bezierPath.addCurve(to: CGPoint(x: -11, y: -41.61), controlPoint1: CGPoint(x: -11, y: -41.53), controlPoint2: CGPoint(x: -11, y: -41.61))
            bezierPath.addLine(to: CGPoint(x: -11, y: -41.61))
            bezierPath.close()
            bezierPath.move(to: CGPoint(x: 10.18, y: -127.26))
            bezierPath.addCurve(to: CGPoint(x: 11, y: -117.39), controlPoint1: CGPoint(x: 11, y: -124.65), controlPoint2: CGPoint(x: 11, y: -122.23))
            bezierPath.addLine(to: CGPoint(x: 11, y: -37.23))
            bezierPath.addCurve(to: CGPoint(x: 10.28, y: -32.16), controlPoint1: CGPoint(x: 11, y: -36.77), controlPoint2: CGPoint(x: 11, y: -34.35))
            bezierPath.addLine(to: CGPoint(x: 10.18, y: -31.74))
            bezierPath.addCurve(to: CGPoint(x: 3, y: -25.3), controlPoint1: CGPoint(x: 8.99, y: -28.48), controlPoint2: CGPoint(x: 6.26, y: -26.1))
            bezierPath.addCurve(to: CGPoint(x: 3, y: -10.59), controlPoint1: CGPoint(x: 3, y: -19.86), controlPoint2: CGPoint(x: 3, y: -14.88))
            bezierPath.addCurve(to: CGPoint(x: 11, y: 0), controlPoint1: CGPoint(x: 7.62, y: -9.28), controlPoint2: CGPoint(x: 11, y: -5.04))
            bezierPath.addCurve(to: CGPoint(x: -0, y: 11), controlPoint1: CGPoint(x: 11, y: 6.08), controlPoint2: CGPoint(x: 6.08, y: 11))
            bezierPath.addCurve(to: CGPoint(x: -11, y: 0), controlPoint1: CGPoint(x: -6.08, y: 11), controlPoint2: CGPoint(x: -11, y: 6.08))
            bezierPath.addCurve(to: CGPoint(x: -3, y: -10.59), controlPoint1: CGPoint(x: -11, y: -5.04), controlPoint2: CGPoint(x: -7.62, y: -9.28))
            bezierPath.addCurve(to: CGPoint(x: -3, y: -25.3), controlPoint1: CGPoint(x: -3, y: -14.88), controlPoint2: CGPoint(x: -3, y: -19.86))
            bezierPath.addCurve(to: CGPoint(x: -10.18, y: -31.74), controlPoint1: CGPoint(x: -6.26, y: -26.1), controlPoint2: CGPoint(x: -8.99, y: -28.48))
            bezierPath.addCurve(to: CGPoint(x: -10.96, y: -37.23), controlPoint1: CGPoint(x: -10.71, y: -33.42), controlPoint2: CGPoint(x: -10.89, y: -35.02))
            bezierPath.addCurve(to: CGPoint(x: -11, y: -41.38), controlPoint1: CGPoint(x: -11, y: -38.41), controlPoint2: CGPoint(x: -11, y: -39.76))
            bezierPath.addLine(to: CGPoint(x: -11, y: -41.61))
            bezierPath.addCurve(to: CGPoint(x: -10.28, y: -126.84), controlPoint1: CGPoint(x: -11, y: -122.32), controlPoint2: CGPoint(x: -10.99, y: -124.69))
            bezierPath.addLine(to: CGPoint(x: -10.18, y: -127.26))
            bezierPath.addCurve(to: CGPoint(x: -0.55, y: -134), controlPoint1: CGPoint(x: -8.7, y: -131.31), controlPoint2: CGPoint(x: -4.86, y: -134))
            bezierPath.addLine(to: CGPoint(x: 0.55, y: -134))
            bezierPath.addCurve(to: CGPoint(x: 10.18, y: -127.26), controlPoint1: CGPoint(x: 4.86, y: -134), controlPoint2: CGPoint(x: 8.7, y: -131.31))
            bezierPath.close()
            
            bezierPath.apply(CGAffineTransform.init(scaleX: 0.5, y: -0.5))
            bezierPath.flatness = 0.01
            
            let shape = SKShapeNode.init(path: bezierPath.cgPath)
            shape.setMaterial(material: material)
            shape.strokeColor = strokeColor
            shape.lineWidth = lineWidth
            shape.glowWidth = glowWidth
            
            let physicsBody = SKPhysicsBody.init(polygonFrom: bezierPath.cgPath)
            physicsBody.isDynamic = false
            shape.physicsBody = physicsBody
            
            self.addChild(shape)
            
            if (hourHandType == .HourHandTypeCapeCodFilled) {
                let rectanglePath = UIBezierPath(roundedRect: CGRect(x: -7, y: -129, width: 14, height: 98), cornerRadius: 6)
                rectanglePath.apply(CGAffineTransform.init(scaleX: 0.5, y: -0.5))
                
                let fillShape = SKShapeNode.init(path: rectanglePath.cgPath)
                fillShape.fillColor = SKColor.black
                fillShape.strokeColor = SKColor.black
                fillShape.lineWidth = 1.0
                
                self.addChild(fillShape)
            }
        }
            
        
        if (hourHandType == .HourHandTypeCutout) {
            let cutWidth = 9
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: cutWidth, y: 56))
            bezierPath.addLine(to: CGPoint(x: -cutWidth, y: 56))
            bezierPath.addLine(to: CGPoint(x: -cutWidth, y: 0))
            bezierPath.addLine(to: CGPoint(x: cutWidth, y: 0))
            bezierPath.addLine(to: CGPoint(x: cutWidth, y: 56))
            bezierPath.close()
            bezierPath.move(to: CGPoint(x: 100, y: -0))
            bezierPath.addCurve(to: CGPoint(x: -0, y: -100), controlPoint1: CGPoint(x: 100, y: -55.23), controlPoint2: CGPoint(x: 55.23, y: -100))
            bezierPath.addCurve(to: CGPoint(x: -100, y: 0), controlPoint1: CGPoint(x: -55.23, y: -100), controlPoint2: CGPoint(x: -100, y: -55.23))
            bezierPath.addCurve(to: CGPoint(x: 0, y: 100), controlPoint1: CGPoint(x: -100, y: 55.23), controlPoint2: CGPoint(x: -55.23, y: 100))
            bezierPath.addCurve(to: CGPoint(x: 100, y: -0), controlPoint1: CGPoint(x: 55.23, y: 100), controlPoint2: CGPoint(x: 100, y: 55.23))
            bezierPath.close()
            
            bezierPath.flatness = 0.01
            
            let shape = SKShapeNode.init(path: bezierPath.cgPath)
            shape.setMaterial(material: material)
            shape.strokeColor = strokeColor
            shape.lineWidth = lineWidth
            shape.glowWidth = glowWidth
            
            let physicsBody = SKPhysicsBody.init(polygonFrom: bezierPath.cgPath)
            physicsBody.isDynamic = false
            shape.physicsBody = physicsBody
            
            self.addChild(shape)
        }
        
        
        if (hourHandType == .HourHandTypeBoxy) {
            
            let rectanglePath = UIBezierPath(rect: CGRect(x: -1.5, y: -11, width: 3, height: 60))
            
            let shape = SKShapeNode.init(path: rectanglePath.cgPath)
            shape.setMaterial(material: material)
            shape.strokeColor = strokeColor
            shape.lineWidth = lineWidth
            shape.glowWidth = glowWidth
            
            let physicsBody = SKPhysicsBody.init(polygonFrom: rectanglePath.cgPath)
            physicsBody.isDynamic = false
            shape.physicsBody = physicsBody
            
            self.addChild(shape)
        }
        
        if (hourHandType == .HourHandTypeFatBoxy) {
            
            let rectanglePath = UIBezierPath(rect: CGRect(x: -3, y: -15, width: 6, height: 65))
            
            let shape = SKShapeNode.init(path: rectanglePath.cgPath)
            shape.setMaterial(material: material)
            shape.strokeColor = strokeColor
            shape.lineWidth = lineWidth
            shape.glowWidth = glowWidth
            
            let physicsBody = SKPhysicsBody.init(polygonFrom: rectanglePath.cgPath)
            physicsBody.isDynamic = false
            shape.physicsBody = physicsBody
            
            self.addChild(shape)
        }
        
        if (hourHandType == .HourHandTypeSquaredHole) {
            
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 1.5, y: 60))
            bezierPath.addLine(to: CGPoint(x: -1.5, y: 60))
            bezierPath.addLine(to: CGPoint(x: -1.5, y: 52))
            bezierPath.addLine(to: CGPoint(x: 1.5, y: 52))
            bezierPath.addLine(to: CGPoint(x: 1.5, y: 60))
            bezierPath.close()
            bezierPath.move(to: CGPoint(x: 4, y: 65))
            bezierPath.addCurve(to: CGPoint(x: 4, y: -10), controlPoint1: CGPoint(x: 4, y: 65), controlPoint2: CGPoint(x: 4, y: -10))
            bezierPath.addLine(to: CGPoint(x: -4, y: -10))
            bezierPath.addLine(to: CGPoint(x: -4, y: 65))
            bezierPath.addLine(to: CGPoint(x: 4, y: 65))
            bezierPath.addLine(to: CGPoint(x: 4, y: 65))
            bezierPath.close()
            
            let shape = SKShapeNode.init(path: bezierPath.cgPath)
            shape.setMaterial(material: material)
            shape.strokeColor = strokeColor
            shape.lineWidth = lineWidth
            shape.glowWidth = glowWidth
            
            let physicsBody = SKPhysicsBody.init(polygonFrom: bezierPath.cgPath)
            physicsBody.isDynamic = false
            shape.physicsBody = physicsBody
            
            self.addChild(shape)
        }
        
        if (hourHandType == .HourHandTypeSwiss) {
            
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: -5, y: -10))
            bezierPath.addLine(to: CGPoint(x: 5, y: -10))
            bezierPath.addLine(to: CGPoint(x: 3, y: 54))
            bezierPath.addLine(to: CGPoint(x: -3, y: 54))
            bezierPath.addLine(to: CGPoint(x: -5, y: -10))
            bezierPath.close()
            
            let shape = SKShapeNode.init(path: bezierPath.cgPath)
            shape.setMaterial(material: material)
            shape.strokeColor = strokeColor
            shape.lineWidth = lineWidth
            shape.glowWidth = glowWidth
            
            let physicsBody = SKPhysicsBody.init(polygonFrom: bezierPath.cgPath)
            physicsBody.isDynamic = false
            shape.physicsBody = physicsBody
            
            self.addChild(shape)
        }
        
        if (hourHandType == .HourHandTypeRounded) {
            
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 3, y: 43.5))
            bezierPath.addCurve(to: CGPoint(x: 3, y: 5.77), controlPoint1: CGPoint(x: 3, y: 43.5), controlPoint2: CGPoint(x: 3, y: 20.44))
            bezierPath.addCurve(to: CGPoint(x: 6.5, y: 0), controlPoint1: CGPoint(x: 5.08, y: 4.68), controlPoint2: CGPoint(x: 6.5, y: 2.51))
            bezierPath.addCurve(to: CGPoint(x: -0, y: -6.5), controlPoint1: CGPoint(x: 6.5, y: -3.59), controlPoint2: CGPoint(x: 3.59, y: -6.5))
            bezierPath.addCurve(to: CGPoint(x: -6.5, y: 0), controlPoint1: CGPoint(x: -3.59, y: -6.5), controlPoint2: CGPoint(x: -6.5, y: -3.59))
            bezierPath.addCurve(to: CGPoint(x: -3, y: 5.77), controlPoint1: CGPoint(x: -6.5, y: 2.51), controlPoint2: CGPoint(x: -5.08, y: 4.68))
            bezierPath.addCurve(to: CGPoint(x: -3, y: 43.5), controlPoint1: CGPoint(x: -3, y: 20.44), controlPoint2: CGPoint(x: -3, y: 43.5))
            bezierPath.addCurve(to: CGPoint(x: 0, y: 46.5), controlPoint1: CGPoint(x: -3, y: 45.16), controlPoint2: CGPoint(x: -1.66, y: 46.5))
            bezierPath.addCurve(to: CGPoint(x: 3, y: 43.5), controlPoint1: CGPoint(x: 1.66, y: 46.5), controlPoint2: CGPoint(x: 3, y: 45.16))
            bezierPath.close()
            
            bezierPath.flatness = 0.01
            
            let shape = SKShapeNode.init(path: bezierPath.cgPath)
            shape.setMaterial(material: material)
            shape.strokeColor = strokeColor
            shape.lineWidth = lineWidth
            shape.glowWidth = glowWidth
            
            let physicsBody = SKPhysicsBody.init(polygonFrom: bezierPath.cgPath)
            physicsBody.isDynamic = false
            shape.physicsBody = physicsBody
            
            self.addChild(shape)
        }
        
        if (hourHandType == .HourHandTypeRoman) {
            
            let hourHandPath = UIBezierPath()
            hourHandPath.move(to: CGPoint(x: 0.08, y: 168.9))
            hourHandPath.addCurve(to: CGPoint(x: 4.82, y: 137.8), controlPoint1: CGPoint(x: 0.08, y: 168.9), controlPoint2: CGPoint(x: 4.82, y: 154.98))
            hourHandPath.addCurve(to: CGPoint(x: 1.44, y: 111.45), controlPoint1: CGPoint(x: 4.82, y: 126.69), controlPoint2: CGPoint(x: 2.84, y: 116.95))
            hourHandPath.addCurve(to: CGPoint(x: 6.42, y: 112.94), controlPoint1: CGPoint(x: 3.24, y: 112.24), controlPoint2: CGPoint(x: 5.17, y: 112.94))
            hourHandPath.addCurve(to: CGPoint(x: 11.58, y: 109.25), controlPoint1: CGPoint(x: 9.27, y: 112.94), controlPoint2: CGPoint(x: 11.58, y: 111.29))
            hourHandPath.addCurve(to: CGPoint(x: 6.42, y: 105.56), controlPoint1: CGPoint(x: 11.58, y: 107.21), controlPoint2: CGPoint(x: 9.27, y: 105.56))
            hourHandPath.addCurve(to: CGPoint(x: 2.15, y: 106.74), controlPoint1: CGPoint(x: 5.34, y: 105.56), controlPoint2: CGPoint(x: 3.73, y: 106.08))
            hourHandPath.addCurve(to: CGPoint(x: 8.47, y: 101.62), controlPoint1: CGPoint(x: 3.8, y: 103.33), controlPoint2: CGPoint(x: 6.1, y: 99.4))
            hourHandPath.addCurve(to: CGPoint(x: 14.95, y: 109.06), controlPoint1: CGPoint(x: 9.89, y: 102.82), controlPoint2: CGPoint(x: 13.58, y: 106.12))
            hourHandPath.addCurve(to: CGPoint(x: 15.68, y: 115.19), controlPoint1: CGPoint(x: 16.62, y: 112.03), controlPoint2: CGPoint(x: 15.98, y: 114.64))
            hourHandPath.addCurve(to: CGPoint(x: 22.09, y: 113.29), controlPoint1: CGPoint(x: 13.32, y: 117.2), controlPoint2: CGPoint(x: 23.02, y: 112.65))
            hourHandPath.addCurve(to: CGPoint(x: 22.12, y: 113.26), controlPoint1: CGPoint(x: 22.07, y: 113.24), controlPoint2: CGPoint(x: 22.12, y: 113.26))
            hourHandPath.addCurve(to: CGPoint(x: 19.06, y: 106.44), controlPoint1: CGPoint(x: 24.62, y: 112.97), controlPoint2: CGPoint(x: 24.25, y: 110.31))
            hourHandPath.addCurve(to: CGPoint(x: 9.03, y: 100.03), controlPoint1: CGPoint(x: 16.39, y: 104.29), controlPoint2: CGPoint(x: 12.06, y: 101.72))
            hourHandPath.addCurve(to: CGPoint(x: 13.21, y: 100.92), controlPoint1: CGPoint(x: 10.36, y: 100.54), controlPoint2: CGPoint(x: 11.77, y: 100.84))
            hourHandPath.addCurve(to: CGPoint(x: 22.75, y: 97.77), controlPoint1: CGPoint(x: 16.52, y: 101.1), controlPoint2: CGPoint(x: 20.01, y: 100.03))
            hourHandPath.addCurve(to: CGPoint(x: 27.82, y: 88.23), controlPoint1: CGPoint(x: 25.5, y: 95.54), controlPoint2: CGPoint(x: 27.47, y: 92.06))
            hourHandPath.addCurve(to: CGPoint(x: 27.17, y: 82.44), controlPoint1: CGPoint(x: 27.99, y: 86.34), controlPoint2: CGPoint(x: 27.79, y: 84.32))
            hourHandPath.addCurve(to: CGPoint(x: 24.16, y: 77.28), controlPoint1: CGPoint(x: 26.55, y: 80.55), controlPoint2: CGPoint(x: 25.51, y: 78.78))
            hourHandPath.addCurve(to: CGPoint(x: 13.21, y: 72.45), controlPoint1: CGPoint(x: 21.46, y: 74.25), controlPoint2: CGPoint(x: 17.34, y: 72.41))
            hourHandPath.addCurve(to: CGPoint(x: 11.41, y: 72.57), controlPoint1: CGPoint(x: 12.61, y: 72.45), controlPoint2: CGPoint(x: 12, y: 72.5))
            hourHandPath.addCurve(to: CGPoint(x: 19.11, y: 67.51), controlPoint1: CGPoint(x: 14.08, y: 71.03), controlPoint2: CGPoint(x: 17.09, y: 69.15))
            hourHandPath.addCurve(to: CGPoint(x: 22.1, y: 60.64), controlPoint1: CGPoint(x: 24.3, y: 63.65), controlPoint2: CGPoint(x: 24.6, y: 60.96))
            hourHandPath.addCurve(to: CGPoint(x: 15.77, y: 58.84), controlPoint1: CGPoint(x: 23.03, y: 61.27), controlPoint2: CGPoint(x: 13.43, y: 56.76))
            hourHandPath.addCurve(to: CGPoint(x: 14.97, y: 65.04), controlPoint1: CGPoint(x: 16.07, y: 59.42), controlPoint2: CGPoint(x: 16.68, y: 62.06))
            hourHandPath.addCurve(to: CGPoint(x: 8.38, y: 72.47), controlPoint1: CGPoint(x: 13.57, y: 67.98), controlPoint2: CGPoint(x: 9.83, y: 71.28))
            hourHandPath.addCurve(to: CGPoint(x: 2.15, y: 67.3), controlPoint1: CGPoint(x: 6.04, y: 74.65), controlPoint2: CGPoint(x: 3.77, y: 70.72))
            hourHandPath.addCurve(to: CGPoint(x: 6.28, y: 68.44), controlPoint1: CGPoint(x: 3.69, y: 67.93), controlPoint2: CGPoint(x: 5.23, y: 68.44))
            hourHandPath.addCurve(to: CGPoint(x: 11.45, y: 64.74), controlPoint1: CGPoint(x: 9.14, y: 68.44), controlPoint2: CGPoint(x: 11.45, y: 66.78))
            hourHandPath.addCurve(to: CGPoint(x: 6.28, y: 61.05), controlPoint1: CGPoint(x: 11.45, y: 62.71), controlPoint2: CGPoint(x: 9.14, y: 61.05))
            hourHandPath.addCurve(to: CGPoint(x: 1.31, y: 62.54), controlPoint1: CGPoint(x: 5.04, y: 61.05), controlPoint2: CGPoint(x: 3.1, y: 61.75))
            hourHandPath.addCurve(to: CGPoint(x: 4.7, y: 36.19), controlPoint1: CGPoint(x: 2.71, y: 57.04), controlPoint2: CGPoint(x: 4.7, y: 47.3))
            hourHandPath.addCurve(to: CGPoint(x: -0.03, y: -5.61), controlPoint1: CGPoint(x: 4.7, y: 19.01), controlPoint2: CGPoint(x: -0.03, y: -5.61))
            hourHandPath.addCurve(to: CGPoint(x: -4.78, y: 36.18), controlPoint1: CGPoint(x: -0.03, y: -5.61), controlPoint2: CGPoint(x: -4.78, y: 19.01))
            hourHandPath.addCurve(to: CGPoint(x: -1.4, y: 62.54), controlPoint1: CGPoint(x: -4.78, y: 47.29), controlPoint2: CGPoint(x: -2.8, y: 57.04))
            hourHandPath.addCurve(to: CGPoint(x: -6.37, y: 61.05), controlPoint1: CGPoint(x: -3.19, y: 61.75), controlPoint2: CGPoint(x: -5.13, y: 61.05))
            hourHandPath.addCurve(to: CGPoint(x: -11.54, y: 64.74), controlPoint1: CGPoint(x: -9.23, y: 61.05), controlPoint2: CGPoint(x: -11.54, y: 62.7))
            hourHandPath.addCurve(to: CGPoint(x: -6.37, y: 68.43), controlPoint1: CGPoint(x: -11.54, y: 66.78), controlPoint2: CGPoint(x: -9.23, y: 68.43))
            hourHandPath.addCurve(to: CGPoint(x: -2.11, y: 67.25), controlPoint1: CGPoint(x: -5.29, y: 68.43), controlPoint2: CGPoint(x: -3.69, y: 67.9))
            hourHandPath.addCurve(to: CGPoint(x: -8.42, y: 72.37), controlPoint1: CGPoint(x: -3.75, y: 70.66), controlPoint2: CGPoint(x: -6.06, y: 74.59))
            hourHandPath.addCurve(to: CGPoint(x: -14.91, y: 64.93), controlPoint1: CGPoint(x: -9.85, y: 71.17), controlPoint2: CGPoint(x: -13.54, y: 67.87))
            hourHandPath.addCurve(to: CGPoint(x: -15.63, y: 58.8), controlPoint1: CGPoint(x: -16.58, y: 61.96), controlPoint2: CGPoint(x: -15.93, y: 59.35))
            hourHandPath.addCurve(to: CGPoint(x: -22.05, y: 60.7), controlPoint1: CGPoint(x: -13.28, y: 56.79), controlPoint2: CGPoint(x: -22.98, y: 61.34))
            hourHandPath.addCurve(to: CGPoint(x: -22.08, y: 60.73), controlPoint1: CGPoint(x: -22.02, y: 60.75), controlPoint2: CGPoint(x: -22.08, y: 60.73))
            hourHandPath.addCurve(to: CGPoint(x: -19.01, y: 67.55), controlPoint1: CGPoint(x: -24.58, y: 61.02), controlPoint2: CGPoint(x: -24.21, y: 63.68))
            hourHandPath.addCurve(to: CGPoint(x: -10.31, y: 73.21), controlPoint1: CGPoint(x: -16.72, y: 69.4), controlPoint2: CGPoint(x: -13.19, y: 71.57))
            hourHandPath.addCurve(to: CGPoint(x: -15.02, y: 72.45), controlPoint1: CGPoint(x: -11.83, y: 72.7), controlPoint2: CGPoint(x: -13.42, y: 72.43))
            hourHandPath.addCurve(to: CGPoint(x: -25.83, y: 77.41), controlPoint1: CGPoint(x: -19.15, y: 72.42), controlPoint2: CGPoint(x: -23.25, y: 74.34))
            hourHandPath.addCurve(to: CGPoint(x: -29.45, y: 88.22), controlPoint1: CGPoint(x: -28.48, y: 80.42), controlPoint2: CGPoint(x: -29.76, y: 84.45))
            hourHandPath.addCurve(to: CGPoint(x: -29.37, y: 88.85), controlPoint1: CGPoint(x: -29.45, y: 88.3), controlPoint2: CGPoint(x: -29.37, y: 88.85))
            hourHandPath.addCurve(to: CGPoint(x: -29.26, y: 89.61), controlPoint1: CGPoint(x: -29.34, y: 89.09), controlPoint2: CGPoint(x: -29.31, y: 89.36))
            hourHandPath.addCurve(to: CGPoint(x: -28.9, y: 90.98), controlPoint1: CGPoint(x: -29.16, y: 90.08), controlPoint2: CGPoint(x: -29.05, y: 90.53))
            hourHandPath.addCurve(to: CGPoint(x: -27.72, y: 93.48), controlPoint1: CGPoint(x: -28.61, y: 91.86), controlPoint2: CGPoint(x: -28.21, y: 92.71))
            hourHandPath.addCurve(to: CGPoint(x: -24.11, y: 97.3), controlPoint1: CGPoint(x: -26.75, y: 95.03), controlPoint2: CGPoint(x: -25.47, y: 96.29))
            hourHandPath.addCurve(to: CGPoint(x: -14.99, y: 100.92), controlPoint1: CGPoint(x: -21.39, y: 99.27), controlPoint2: CGPoint(x: -18.43, y: 100.76))
            hourHandPath.addCurve(to: CGPoint(x: -5.48, y: 97.76), controlPoint1: CGPoint(x: -11.75, y: 101.09), controlPoint2: CGPoint(x: -8.21, y: 100.03))
            hourHandPath.addCurve(to: CGPoint(x: -0.83, y: 90.45), controlPoint1: CGPoint(x: -3.28, y: 95.95), controlPoint2: CGPoint(x: -1.6, y: 93.43))
            hourHandPath.addCurve(to: CGPoint(x: -0.67, y: 90.98), controlPoint1: CGPoint(x: -0.78, y: 90.62), controlPoint2: CGPoint(x: -0.73, y: 90.8))
            hourHandPath.addCurve(to: CGPoint(x: 0.51, y: 93.48), controlPoint1: CGPoint(x: -0.38, y: 91.87), controlPoint2: CGPoint(x: 0.03, y: 92.71))
            hourHandPath.addCurve(to: CGPoint(x: 4.12, y: 97.3), controlPoint1: CGPoint(x: 1.48, y: 95.03), controlPoint2: CGPoint(x: 2.77, y: 96.29))
            hourHandPath.addCurve(to: CGPoint(x: 5.33, y: 98.14), controlPoint1: CGPoint(x: 4.52, y: 97.6), controlPoint2: CGPoint(x: 4.93, y: 97.87))
            hourHandPath.addCurve(to: CGPoint(x: 0.35, y: 107.53), controlPoint1: CGPoint(x: 3.61, y: 97.93), controlPoint2: CGPoint(x: 1.42, y: 103.54))
            hourHandPath.addCurve(to: CGPoint(x: 0.09, y: 106.71), controlPoint1: CGPoint(x: 0.19, y: 107), controlPoint2: CGPoint(x: 0.09, y: 106.71))
            hourHandPath.addCurve(to: CGPoint(x: -0.18, y: 107.54), controlPoint1: CGPoint(x: 0.09, y: 106.71), controlPoint2: CGPoint(x: -0.01, y: 107))
            hourHandPath.addCurve(to: CGPoint(x: -0.34, y: 107.47), controlPoint1: CGPoint(x: -0.23, y: 107.52), controlPoint2: CGPoint(x: -0.28, y: 107.49))
            hourHandPath.addCurve(to: CGPoint(x: -5.49, y: 98.24), controlPoint1: CGPoint(x: -1.46, y: 103.28), controlPoint2: CGPoint(x: -3.7, y: 97.37))
            hourHandPath.addCurve(to: CGPoint(x: -19.06, y: 106.48), controlPoint1: CGPoint(x: -5.16, y: 98), controlPoint2: CGPoint(x: -14.56, y: 102.82))
            hourHandPath.addCurve(to: CGPoint(x: -22.05, y: 113.35), controlPoint1: CGPoint(x: -24.26, y: 110.34), controlPoint2: CGPoint(x: -24.55, y: 113.03))
            hourHandPath.addCurve(to: CGPoint(x: -22.04, y: 113.31), controlPoint1: CGPoint(x: -22.09, y: 113.33), controlPoint2: CGPoint(x: -22.04, y: 113.31))
            hourHandPath.addCurve(to: CGPoint(x: -15.73, y: 115.15), controlPoint1: CGPoint(x: -22.99, y: 112.72), controlPoint2: CGPoint(x: -13.38, y: 117.23))
            hourHandPath.addCurve(to: CGPoint(x: -14.93, y: 108.95), controlPoint1: CGPoint(x: -16.02, y: 114.57), controlPoint2: CGPoint(x: -16.64, y: 111.93))
            hourHandPath.addCurve(to: CGPoint(x: -8.34, y: 101.52), controlPoint1: CGPoint(x: -13.52, y: 106.01), controlPoint2: CGPoint(x: -9.78, y: 102.71))
            hourHandPath.addCurve(to: CGPoint(x: -2.1, y: 106.69), controlPoint1: CGPoint(x: -6, y: 99.34), controlPoint2: CGPoint(x: -3.73, y: 103.27))
            hourHandPath.addCurve(to: CGPoint(x: -6.24, y: 105.55), controlPoint1: CGPoint(x: -3.64, y: 106.05), controlPoint2: CGPoint(x: -5.19, y: 105.55))
            hourHandPath.addCurve(to: CGPoint(x: -11.41, y: 109.24), controlPoint1: CGPoint(x: -9.09, y: 105.55), controlPoint2: CGPoint(x: -11.41, y: 107.21))
            hourHandPath.addCurve(to: CGPoint(x: -6.24, y: 112.94), controlPoint1: CGPoint(x: -11.41, y: 111.28), controlPoint2: CGPoint(x: -9.09, y: 112.94))
            hourHandPath.addCurve(to: CGPoint(x: -1.27, y: 111.45), controlPoint1: CGPoint(x: -5, y: 112.94), controlPoint2: CGPoint(x: -3.06, y: 112.24))
            hourHandPath.addCurve(to: CGPoint(x: -4.65, y: 137.8), controlPoint1: CGPoint(x: -2.67, y: 116.95), controlPoint2: CGPoint(x: -4.65, y: 126.69))
            hourHandPath.addCurve(to: CGPoint(x: 0.08, y: 168.9), controlPoint1: CGPoint(x: -4.66, y: 154.98), controlPoint2: CGPoint(x: 0.08, y: 168.9))
            hourHandPath.addLine(to: CGPoint(x: 0.08, y: 168.9))
            hourHandPath.close()
            hourHandPath.move(to: CGPoint(x: -18.91, y: 97.59))
            hourHandPath.addCurve(to: CGPoint(x: -21.97, y: 95.16), controlPoint1: CGPoint(x: -20.14, y: 97.11), controlPoint2: CGPoint(x: -21.24, y: 96.25))
            hourHandPath.addCurve(to: CGPoint(x: -23.27, y: 91.63), controlPoint1: CGPoint(x: -22.71, y: 94.07), controlPoint2: CGPoint(x: -23.11, y: 92.82))
            hourHandPath.addCurve(to: CGPoint(x: -23.38, y: 89.88), controlPoint1: CGPoint(x: -23.35, y: 91.03), controlPoint2: CGPoint(x: -23.38, y: 90.45))
            hourHandPath.addCurve(to: CGPoint(x: -23.34, y: 89.05), controlPoint1: CGPoint(x: -23.37, y: 89.6), controlPoint2: CGPoint(x: -23.37, y: 89.31))
            hourHandPath.addCurve(to: CGPoint(x: -23.31, y: 88.7), controlPoint1: CGPoint(x: -23.33, y: 88.93), controlPoint2: CGPoint(x: -23.32, y: 88.83))
            hourHandPath.addCurve(to: CGPoint(x: -23.27, y: 88.22), controlPoint1: CGPoint(x: -23.31, y: 88.7), controlPoint2: CGPoint(x: -23.29, y: 88.37))
            hourHandPath.addLine(to: CGPoint(x: -23.26, y: 88.14))
            hourHandPath.addCurve(to: CGPoint(x: -20.24, y: 83), controlPoint1: CGPoint(x: -22.95, y: 86), controlPoint2: CGPoint(x: -21.8, y: 84.16))
            hourHandPath.addCurve(to: CGPoint(x: -15.03, y: 81.33), controlPoint1: CGPoint(x: -18.64, y: 81.85), controlPoint2: CGPoint(x: -16.84, y: 81.32))
            hourHandPath.addCurve(to: CGPoint(x: -6.99, y: 88.24), controlPoint1: CGPoint(x: -11.48, y: 81.34), controlPoint2: CGPoint(x: -7.77, y: 83.81))
            hourHandPath.addCurve(to: CGPoint(x: -6.95, y: 88.42), controlPoint1: CGPoint(x: -6.96, y: 88.32), controlPoint2: CGPoint(x: -6.95, y: 88.42))
            hourHandPath.addLine(to: CGPoint(x: -6.92, y: 88.62))
            hourHandPath.addLine(to: CGPoint(x: -6.88, y: 89.03))
            hourHandPath.addCurve(to: CGPoint(x: -6.85, y: 89.85), controlPoint1: CGPoint(x: -6.86, y: 89.3), controlPoint2: CGPoint(x: -6.85, y: 89.57))
            hourHandPath.addCurve(to: CGPoint(x: -7.06, y: 91.52), controlPoint1: CGPoint(x: -6.87, y: 90.4), controlPoint2: CGPoint(x: -6.94, y: 90.96))
            hourHandPath.addCurve(to: CGPoint(x: -8.54, y: 94.7), controlPoint1: CGPoint(x: -7.33, y: 92.62), controlPoint2: CGPoint(x: -7.81, y: 93.74))
            hourHandPath.addCurve(to: CGPoint(x: -15.06, y: 98.18), controlPoint1: CGPoint(x: -10.01, y: 96.66), controlPoint2: CGPoint(x: -12.36, y: 98.04))
            hourHandPath.addCurve(to: CGPoint(x: -18.91, y: 97.59), controlPoint1: CGPoint(x: -16.3, y: 98.27), controlPoint2: CGPoint(x: -17.69, y: 98.07))
            hourHandPath.close()
            hourHandPath.move(to: CGPoint(x: 9.32, y: 97.6))
            hourHandPath.addCurve(to: CGPoint(x: 6.26, y: 95.17), controlPoint1: CGPoint(x: 8.09, y: 97.11), controlPoint2: CGPoint(x: 7, y: 96.25))
            hourHandPath.addCurve(to: CGPoint(x: 4.96, y: 91.64), controlPoint1: CGPoint(x: 5.52, y: 94.08), controlPoint2: CGPoint(x: 5.12, y: 92.83))
            hourHandPath.addCurve(to: CGPoint(x: 4.86, y: 89.89), controlPoint1: CGPoint(x: 4.88, y: 91.04), controlPoint2: CGPoint(x: 4.85, y: 90.45))
            hourHandPath.addCurve(to: CGPoint(x: 4.89, y: 89.05), controlPoint1: CGPoint(x: 4.87, y: 89.6), controlPoint2: CGPoint(x: 4.87, y: 89.32))
            hourHandPath.addCurve(to: CGPoint(x: 4.92, y: 88.7), controlPoint1: CGPoint(x: 4.91, y: 88.93), controlPoint2: CGPoint(x: 4.91, y: 88.84))
            hourHandPath.addCurve(to: CGPoint(x: 4.96, y: 88.22), controlPoint1: CGPoint(x: 4.92, y: 88.7), controlPoint2: CGPoint(x: 4.95, y: 88.38))
            hourHandPath.addLine(to: CGPoint(x: 4.98, y: 88.15))
            hourHandPath.addCurve(to: CGPoint(x: 7.99, y: 83), controlPoint1: CGPoint(x: 5.28, y: 86), controlPoint2: CGPoint(x: 6.44, y: 84.16))
            hourHandPath.addCurve(to: CGPoint(x: 13.21, y: 81.33), controlPoint1: CGPoint(x: 9.59, y: 81.85), controlPoint2: CGPoint(x: 11.39, y: 81.32))
            hourHandPath.addCurve(to: CGPoint(x: 18.29, y: 83.15), controlPoint1: CGPoint(x: 15.02, y: 81.35), controlPoint2: CGPoint(x: 16.79, y: 81.96))
            hourHandPath.addCurve(to: CGPoint(x: 21.26, y: 88.22), controlPoint1: CGPoint(x: 19.75, y: 84.34), controlPoint2: CGPoint(x: 20.91, y: 86.09))
            hourHandPath.addCurve(to: CGPoint(x: 19.69, y: 94.71), controlPoint1: CGPoint(x: 21.64, y: 90.33), controlPoint2: CGPoint(x: 21.16, y: 92.75))
            hourHandPath.addCurve(to: CGPoint(x: 13.21, y: 98.19), controlPoint1: CGPoint(x: 18.24, y: 96.66), controlPoint2: CGPoint(x: 15.84, y: 98.04))
            hourHandPath.addCurve(to: CGPoint(x: 9.32, y: 97.6), controlPoint1: CGPoint(x: 11.9, y: 98.28), controlPoint2: CGPoint(x: 10.56, y: 98.07))
            hourHandPath.close()
            hourHandPath.move(to: CGPoint(x: -0.78, y: 83.49))
            hourHandPath.addCurve(to: CGPoint(x: -1.06, y: 82.44), controlPoint1: CGPoint(x: -0.87, y: 83.13), controlPoint2: CGPoint(x: -0.95, y: 82.78))
            hourHandPath.addCurve(to: CGPoint(x: -4.08, y: 77.27), controlPoint1: CGPoint(x: -1.69, y: 80.55), controlPoint2: CGPoint(x: -2.72, y: 78.78))
            hourHandPath.addLine(to: CGPoint(x: -5.8, y: 75.67))
            hourHandPath.addCurve(to: CGPoint(x: -5.55, y: 75.78), controlPoint1: CGPoint(x: -5.6, y: 75.77), controlPoint2: CGPoint(x: -5.5, y: 75.81))
            hourHandPath.addCurve(to: CGPoint(x: -0.31, y: 66.46), controlPoint1: CGPoint(x: -3.79, y: 76.64), controlPoint2: CGPoint(x: -1.43, y: 70.65))
            hourHandPath.addCurve(to: CGPoint(x: -0.05, y: 67.28), controlPoint1: CGPoint(x: -0.14, y: 66.99), controlPoint2: CGPoint(x: -0.05, y: 67.28))
            hourHandPath.addCurve(to: CGPoint(x: 0.22, y: 66.45), controlPoint1: CGPoint(x: -0.05, y: 67.28), controlPoint2: CGPoint(x: 0.05, y: 66.99))
            hourHandPath.addCurve(to: CGPoint(x: 0.38, y: 66.52), controlPoint1: CGPoint(x: 0.27, y: 66.47), controlPoint2: CGPoint(x: 0.33, y: 66.5))
            hourHandPath.addCurve(to: CGPoint(x: 4.4, y: 75.51), controlPoint1: CGPoint(x: 1.27, y: 69.86), controlPoint2: CGPoint(x: 2.88, y: 74.29))
            hourHandPath.addCurve(to: CGPoint(x: 2.4, y: 77.41), controlPoint1: CGPoint(x: 3.67, y: 76.08), controlPoint2: CGPoint(x: 2.99, y: 76.71))
            hourHandPath.addCurve(to: CGPoint(x: -0.78, y: 83.49), controlPoint1: CGPoint(x: 0.85, y: 79.17), controlPoint2: CGPoint(x: -0.21, y: 81.29))
            hourHandPath.close()
            
            hourHandPath.flatness = 0.1
            
            let shape = SKShapeNode.init(path: hourHandPath.cgPath)
            shape.setScale(0.35)
            shape.setMaterial(material: material)
            shape.strokeColor = strokeColor
            shape.lineWidth = lineWidth
            shape.glowWidth = glowWidth
            
            let physicsBody = SKPhysicsBody.init(polygonFrom: hourHandPath.cgPath)
            physicsBody.isDynamic = false
            shape.physicsBody = physicsBody
            
            self.addChild(shape)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

