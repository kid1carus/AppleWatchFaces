//
//  WatchFaceNode.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 11/9/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import Foundation
import SpriteKit

class WatchFaceNode: SKShapeNode {
    
    var faceSettings: FaceSetting = FaceSetting.defaults()
    var originalSize: CGSize = CGSize.zero
    let magicSize = CGSize.init(width: 105, height: 130) //translation in view
    
    enum PartsZPositions: Int {
        case background = 0,
        backgroundShape,
        foreground,
        complications,
        hourHand,
        minuteHand,
        secondHand
    }
    
    enum AlphaUpdateSections: Int {
        case backgrounds = 0,
        rings,
        hands
    }
    
    enum LayerAdjustmentType: Int {
        case Angle, Scale, Alpha, Position, All
    }
    
    func adjustLayer(faceSetting: FaceSetting, index: Int, adjustmentType: WatchFaceNode.LayerAdjustmentType) {
        let faceLayer = faceSetting.faceLayers[index]
        let layerNode = self.children[index]
        
        if adjustmentType == .Angle {
            layerNode.zRotation = -CGFloat(faceLayer.angleOffset)
        }
        
        if adjustmentType == .Scale {
            layerNode.xScale = CGFloat(faceLayer.scale)
            layerNode.yScale = CGFloat(faceLayer.scale)
        }
        
        if adjustmentType == .Alpha {
            layerNode.alpha = CGFloat(faceLayer.alpha)
        }
    }
    
    func positionLayer(faceSetting: FaceSetting, index: Int ) {
        let faceLayer = faceSetting.faceLayers[index]
        let layerNode = self.children[index]
        
        let xPos = magicSize.width * CGFloat(faceLayer.horizontalPosition)
        let yPos = magicSize.height * CGFloat(faceLayer.verticalPosition)
        
        layerNode.position = CGPoint.init(x: xPos, y: yPos)
        
    }
    
    func highlightLayer(index: Int) {
        let layerNode = self.children[index]
        
        let originalScale = layerNode.xScale
        
        let bloomUpAction = SKAction.scale(to: originalScale*1.3, duration: 0.175)
        bloomUpAction.timingMode = .easeIn
        let bloomDownAction = SKAction.scale(to: originalScale, duration: 0.095)
        bloomUpAction.timingMode = .easeOut
        let combinedAction = SKAction.sequence([bloomUpAction, bloomDownAction])

        if !layerNode.hasActions() {
            layerNode.run(combinedAction)
        }

    }
    
    func update(_ currentTime: TimeInterval) {
        //frame updates from scene. used for animations when needed
        
        let faceLayers = faceSettings.faceLayers
        
        //TODO: optimize this later
        for (layerIndex, faceLayer) in faceLayers.enumerated() {
            let layerNode = self.children[layerIndex]
            //for seconds
            let rotateAmount = -((CGFloat(currentTime) * CGFloat.pi/2) / 60)
            
            if faceLayer.layerType == .ImageTexture {
                //has image options
                guard let imageOptions = faceLayer.layerOptions as? ImageBackgroundLayerOptions else { continue }
                //only update per frame for angle if anglePersec <> 0
                guard CGFloat(imageOptions.anglePerSec) != 0.0 else { continue }
                layerNode.zRotation = rotateAmount * CGFloat(imageOptions.anglePerSec) - CGFloat(faceLayer.angleOffset)
            }
            if faceLayer.layerType == .Gear {
                guard let imageOptions = faceLayer.layerOptions as? GearLayerOptions else { continue }
                //only update per frame for angle if anglePersec <> 0
                guard CGFloat(imageOptions.anglePerSec) != 0.0 else { continue }
                
                layerNode.zRotation = rotateAmount * CGFloat(imageOptions.anglePerSec) - CGFloat(faceLayer.angleOffset)
            }
        }
    }
    
