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
    
    var clockFaceSettings: ClockFaceSetting = ClockFaceSetting.defaults()
    var originalSize: CGSize = CGSize.zero
    
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
    
    func adjustAlpha(clockSetting: ClockSetting, section: AlphaUpdateSections) {
        
        if section == .backgrounds {
            if let backgroundNode = self.childNode(withName: "background") {
                backgroundNode.alpha = CGFloat(clockSetting.clockCasingMaterialAlpha)
            }
            if let backgroundShapeNode = self.childNode(withName: "backgroundShape") {
                backgroundShapeNode.alpha = CGFloat(clockSetting.clockFaceMaterialAlpha)
            }
            if let foregroundNode = self.childNode(withName: "foregroundNode") {
                foregroundNode.alpha = CGFloat(clockSetting.clockForegroundMaterialAlpha)
            }
        }
        
        if section == .hands {
            //need clockface settings for these
            guard let clockFaceSettings = clockSetting.clockFaceSettings else { return }
            guard clockFaceSettings.handAlphas.count>2 else { return }
            
            let secondHandAlpha = clockFaceSettings.handAlphas[0]
            if let node = self.childNode(withName: "secondHand") {
                node.alpha = CGFloat(secondHandAlpha)
            }
            if let node = self.childNode(withName: "secondHandShadow") {
                node.alpha = CGFloat(secondHandAlpha)
            }
            
            let minuteHandAlpha = clockFaceSettings.handAlphas[1]
            if let node = self.childNode(withName: "minuteHand") {
                node.alpha = CGFloat(minuteHandAlpha)
            }
            if let node = self.childNode(withName: "minuteHandShadow") {
                node.alpha = CGFloat(minuteHandAlpha)
            }
            
            let hourHandAlpha = clockFaceSettings.handAlphas[2]
            if let node = self.childNode(withName: "hourHand") {
                node.alpha = CGFloat(hourHandAlpha)
            }
            if let node = self.childNode(withName: "hourHandShadow") {
                node.alpha = CGFloat(hourHandAlpha)
            }
        }
        
        if section == .rings {
            guard let indicatorNode = self.childNode(withName: "indicatorNode") else { return }
            
            guard let clockFaceSettings = clockSetting.clockFaceSettings else { return }
            guard clockFaceSettings.ringAlphas.count>2 else { return }
            
            for childnode in indicatorNode.children {
                if let userDataDict = childnode.userData as? [String: Int] {
                    let ringMaterialDesiredThemeColorIndex = userDataDict["ringMaterialDesiredThemeColorIndex"]
                    for index in 0 ... 2 {
                        if (ringMaterialDesiredThemeColorIndex == index) {
                            childnode.alpha = CGFloat(clockFaceSettings.ringAlphas[index])
                        }
                    }
                }
            }
        }
        
        
    }
    
    init(clockSetting: ClockSetting, size: CGSize) {
        super.init()
        
        self.originalSize = size
        self.name = "watchFaceNode"
        
        //nothing to without these settings
        guard let clockFaceSettings = clockSetting.clockFaceSettings else { return }
        self.clockFaceSettings = clockFaceSettings
        
        let bottomLayerMaterial = clockSetting.clockCasingMaterialName
        let topLayerMaterial = clockSetting.clockFaceMaterialName
        let overlayMaterial = clockSetting.clockForegroundMaterialName
        
        let backgroundNode = FaceBackgroundNode.init(backgroundType: FaceBackgroundTypes.FaceBackgroundTypeFilled , material: bottomLayerMaterial)
        backgroundNode.name = "background"
        backgroundNode.zPosition = CGFloat(PartsZPositions.background.rawValue)
        backgroundNode.alpha = CGFloat(clockSetting.clockCasingMaterialAlpha)
        
        self.addChild(backgroundNode)
        
        let backgroundShapeNode = FaceBackgroundNode.init(backgroundType: clockSetting.faceBackgroundType , material: topLayerMaterial, material2: bottomLayerMaterial)
        backgroundShapeNode.name = "backgroundShape"
        backgroundShapeNode.zPosition = CGFloat(PartsZPositions.backgroundShape.rawValue)
        backgroundShapeNode.alpha = CGFloat(clockSetting.clockFaceMaterialAlpha)
        
        self.addChild(backgroundShapeNode)
        
        var shapeType: OverlayShapeTypes = .Circle
        var itemSize:CGFloat = 0
        var itemStrength:CGFloat = 0
        if let clockOverlaySettings = clockSetting.clockOverlaySettings {
            shapeType = clockOverlaySettings.shapeType
            itemSize = CGFloat(clockOverlaySettings.itemSize)
            itemStrength = CGFloat(clockOverlaySettings.itemStrength)
        }
        
        let foregroundNode = FaceForegroundNode.init(foregroundType: clockSetting.faceForegroundType, material: overlayMaterial, material2: bottomLayerMaterial, strokeColor: SKColor.clear, lineWidth: 0.0, shapeType: shapeType, itemSize: itemSize, itemStrength: itemStrength)
        foregroundNode.name = "foregroundNode"
        foregroundNode.zPosition = CGFloat(PartsZPositions.foreground.rawValue)
        foregroundNode.alpha = CGFloat(clockSetting.clockForegroundMaterialAlpha)
        
        self.addChild(foregroundNode)
        
        renderHands(clockSetting: clockSetting)
        
        renderIndicatorItems(clockFaceSettings: clockFaceSettings, size: size)
    }
    
    func renderIndicatorItems( clockFaceSettings: ClockFaceSetting, size: CGSize ) {
        let ringShapePath = WatchFaceNode.getShapePath( ringRenderShape: clockFaceSettings.ringRenderShape )
        
        let indicatorNode = SKNode()
        indicatorNode.name = "indicatorNode"
        indicatorNode.zPosition = CGFloat(PartsZPositions.complications.rawValue)
        self.addChild(indicatorNode)
        
        var currentDistance = Float(1.0)
        //loop through ring settings and render rings from outside to inside
        for ringSetting in clockFaceSettings.ringSettings {
            
            let desiredMaterialIndex = ringSetting.ringMaterialDesiredThemeColorIndex
            var material = ""
            if (desiredMaterialIndex<=clockFaceSettings.ringMaterials.count-1) {
                material = clockFaceSettings.ringMaterials[desiredMaterialIndex]
            } else {
                material = clockFaceSettings.ringMaterials[clockFaceSettings.ringMaterials.count-1]
            }
            
            generateRingNode(
                indicatorNode,
                patternTotal: ringSetting.ringPatternTotal,
                patternArray: ringSetting.ringPattern,
                ringType: ringSetting.ringType,
                material: material,
                currentDistance: currentDistance,
                clockFaceSettings: clockFaceSettings,
                ringSettings: ringSetting,
                renderNumbers: true,
                renderShapes: true,
                ringShape: ringShapePath,
                size: size)
            
            //move it closer to center
            currentDistance = currentDistance - ringSetting.ringWidth
        }
    }
    
    func generateRingNode( _ clockFaceNode: SKNode, patternTotal: Int, patternArray: [Int], ringType: RingTypes, material: String, currentDistance: Float, clockFaceSettings: ClockFaceSetting, ringSettings: ClockRingSetting, renderNumbers: Bool, renderShapes: Bool, ringShape: UIBezierPath, size: CGSize) {
        
        let positionInRing = clockFaceSettings.ringSettings.firstIndex(of: ringSettings)
        
        let ringNode = SKNode()
        ringNode.name = "ringNode"
        //keep track of ringIndex for tapDetection / highlighting in editor
        if let positionInRing = positionInRing { ringNode.userData = ["positionInRing":positionInRing, "ringMaterialDesiredThemeColorIndex" : ringSettings.ringMaterialDesiredThemeColorIndex] }
        clockFaceNode.addChild(ringNode)
        
        //optional stroke color
        var strokeColor:SKColor? = nil
        if (ringSettings.shouldShowTextOutline) {
            let strokeMaterial = clockFaceSettings.ringMaterials[ringSettings.textOutlineDesiredThemeColorIndex]
            strokeColor = SKColor.init(hexString: strokeMaterial)
        }
        
        //just exit for spacer
        if (ringType == RingTypes.RingTypeSpacer) { return }
        
        //draw any special items
        if (ringType == RingTypes.RingTypeDigitalTime) {
            //draw it
            let digitalTimeNode = DigitalTimeNode.init(digitalTimeTextType: ringSettings.textType, timeFormat: ringSettings.ringStaticTimeFormat, textSize: ringSettings.textSize,
                                                       effect: ringSettings.ringStaticEffects, horizontalPosition: ringSettings.ringStaticItemHorizontalPosition, fillColor: SKColor.init(hexString: material), strokeColor: strokeColor)
            
            var xPos:CGFloat = 0
            var yPos:CGFloat = 0
            let magicSize = CGSize.init(width: 105, height: 130)
            let xDist = magicSize.width * CGFloat(currentDistance) - CGFloat(ringSettings.textSize * 15)
            let yDist = magicSize.height * CGFloat(currentDistance) - CGFloat(ringSettings.textSize * 10)
            
            if (ringSettings.ringStaticItemHorizontalPosition == .Left) {
                xPos = -xDist
            }
            if (ringSettings.ringStaticItemHorizontalPosition == .Right) {
                xPos = xDist
            }
            if (ringSettings.ringStaticItemVerticalPosition == .Top) {
                yPos = yDist
            }
            if (ringSettings.ringStaticItemVerticalPosition == .Bottom) {
                yPos = -yDist
            }
            if (ringSettings.ringStaticItemHorizontalPosition == .Numeric) {
                xPos = magicSize.width * 2 * (CGFloat(ringSettings.ringStaticHorizontalPositionNumeric) - 0.5)
            }
            if (ringSettings.ringStaticItemVerticalPosition == .Numeric) {
                yPos = -magicSize.height * 2 * (CGFloat(ringSettings.ringStaticVerticalPositionNumeric) - 0.5)
            }
            //horizontalPosition: .Right, verticalPosition: .Top
            digitalTimeNode.position = CGPoint.init(x: xPos, y: yPos)
            
            ringNode.addChild(digitalTimeNode)
            
            return
        }
        
        //draw items that loop
        
        // exit if pattern array is empty
        if (patternArray.count == 0) { return }
        
        var patternCounter = 0
        
        generateLoop: for outerRingIndex in 0...(patternTotal-1) {
            //dont draw when pattern == 0
            var doDraw = true
            if ( patternArray[patternCounter] == 0) { doDraw = false }
            patternCounter = patternCounter + 1
            if (patternCounter >= patternArray.count) { patternCounter = 0 }
            
            if (!doDraw) { continue }
            
            var outerRingNode = SKNode.init()
            
            //get new position
            let percentOfPath:CGFloat = CGFloat(outerRingIndex) / CGFloat(patternTotal)
            let distanceMult = CGFloat(currentDistance)
            guard let newPos = ringShape.point(at: percentOfPath) else { return }
            let scaledPoint = newPos.applying(CGAffineTransform.init(scaleX: distanceMult, y: distanceMult))
            
            if (renderNumbers && ringType == RingTypes.RingTypeTextNode || renderNumbers && ringType == RingTypes.RingTypeTextRotatingNode) {
                //print("patternDraw")
                
                //numbers
                var numberToRender = outerRingIndex
                if numberToRender == 0 { numberToRender = patternTotal }
                
                //force small totals to show as 12s
                if patternTotal < 12 {
                    numberToRender = numberToRender * ( 12 / patternTotal )
                }
                
                outerRingNode  = NumberTextNode.init(
                    numberTextType: ringSettings.textType,
                    textSize: ringSettings.textSize,
                    currentNum: numberToRender,
                    totalNum: patternTotal,
                    shouldDisplayRomanNumerals: clockFaceSettings.shouldShowRomanNumeralText,
                    pivotMode: 0,
                    fillColor: SKColor.init(hexString: material),
                    strokeColor: strokeColor
                )
                
                //keep track of ringIndex for tapDetection / highlighting in editor
                if let positionInRing = positionInRing { outerRingNode.userData = ["positionInRing":positionInRing] }
                
                ringNode.name = "textRingNode"
                
                if ringType == .RingTypeTextRotatingNode {
                    let angle = atan2(scaledPoint.y, scaledPoint.x)
                    outerRingNode.zRotation = angle - CGFloat(Double.pi/2)
                }
                
            }
            if (ringType == RingTypes.RingTypeShapeNode) {
                //shape
                outerRingNode = FaceIndicatorNode.init(indicatorType:  ringSettings.indicatorType, size: ringSettings.indicatorSize, fillColor: SKColor.init(hexString: material))
                outerRingNode.name = "indicatorNode"
                
                let angle = atan2(scaledPoint.y, scaledPoint.x)
                outerRingNode.zRotation = angle + CGFloat(Double.pi/2)
            }
            outerRingNode.position = scaledPoint
            
            ringNode.addChild(outerRingNode)
        }
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
            secondHand.positionHands(sec: sec, secondHandMovement: clockFaceSettings.secondHandMovement, force: force)
        }
        
        if let minuteHand = self.childNode(withName: "minuteHand") as? MinuteHandNode {
            minuteHand.positionHands(sec: sec, min: min, minuteHandMovement: clockFaceSettings.minuteHandMovement, force: force)
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
    
    func redrawIndicators(clockFaceSettings: ClockFaceSetting) {
        self.clockFaceSettings = clockFaceSettings
        
        //remove old indicators
        if let indicatorNode = self.childNode(withName: "indicatorNode") {
            indicatorNode.removeFromParent()
        }
        renderIndicatorItems(clockFaceSettings: clockFaceSettings, size: originalSize)
        
    }
}

