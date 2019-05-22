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
    
    init(faceSettings: FaceSetting, size: CGSize) {
        super.init()
        
        self.faceSettings = faceSettings
        self.originalSize = size
        self.name = "watchFaceNode"
        
        let faceLayers = faceSettings.faceLayers
        
        func hexColorForDesiredIndex(index: Int) -> String {
            return faceSettings.faceColors[index]
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
        
        for faceLayer in faceLayers {
            let hexColor = hexColorForDesiredIndex(index: faceLayer.desiredThemeColorIndex)
            let layerColor = SKColor.init(hexString: hexColor)
            
            if faceLayer.layerType == .SecondHand {
                let secHandNode = SecondHandNode.init(secondHandType: .SecondHandTypeRail)
                secHandNode.name = "secondHand"
                
                setLayerProps(layerNode: secHandNode, faceLayer: faceLayer)
                self.addChild(secHandNode)
            }
            if faceLayer.layerType == .MinuteHand {
                let minHandNode = MinuteHandNode.init(minuteHandType: .MinuteHandTypeBoxy)
                minHandNode.name = "minuteHand"
                
                setLayerProps(layerNode: minHandNode, faceLayer: faceLayer)
                self.addChild(minHandNode)
            }
            if faceLayer.layerType == .HourHand {
                let hourHandNode = HourHandNode.init(hourHandType: .HourHandTypeBoxy)
                hourHandNode.name = "hourHand"

                setLayerProps(layerNode: hourHandNode, faceLayer: faceLayer)
                self.addChild(hourHandNode)
            }
            if faceLayer.layerType == .ImageTexture {
                let backgroundNode = FaceBackgroundNode.init(backgroundType: .FaceBackgroundTypeFilled , material: "copper.jpg")
                backgroundNode.name = "background"
                
                setLayerProps(layerNode: backgroundNode, faceLayer: faceLayer)
                self.addChild(backgroundNode)
            }
            if faceLayer.layerType == .ColorTexture {
                let backgroundNode = FaceBackgroundNode.init(backgroundType: .FaceBackgroundTypeFilled , material: hexColor)
                backgroundNode.name = "background"
                
                setLayerProps(layerNode: backgroundNode, faceLayer: faceLayer)
                self.addChild(backgroundNode)
            }
            if faceLayer.layerType == .GradientTexture {
                var destinationColorHex = ""
                if let gradientOptions = faceLayer.layerOptions as? GradientBackgroundLayerOptions {
                    //get outline width / color / and font
                    destinationColorHex = hexColorForDesiredIndex(index: gradientOptions.desiredThemeColorIndexForDestination)
                }
                
                let backgroundNode = FaceBackgroundNode.init(backgroundType: .FaceBackgroundTypeDiagonalGradient , material: destinationColorHex, material2: hexColor)
                backgroundNode.name = "background"
                
                setLayerProps(layerNode: backgroundNode, faceLayer: faceLayer)
                self.addChild(backgroundNode)
            }
            if (faceLayer.layerType == .DateTimeLabel) {
                
                var strokeColorHex = ""
                var outlineWidth:Float = 0
                var fontType = NumberTextTypes.NumberTextTypeSystem
                var formatType = DigitalTimeFormats.HHMM
                var effectType = DigitalTimeEffects.None
                if let digitalTimeOptions = faceLayer.layerOptions as? DigitalTimeLayerOptions {
                    //get outline width / color / and font
                    strokeColorHex = hexColorForDesiredIndex(index: digitalTimeOptions.desiredThemeColorIndexForOutline)
                    outlineWidth = digitalTimeOptions.outlineWidth
                    fontType = digitalTimeOptions.fontType
                    formatType = digitalTimeOptions.formatType
                    effectType = digitalTimeOptions.effectType
                }
                
                let digitalTimeNode = DigitalTimeNode.init(digitalTimeTextType: fontType, timeFormat: formatType, textSize: 1.0,
                                                           effect: effectType, horizontalPosition: .Centered, fillColor: layerColor, strokeColor: SKColor.init(hexString: strokeColorHex), lineWidth: outlineWidth)
                digitalTimeNode.name = "timeLabel"
                
                setLayerProps(layerNode: digitalTimeNode, faceLayer: faceLayer)
                self.addChild(digitalTimeNode)
            }
            if faceLayer.layerType == .ShapeRing {
                if let shapeOptions = faceLayer.layerOptions as? ShapeLayerOptions {
                    let shapeNode = SKNode.init()
                    shapeNode.name = "shapeNode"
                    
                    let fillMaterial = hexColorForDesiredIndex(index: faceLayer.desiredThemeColorIndex)
                    let ringShapePath = WatchFaceNode.getShapePath( ringRenderShape: .RingRenderShapeCircle )
                    
                    //TODO: fix this with better ringNode rendering seperating out just shapes
                    let ringSettings = ClockRingSetting.defaults()
                    ringSettings.indicatorSize = shapeOptions.indicatorSize
                    ringSettings.indicatorType = shapeOptions.indicatorType
                    generateRingNode(shapeNode, patternTotal: shapeOptions.patternTotal, patternArray: shapeOptions.patternArray, ringType: .RingTypeShapeNode, material: fillMaterial, currentDistance: 0.8, clockFaceSettings: ClockFaceSetting.defaults(), ringSettings: ringSettings, renderNumbers: true, renderShapes: true, ringShape: ringShapePath, size: size, lineWidth: 0.0)
                    
                    setLayerProps(layerNode: shapeNode, faceLayer: faceLayer)
                    self.addChild(shapeNode)
                }
            }
            if faceLayer.layerType == .NumberRing {
                if let layerOptions = faceLayer.layerOptions as? NumberRingLayerOptions {
                    let shapeNode = SKNode.init()
                    shapeNode.name = "numberRingNode"
                    
                    let fillMaterial = hexColorForDesiredIndex(index: faceLayer.desiredThemeColorIndex)
                    let ringShapePath = WatchFaceNode.getShapePath( ringRenderShape: .RingRenderShapeCircle )
                    
                    //TODO: fix this with better ringNode rendering seperating out just shapes
                    let ringSettings = ClockRingSetting.defaults()
                    ringSettings.textSize = layerOptions.textSize
                    ringSettings.textType = layerOptions.fontType
                    ringSettings.textOutlineDesiredThemeColorIndex = layerOptions.desiredThemeColorIndexForOutline
                    let clockFaceSettings = ClockFaceSetting.defaults()
                    clockFaceSettings.ringMaterials = faceSettings.faceColors
                    
                    generateRingNode(shapeNode, patternTotal: layerOptions.patternTotal, patternArray: layerOptions.patternArray, ringType: .RingTypeTextNode,
                        material: fillMaterial, currentDistance: 0.8, clockFaceSettings: clockFaceSettings, ringSettings: ringSettings, renderNumbers: true,
                        renderShapes: true, ringShape: ringShapePath, size: size, lineWidth: layerOptions.outlineWidth)
                    
                    setLayerProps(layerNode: shapeNode, faceLayer: faceLayer)
                    self.addChild(shapeNode)
                }
            }
        }
        
//        let backgroundNode = FaceBackgroundNode.init(backgroundType: FaceBackgroundTypes.FaceBackgroundTypeFilled , material: bottomLayerMaterial)
//        backgroundNode.name = "background"
//        backgroundNode.zPosition = CGFloat(PartsZPositions.background.rawValue)
//        backgroundNode.alpha = CGFloat(clockSetting.clockCasingMaterialAlpha)
//
//        self.addChild(backgroundNode)
//
//        let backgroundShapeNode = FaceBackgroundNode.init(backgroundType: clockSetting.faceBackgroundType , material: topLayerMaterial, material2: bottomLayerMaterial)
//        backgroundShapeNode.name = "backgroundShape"
//        backgroundShapeNode.zPosition = CGFloat(PartsZPositions.backgroundShape.rawValue)
//        backgroundShapeNode.alpha = CGFloat(clockSetting.clockFaceMaterialAlpha)
//
//        self.addChild(backgroundShapeNode)
//
//        var shapeType: OverlayShapeTypes = .Circle
//        var itemSize:CGFloat = 0
//        var itemStrength:CGFloat = 0
//        if let clockOverlaySettings = clockSetting.clockOverlaySettings {
//            shapeType = clockOverlaySettings.shapeType
//            itemSize = CGFloat(clockOverlaySettings.itemSize)
//            itemStrength = CGFloat(clockOverlaySettings.itemStrength)
//        }
//
//        let foregroundNode = FaceForegroundNode.init(foregroundType: clockSetting.faceForegroundType, material: overlayMaterial, material2: bottomLayerMaterial, strokeColor: SKColor.clear, lineWidth: 0.0, shapeType: shapeType, itemSize: itemSize, itemStrength: itemStrength)
//        foregroundNode.name = "foregroundNode"
//        foregroundNode.zPosition = CGFloat(PartsZPositions.foreground.rawValue)
//        foregroundNode.alpha = CGFloat(clockSetting.clockForegroundMaterialAlpha)
//
//        self.addChild(foregroundNode)
//
//        renderHands(clockSetting: clockSetting)
//
//        renderIndicatorItems(clockFaceSettings: clockFaceSettings, size: size)
    }
    
    func generateRingNode( _ clockFaceNode: SKNode, patternTotal: Int, patternArray: [Int], ringType: RingTypes, material: String, currentDistance: Float, clockFaceSettings: ClockFaceSetting, ringSettings: ClockRingSetting, renderNumbers: Bool, renderShapes: Bool, ringShape: UIBezierPath, size: CGSize, lineWidth: Float) {
        
        let ringNode = SKNode()
        ringNode.name = "ringNode"

        clockFaceNode.addChild(ringNode)
        
        let strokeMaterial = clockFaceSettings.ringMaterials[ringSettings.textOutlineDesiredThemeColorIndex]
        let strokeColor = SKColor.init(hexString: strokeMaterial)
        
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
                    numberTextType: ringSettings.textType,
                    textSize: ringSettings.textSize,
                    currentNum: numberToRender,
                    totalNum: patternTotal,
                    shouldDisplayRomanNumerals: clockFaceSettings.shouldShowRomanNumeralText,
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
                innerRingNode = FaceIndicatorNode.init(indicatorType:  ringSettings.indicatorType, size: ringSettings.indicatorSize, fillColor: SKColor.init(hexString: material))
                innerRingNode.name = "indicatorNode"
                
                let angle = atan2(scaledPoint.y, scaledPoint.x)
                innerRingNode.zRotation = angle + CGFloat(Double.pi/2)
            }
            innerRingNode.position = scaledPoint
            
            outerRingNode.addChild(innerRingNode)
        }
        
        ringNode.addChild(outerRingNode)
    }
    
    func renderHands(clockSetting: ClockSetting) {
        //nothing to without these settings
        guard let clockFaceSettings = clockSetting.clockFaceSettings else { return }
        
        var renderShadows = false
        let shadowMaterial = "#111111AA"
        let shadowChildZposition:CGFloat = -0.5
        var shadowColor = SKColor.init(hexString: shadowMaterial)
        shadowColor = shadowColor.withAlphaComponent(0.4)
        let shadowLineWidth:CGFloat = 2.0
        var secondHandGlowWidth:CGFloat = 0
        var minuteHandGlowWidth:CGFloat = 0
        var hourHandGlowWidth:CGFloat = 0
        var secondHandAlpha:CGFloat = 1
        var minuteHandAlpha:CGFloat = 1
        var hourHandAlpha:CGFloat = 1
        
        //TODO: figure out why [safe: 0] was not working here
        if clockFaceSettings.handEffectWidths.count>0 {
            secondHandGlowWidth = CGFloat(clockFaceSettings.handEffectWidths[0])
        }
        if clockFaceSettings.handAlphas.count>0 {
            secondHandAlpha = CGFloat(clockFaceSettings.handAlphas[0])
        }

        //var secondHandStrokeColor = SKColor.init(hexString: clockFaceSettings.secondHandMaterialName)
        
        let secondHandStrokeColor = SKColor.init(hexString: clockFaceSettings.handOutlineMaterialName)
        let lineWidth:CGFloat = 0.0
        var physicsFieldType:PhysicsFieldTypes = .None
        var physicsFieldItemStrength:CGFloat = 0.0
        if let overlaySettings = clockSetting.clockOverlaySettings {
            physicsFieldType = overlaySettings.fieldType
            physicsFieldItemStrength = CGFloat(overlaySettings.itemStrength)
        }
        let secHandNode = SecondHandNode.init(secondHandType: clockFaceSettings.secondHandType, material: clockFaceSettings.secondHandMaterialName, strokeColor: secondHandStrokeColor, lineWidth: lineWidth, glowWidth: secondHandGlowWidth, fieldType: physicsFieldType, itemStrength: physicsFieldItemStrength)
        secHandNode.name = "secondHand"
        secHandNode.alpha = secondHandAlpha
        secHandNode.zPosition = CGFloat(PartsZPositions.secondHand.rawValue)
        
        self.addChild(secHandNode)
        
        //whitelist rendring shadows
        let typesThatShouldHaveShadows = [SecondHandTypes.SecondHandTypeBlocky, SecondHandTypes.SecondHandTypeFlatDial,
                                          SecondHandTypes.SecondHandTypePointy, SecondHandTypes.SecondHandTypePointy, SecondHandTypes.SecondHandTypeSquaredHole]
        if (typesThatShouldHaveShadows.firstIndex(of: clockFaceSettings.secondHandType) != nil) {
            renderShadows = true
        }
        
        if renderShadows {
            let secHandShadowNode = SecondHandNode.init(secondHandType: clockFaceSettings.secondHandType, material: shadowMaterial, strokeColor: shadowColor, lineWidth: shadowLineWidth, glowWidth: 0, fieldType: .None, itemStrength: 1.0)
            secHandShadowNode.position = CGPoint.init(x: 0, y: 0)
            secHandShadowNode.name = "secondHandShadow"
            secHandShadowNode.alpha = secondHandAlpha
            secHandShadowNode.zPosition = shadowChildZposition
            secHandNode.addChild(secHandShadowNode)
        }
        
        if clockFaceSettings.handEffectWidths.count>1 {
            minuteHandGlowWidth = CGFloat(clockFaceSettings.handEffectWidths[1])
        }
        if clockFaceSettings.handAlphas.count>1 {
            minuteHandAlpha = CGFloat(clockFaceSettings.handAlphas[1])
        }
        
        var minuteHandStrokeColor = SKColor.init(hexString: clockFaceSettings.minuteHandMaterialName)
        if (clockFaceSettings.shouldShowHandOutlines) {
            minuteHandStrokeColor = SKColor.init(hexString: clockFaceSettings.handOutlineMaterialName)
        }
        let minHandNode = MinuteHandNode.init(minuteHandType: clockFaceSettings.minuteHandType, material: clockFaceSettings.minuteHandMaterialName, strokeColor: minuteHandStrokeColor, lineWidth: 1.0,
            glowWidth: minuteHandGlowWidth)
        minHandNode.name = "minuteHand"
        minHandNode.alpha = minuteHandAlpha
        minHandNode.zPosition = CGFloat(PartsZPositions.minuteHand.rawValue)
        
        self.addChild(minHandNode)
        
        if renderShadows {
            let minHandShadowNode = MinuteHandNode.init(minuteHandType: clockFaceSettings.minuteHandType, material: shadowMaterial, strokeColor: shadowColor, lineWidth: shadowLineWidth, glowWidth: 0)
            minHandShadowNode.position = CGPoint.init(x: 0, y: 0)
            minHandShadowNode.name = "minuteHandShadow"
            minHandShadowNode.alpha = minuteHandAlpha
            minHandShadowNode.zPosition = shadowChildZposition
            minHandNode.addChild(minHandShadowNode)
        }
        
        var hourHandStrokeColor = SKColor.init(hexString: clockFaceSettings.hourHandMaterialName)
        if (clockFaceSettings.shouldShowHandOutlines) {
        hourHandStrokeColor = SKColor.init(hexString: clockFaceSettings.handOutlineMaterialName)
        }
        if clockFaceSettings.handEffectWidths.count>2 {
            hourHandGlowWidth = CGFloat(clockFaceSettings.handEffectWidths[2])
        }
        if clockFaceSettings.handAlphas.count>2 {
            hourHandAlpha = CGFloat(clockFaceSettings.handAlphas[2])
        }
        
        let hourHandNode = HourHandNode.init(hourHandType: clockFaceSettings.hourHandType, material: clockFaceSettings.hourHandMaterialName, strokeColor: hourHandStrokeColor, lineWidth: 1.0, glowWidth: hourHandGlowWidth)
        hourHandNode.name = "hourHand"
        hourHandNode.alpha = hourHandAlpha
        hourHandNode.zPosition = CGFloat(PartsZPositions.hourHand.rawValue)
        
        self.addChild(hourHandNode)
        
        if renderShadows {
            let hourHandShadowNode = HourHandNode.init(hourHandType: clockFaceSettings.hourHandType, material: shadowMaterial, strokeColor: shadowColor, lineWidth: shadowLineWidth, glowWidth: 0)
            hourHandShadowNode.position = CGPoint.init(x: 0, y: 0)
            hourHandShadowNode.name = "hourHandShadow"
            hourHandShadowNode.alpha = hourHandAlpha
            hourHandShadowNode.zPosition = shadowChildZposition
            hourHandNode.addChild(hourHandShadowNode)
        }
    }
    
    func positionHands( sec: CGFloat, min: CGFloat, hour: CGFloat ) {
        positionHands(sec: sec, min: min, hour: hour, force: false)
    }
    
    func positionHands( sec: CGFloat, min: CGFloat, hour: CGFloat, force: Bool ) {
        
        if let background = self.childNode(withName: "backgroundShape") as? FaceBackgroundNode {
            background.positionHands(min: min, hour: hour, force: force)
        }
        
        if let foreground = self.childNode(withName: "foregroundNode") as? FaceForegroundNode {
            foreground.positionHands(min: min, hour: hour, force: force)
        }
        
        if let secondHand = self.childNode(withName: "secondHand") as? SecondHandNode {
            secondHand.positionHands(sec: sec, secondHandMovement: .SecondHandMovementStep, force: force)
        }
        
        if let minuteHand = self.childNode(withName: "minuteHand") as? MinuteHandNode {
            minuteHand.positionHands(sec: sec, min: min, minuteHandMovement: .MinuteHandMovementStep, force: force)
        }
        
        if let hourHand = self.childNode(withName: "hourHand") as? HourHandNode {
            hourHand.positionHands(min: min, hour: hour, force: force)
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
    
    func redrawIndicators(faceSetting: FaceSetting) {
//        self.faceSettings = faceSetting
//        
//        //remove old indicators
//        if let indicatorNode = self.childNode(withName: "indicatorNode") {
//            indicatorNode.removeFromParent()
//        }
//        renderIndicatorItems(clockFaceSettings: clockFaceSettings, size: originalSize)
        
    }
}