    init(faceSettings: FaceSetting, size: CGSize) {
        super.init()
        
        self.faceSettings = faceSettings
        self.originalSize = size
        self.name = "watchFaceNode"
        
        let faceLayers = faceSettings.faceLayers
        
        func hexColorForDesiredIndex(index: Int) -> String {
            if faceSettings.faceColors.count > index {
                return faceSettings.faceColors[index]
            } else {
                return ""
            }
        }
        
        func colorForDesiredIndex(index: Int) -> SKColor {
            let colorString = hexColorForDesiredIndex(index: index)
            return SKColor.init(hexString: colorString)
        }
        
        func setLayerProps( layerNode: SKNode, faceLayer: FaceLayer ) {
            layerNode.alpha = CGFloat(faceLayer.alpha)
            layerNode.xScale = CGFloat(faceLayer.scale)
            layerNode.yScale = CGFloat(faceLayer.scale)
            layerNode.zRotation = -CGFloat(faceLayer.angleOffset)
            
            let xPos = magicSize.width * CGFloat(faceLayer.horizontalPosition)
            let yPos = magicSize.height * CGFloat(faceLayer.verticalPosition)
            
            layerNode.position = CGPoint.init(x: xPos, y: yPos)
        }
        
        for (layerIndex, faceLayer) in faceLayers.enumerated() {
            
            let hexColor = hexColorForDesiredIndex(index: faceLayer.desiredThemeColorIndex)
            let layerColor = SKColor.init(hexString: hexColor)
            
            if faceLayer.layerType == .Gear {
                guard let layerOptions = faceLayer.layerOptions as? GearLayerOptions else { return }
                
                let strokeColor = colorForDesiredIndex(index: layerOptions.desiredThemeColorIndexForOutline)
                
                let gearNode = GearNode.init(gearType: layerOptions.gearType, material: hexColor, strokeColor: strokeColor, lineWidth: CGFloat(layerOptions.outlineWidth), glowWidth: 0.0)
                gearNode.name = "gear"
                
                setLayerProps(layerNode: gearNode, faceLayer: faceLayer)
                gearNode.zPosition = CGFloat(layerIndex)
                self.addChild(gearNode)
            }
            
            if faceLayer.layerType == .BatteryIndicator {
                guard let layerOptions = faceLayer.layerOptions as? BatteryIndicatorOptions else { return }
                
                let strokeColor = colorForDesiredIndex(index: layerOptions.desiredThemeColorIndexForOutline)
                var batteryFillColor:SKColor? = colorForDesiredIndex(index: layerOptions.desiredThemeColorIndexForBatteryLevel)
                
                if (layerOptions.autoBatteryColor) {
                    batteryFillColor = nil
                }
                
                let batteryNode = BatteryNode.init(type: .normal, percent: 1.0, batteryfillColor: batteryFillColor, backgroundColor: SKColor.clear, strokeColor: strokeColor, lineWidth: CGFloat(layerOptions.outlineWidth), innerPadding: CGFloat(layerOptions.innerPadding))
                batteryNode.name = "battery"
                batteryNode.setToTime() //set initial percent correctly
                
                setLayerProps(layerNode: batteryNode, faceLayer: faceLayer)
                batteryNode.zPosition = CGFloat(layerIndex)
                self.addChild(batteryNode)
            }
            
            if faceLayer.layerType == .ImageTexture {
                guard let imageOptions = faceLayer.layerOptions as? ImageBackgroundLayerOptions else { return }
                
                var filename = imageOptions.filename
                if (faceLayer.filenameForImage != "") {
                    filename = faceLayer.filenameForImage
                }
                
                let backgroundNode = FaceBackgroundNode.init(backgroundType: imageOptions.backgroundType , material: filename)
                backgroundNode.name = "background"
                
                setLayerProps(layerNode: backgroundNode, faceLayer: faceLayer)
                backgroundNode.zPosition = CGFloat(layerIndex)
                self.addChild(backgroundNode)
            }
            
            if faceLayer.layerType == .SecondHand {
                guard let layerOptions = faceLayer.layerOptions as? SecondHandLayerOptions else { return }
                let strokeColor = colorForDesiredIndex(index: layerOptions.desiredThemeColorIndexForOutline)
                let secHandNode = SecondHandNode.init(secondHandType: layerOptions.handType, material: hexColor, strokeColor: strokeColor,
                                                      lineWidth: CGFloat(layerOptions.outlineWidth), glowWidth: CGFloat(layerOptions.effectsStrength), fieldType: layerOptions.physicsFieldType, itemStrength: CGFloat(layerOptions.physicFieldStrength))
                secHandNode.name = "secondHand"
                
                setLayerProps(layerNode: secHandNode, faceLayer: faceLayer)
                secHandNode.zPosition = CGFloat(layerIndex)
                self.addChild(secHandNode)
            }
            if faceLayer.layerType == .MinuteHand {
                guard let layerOptions = faceLayer.layerOptions as? MinuteHandLayerOptions else { return }
                let strokeColor = colorForDesiredIndex(index: layerOptions.desiredThemeColorIndexForOutline)
                let minHandNode = MinuteHandNode.init(minuteHandType: layerOptions.handType, material: hexColor, strokeColor: strokeColor, lineWidth: CGFloat(layerOptions.outlineWidth), glowWidth: CGFloat(layerOptions.effectsStrength) )
                minHandNode.name = "minuteHand"
                
                setLayerProps(layerNode: minHandNode, faceLayer: faceLayer)
                minHandNode.zPosition = CGFloat(layerIndex)
                self.addChild(minHandNode)
            }
            if faceLayer.layerType == .HourHand {
                guard let layerOptions = faceLayer.layerOptions as? HourHandLayerOptions else { return }
                let strokeColor = colorForDesiredIndex(index: layerOptions.desiredThemeColorIndexForOutline)
                let minHandNode = HourHandNode.init(hourHandType: layerOptions.handType, material: hexColor, strokeColor: strokeColor, lineWidth: CGFloat(layerOptions.outlineWidth), glowWidth: CGFloat(layerOptions.effectsStrength) )
                minHandNode.name = "hourHand"
                
                setLayerProps(layerNode: minHandNode, faceLayer: faceLayer)
                minHandNode.zPosition = CGFloat(layerIndex)
                self.addChild(minHandNode)
            }
            if faceLayer.layerType == .ColorTexture {
                guard let layerOptions = faceLayer.layerOptions as? ImageBackgroundLayerOptions else { return }
                
                let backgroundNode = FaceBackgroundNode.init(backgroundType: layerOptions.backgroundType , material: hexColor)
                backgroundNode.name = "background"
                
                setLayerProps(layerNode: backgroundNode, faceLayer: faceLayer)
                backgroundNode.zPosition = CGFloat(layerIndex)
                self.addChild(backgroundNode)
            }
            if faceLayer.layerType == .GradientTexture {
                var destinationColorHex = ""
                var backgroundType:FaceBackgroundTypes = .FaceBackgroundTypeDiagonalGradient
                if let gradientOptions = faceLayer.layerOptions as? GradientBackgroundLayerOptions {
                    //get outline width / color / and font
                    destinationColorHex = hexColorForDesiredIndex(index: gradientOptions.desiredThemeColorIndexForDestination)
                    switch gradientOptions.directionType {
                    case .Diagonal:
                        backgroundType = .FaceBackgroundTypeDiagonalGradient
                    case .Horizontal:
                        backgroundType = .FaceBackgroundTypeHorizontalGradient
                    case .Vertical:
                        backgroundType = .FaceBackgroundTypeVerticalGradient
                    }
                }
                
                let backgroundNode = FaceBackgroundNode.init(backgroundType: backgroundType , material: destinationColorHex, material2: hexColor)
                backgroundNode.name = "background"
                
                setLayerProps(layerNode: backgroundNode, faceLayer: faceLayer)
                backgroundNode.zPosition = CGFloat(layerIndex)
                self.addChild(backgroundNode)
            }
            if (faceLayer.layerType == .DateTimeLabel) {
                
                var strokeColorHex = ""
                var outlineWidth:Float = 0
                var fontType = NumberTextTypes.NumberTextTypeSystem
                var formatType = DigitalTimeFormats.HHMM
                var effectType = DigitalTimeEffects.None
                var justificationType = HorizontalPositionTypes.Centered
                if let digitalTimeOptions = faceLayer.layerOptions as? DigitalTimeLayerOptions {
                    //get outline width / color / and font
                    strokeColorHex = hexColorForDesiredIndex(index: digitalTimeOptions.desiredThemeColorIndexForOutline)
                    outlineWidth = digitalTimeOptions.outlineWidth
                    fontType = digitalTimeOptions.fontType
                    formatType = digitalTimeOptions.formatType
                    effectType = digitalTimeOptions.effectType
                    justificationType = digitalTimeOptions.justificationType
                }
                
                let digitalTimeNode = DigitalTimeNode.init(digitalTimeTextType: fontType, timeFormat: formatType, textSize: 1.0,
                                                           effect: effectType, horizontalPosition: justificationType, fillColor: layerColor, strokeColor: SKColor.init(hexString: strokeColorHex), lineWidth: outlineWidth)
                digitalTimeNode.name = "timeLabel"
                
                setLayerProps(layerNode: digitalTimeNode, faceLayer: faceLayer)
                digitalTimeNode.zPosition = CGFloat(layerIndex)
                self.addChild(digitalTimeNode)
            }
            if faceLayer.layerType == .ShapeRing {
                if let shapeOptions = faceLayer.layerOptions as? ShapeLayerOptions {
                    let shapeNode = SKNode.init()
                    shapeNode.name = "shapeNode"
                    
                    let fillMaterial = hexColorForDesiredIndex(index: faceLayer.desiredThemeColorIndex)
                    let ringShapePath = WatchFaceNode.getShapePath( ringRenderShape: shapeOptions.pathShape )
                    
                    let strokeHex = ""
                    
                    generateRingNode(shapeNode, patternTotal: shapeOptions.patternTotal, patternArray: shapeOptions.patternArray, ringType: .RingTypeShapeNode, material: fillMaterial, currentDistance: 0.8, renderNumbers: true, renderShapes: true, ringShape: ringShapePath, size: size, lineWidth: 0.0, strokeHex: strokeHex, textSize: 0, textType: .NumberTextTypeSystem, indicatorSize: shapeOptions.indicatorSize, indicatorType: shapeOptions.indicatorType)
                    
                    setLayerProps(layerNode: shapeNode, faceLayer: faceLayer)
                    shapeNode.zPosition = CGFloat(layerIndex)
                    self.addChild(shapeNode)
                }
            }
            if faceLayer.layerType == .NumberRing {
                if let layerOptions = faceLayer.layerOptions as? NumberRingLayerOptions {
                    let shapeNode = SKNode.init()
                    shapeNode.name = "numberRingNode"
                    
                    let fillMaterial = hexColorForDesiredIndex(index: faceLayer.desiredThemeColorIndex)
                    let ringShapePath = WatchFaceNode.getShapePath( ringRenderShape: layerOptions.pathShape )
                    
                    let strokeHex = faceSettings.faceColors[layerOptions.desiredThemeColorIndexForOutline]
                    
                    var ringType:RingTypes = .RingTypeTextNode
                    if layerOptions.isRotating { ringType = .RingTypeTextRotatingNode }
                    
                    generateRingNode(shapeNode, patternTotal: layerOptions.patternTotal, patternArray: layerOptions.patternArray, ringType: ringType,
                        material: fillMaterial, currentDistance: 0.8, renderNumbers: true,
                        renderShapes: true, ringShape: ringShapePath, size: size, lineWidth: layerOptions.outlineWidth, strokeHex: strokeHex, textSize: layerOptions.textSize, textType: layerOptions.fontType, indicatorSize: 0, indicatorType: .FaceIndicatorTypeNone)
                    
                    setLayerProps(layerNode: shapeNode, faceLayer: faceLayer)
                    shapeNode.zPosition = CGFloat(layerIndex)
                    self.addChild(shapeNode)
                }
            }
            
            if faceLayer.layerType == .ParticleField {
                if let layerOptions = faceLayer.layerOptions as? ParticleFieldLayerOptions {
                    let fillMaterial = hexColorForDesiredIndex(index: faceLayer.desiredThemeColorIndex)
                    //let strokeHex = faceSettings.faceColors[layerOptions.desiredThemeColorIndexForOutline]
                    let strokeColor = SKColor.white
                    let material2 = "#eeeeeeff"
                    
                    let particleNode = FaceForegroundNode.init(foregroundType: layerOptions.nodeType, material: fillMaterial, material2: material2, strokeColor: strokeColor, lineWidth: 0, shapeType: layerOptions.shapeType, itemSize: CGFloat(layerOptions.itemSize), itemStrength: 0.26, particleZPosition: CGFloat(layerIndex)-0.5)
                    particleNode.name = "particleNode"
                    
                    setLayerProps(layerNode: particleNode, faceLayer: faceLayer)
                    particleNode.zPosition = CGFloat(layerIndex)
                    self.addChild(particleNode)
                }
            }

        }
        
    }
    
    func generateRingNode( _ clockFaceNode: SKNode, patternTotal: Int, patternArray: [Int], ringType: RingTypes, material: String, currentDistance: Float, renderNumbers: Bool, renderShapes: Bool, ringShape: UIBezierPath, size: CGSize, lineWidth: Float, strokeHex: String, textSize: Float, textType: NumberTextTypes, indicatorSize: Float, indicatorType: FaceIndicatorTypes) {
        
        let ringNode = SKNode()
        ringNode.name = "ringNode"

        clockFaceNode.addChild(ringNode)
        
        let strokeColor = SKColor.init(hexString: strokeHex)
        
        // exit if pattern array is empty
        if (patternArray.count == 0) { return }
        
        var patternCounter = 0
        
        let outerRingNode = SKNode.init()
        
        generateLoop: for outerRingIndex in 0...(patternTotal-1) {
            //dont draw when pattern == 0
            var doDraw = true
            if ( patternArray[patternCounter] == 0) { doDraw = false }
            patternCounter = patternCounter + 1
            if (patternCounter >= patternArray.count) { patternCounter = 0 }
            
            if (!doDraw) { continue }
            
            var innerRingNode = SKNode.init()
            
            //get new position
            let percentOfPath:CGFloat = CGFloat(outerRingIndex) / CGFloat(patternTotal)
            let distanceMult = CGFloat(currentDistance)
            guard let newPos = ringShape.point(at: percentOfPath) else { return }
            let scaledPoint = newPos.applying(CGAffineTransform.init(scaleX: distanceMult, y: distanceMult))
            
            if (renderNumbers && ringType == RingTypes.RingTypeTextNode || renderNumbers && ringType == RingTypes.RingTypeTextRotatingNode) {
                //numbers
                var numberToRender = outerRingIndex
                if numberToRender == 0 { numberToRender = patternTotal }
                
                //force small totals to show as 12s
                if patternTotal < 12 {
                    numberToRender = numberToRender * ( 12 / patternTotal )
                }
                
                innerRingNode  = NumberTextNode.init(
                    numberTextType: textType,
                    textSize: textSize,
                    currentNum: numberToRender,
                    totalNum: patternTotal,
                    shouldDisplayRomanNumerals: false,
                    pivotMode: 0,
                    fillColor: SKColor.init(hexString: material),
                    strokeColor: strokeColor,
                    lineWidth: lineWidth
                )
                
                ringNode.name = "textRingNode"
                
                if ringType == .RingTypeTextRotatingNode {
                    let angle = atan2(scaledPoint.y, scaledPoint.x)
                    innerRingNode.zRotation = angle - CGFloat(Double.pi/2)
                }
                
            }
            if (ringType == RingTypes.RingTypeShapeNode) {
                //shape
                innerRingNode = FaceIndicatorNode.init(indicatorType:  indicatorType, size: indicatorSize, fillColor: SKColor.init(hexString: material))
                innerRingNode.name = "indicatorNode"
                
                let angle = atan2(scaledPoint.y, scaledPoint.x)
                innerRingNode.zRotation = angle + CGFloat(Double.pi/2)
            }
            innerRingNode.position = scaledPoint
            
            outerRingNode.addChild(innerRingNode)
        }
        
        ringNode.addChild(outerRingNode)
    }
    
    func positionHands( sec: CGFloat, min: CGFloat, hour: CGFloat ) {
        positionHands(sec: sec, min: min, hour: hour, force: false)
    }
    
    func positionHands( sec: CGFloat, min: CGFloat, hour: CGFloat, force: Bool ) {
        
        for (index,layer) in self.faceSettings.faceLayers.enumerated() {
            
            if layer.layerType == .SecondHand, let secondHandNode = self.children[index] as?
                SecondHandNode {
                    guard let layerOptions = layer.layerOptions as? SecondHandLayerOptions else { return }
                    secondHandNode.positionHands(sec: sec, secondHandMovement: layerOptions.handAnimation, force: force)
            }
            
            if layer.layerType == .MinuteHand, let minuteHandNode = self.children[index] as? MinuteHandNode {
                guard let layerOptions = layer.layerOptions as? MinuteHandLayerOptions else { return }
                minuteHandNode.positionHands(sec: sec, min: min, minuteHandMovement: layerOptions.handAnimation, force: force)
            }
            
            if layer.layerType == .HourHand, let hourHandNode = self.children[index] as? HourHandNode {
                hourHandNode.positionHands(min: min, hour: hour, force: force)
            }
        }
        if let background = self.childNode(withName: "backgroundShape") as? FaceBackgroundNode {
            background.positionHands(min: min, hour: hour, force: force)
        }
        
        if let foreground = self.childNode(withName: "foregroundNode") as? FaceForegroundNode {
            foreground.positionHands(min: min, hour: hour, force: force)
        }
    
    }
    
    func setToTime() {
        setToTime( force: false)
    }
    
    func setToTime( force: Bool ) {
        // Called before each frame is rendered
        let date = ClockTimer.currentDate
        let calendar = Calendar.current
        
        let hour = CGFloat(calendar.component(.hour, from: date))
        let minutes = CGFloat(calendar.component(.minute, from: date))
        let seconds = CGFloat(calendar.component(.second, from: date))
        
        //normalize 24 hour to 12
        var hour12 = hour
        if hour12>=12 { hour12 -= 12 }
        
        positionHands(sec: seconds, min: minutes, hour: hour12, force: force)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func getShapePath( ringRenderShape: RingRenderShapes) -> UIBezierPath {
        let totalWidth = CGFloat(SKWatchScene.sizeMulitplier * 2)
        
        let ringShapePath = UIBezierPath()
        
        if ringRenderShape == .RingRenderShapeRoundedRect {
            ringShapePath.move(to: CGPoint(x: 0, y: -100))
            ringShapePath.addLine(to: CGPoint(x: 69.43, y: -100))
            ringShapePath.addCurve(to: CGPoint(x: 86.6, y: -98.69), controlPoint1: CGPoint(x: 78.23, y: -100), controlPoint2: CGPoint(x: 82.63, y: -100))
            ringShapePath.addLine(to: CGPoint(x: 87.37, y: -98.5))
            ringShapePath.addCurve(to: CGPoint(x: 98.5, y: -87.37), controlPoint1: CGPoint(x: 92.54, y: -96.62), controlPoint2: CGPoint(x: 96.62, y: -92.54))
            ringShapePath.addCurve(to: CGPoint(x: 100, y: -69.43), controlPoint1: CGPoint(x: 100, y: -82.63), controlPoint2: CGPoint(x: 100, y: -78.23))
            ringShapePath.addLine(to: CGPoint(x: 100, y: 69.43))
            ringShapePath.addCurve(to: CGPoint(x: 98.69, y: 86.6), controlPoint1: CGPoint(x: 100, y: 78.23), controlPoint2: CGPoint(x: 100, y: 82.63))
            ringShapePath.addLine(to: CGPoint(x: 98.5, y: 87.37))
            ringShapePath.addCurve(to: CGPoint(x: 87.37, y: 98.5), controlPoint1: CGPoint(x: 96.62, y: 92.54), controlPoint2: CGPoint(x: 92.54, y: 96.62))
            ringShapePath.addCurve(to: CGPoint(x: 69.43, y: 100), controlPoint1: CGPoint(x: 82.63, y: 100), controlPoint2: CGPoint(x: 78.23, y: 100))
            ringShapePath.addLine(to: CGPoint(x: -69.43, y: 100))
            ringShapePath.addCurve(to: CGPoint(x: -86.6, y: 98.69), controlPoint1: CGPoint(x: -78.23, y: 100), controlPoint2: CGPoint(x: -82.63, y: 100))
            ringShapePath.addLine(to: CGPoint(x: -87.37, y: 98.5))
            ringShapePath.addCurve(to: CGPoint(x: -98.5, y: 87.37), controlPoint1: CGPoint(x: -92.54, y: 96.62), controlPoint2: CGPoint(x: -96.62, y: 92.54))
            ringShapePath.addCurve(to: CGPoint(x: -100, y: 69.43), controlPoint1: CGPoint(x: -100, y: 82.63), controlPoint2: CGPoint(x: -100, y: 78.23))
            ringShapePath.addLine(to: CGPoint(x: -100, y: -69.43))
            ringShapePath.addCurve(to: CGPoint(x: -98.69, y: -86.6), controlPoint1: CGPoint(x: -100, y: -78.23), controlPoint2: CGPoint(x: -100, y: -82.63))
            ringShapePath.addLine(to: CGPoint(x: -98.5, y: -87.37))
            ringShapePath.addCurve(to: CGPoint(x: -87.37, y: -98.5), controlPoint1: CGPoint(x: -96.62, y: -92.54), controlPoint2: CGPoint(x: -92.54, y: -96.62))
            ringShapePath.addCurve(to: CGPoint(x: -69.43, y: -100), controlPoint1: CGPoint(x: -82.63, y: -100), controlPoint2: CGPoint(x: -78.23, y: -100))
            ringShapePath.close()
            ringShapePath.apply(CGAffineTransform.init(scaleX: 1, y: -1.275)) //flip and stretch
        }
        
        if ringRenderShape == .RingRenderShapeOval {
            ringShapePath.addArc(withCenter: CGPoint.zero, radius: totalWidth/2, startAngle: CGFloat(Double.pi/2), endAngle: -CGFloat(Double.pi*2)+CGFloat(Double.pi/2), clockwise: false) //reversed, but works
            ringShapePath.apply(CGAffineTransform.init(scaleX: 1.0, y: 1.27))  //scale/stratch
        }
        
        if ringRenderShape == .RingRenderShapeCircle {
            ringShapePath.addArc(withCenter: CGPoint.zero, radius: totalWidth/2, startAngle: CGFloat(Double.pi/2), endAngle: -CGFloat(Double.pi*2)+CGFloat(Double.pi/2), clockwise: false) //reversed, but works
        }
        
        // STAR ?
        /*
         ringShapePath.move(to: CGPoint(x: 144, y: 17.72))
         ringShapePath.addLine(to: CGPoint(x: 191.52, y: 87.06))
         ringShapePath.addLine(to: CGPoint(x: 272.15, y: 110.83))
         ringShapePath.addLine(to: CGPoint(x: 220.89, y: 177.45))
         ringShapePath.addLine(to: CGPoint(x: 223.2, y: 261.48))
         ringShapePath.addLine(to: CGPoint(x: 144, y: 233.32))
         ringShapePath.addLine(to: CGPoint(x: 64.8, y: 261.48))
         ringShapePath.addLine(to: CGPoint(x: 67.11, y: 177.45))
         ringShapePath.addLine(to: CGPoint(x: 15.85, y: 110.83))
         ringShapePath.addLine(to: CGPoint(x: 96.48, y: 87.06))
         ringShapePath.addLine(to: CGPoint(x: 144, y: 17.72))
         
         ringShapePath.apply(CGAffineTransform.init(rotationAngle: CGFloat.pi)) //rot
         ringShapePath.apply(CGAffineTransform.init(scaleX: -0.9, y: 0.9))  //scale/stratch
         ringShapePath.apply(CGAffineTransform.init(translationX: -130.0, y: 130.0)) //repos
         */
        
        return ringShapePath
    }
    
    func hideHands() {
        if let secondHand = self.childNode(withName: "secondHand") {
            secondHand.isHidden = true
        }
        if let minuteHand = self.childNode(withName: "minuteHand") {
            minuteHand.isHidden = true
        }
        if let hourHand = self.childNode(withName: "hourHand") {
            hourHand.isHidden = true
        }
    }

}

