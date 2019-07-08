//
//  HourTextNodeNode.swift
//  AppleWatchFaces
//
//  Created by Mike Hill on 11/11/15.
//  Copyright © 2015 Mike Hill. All rights reserved.
//

import UIKit
import SpriteKit
import SceneKit
import Foundation

#if os(watchOS)
import WatchKit
import ClockKit
#endif

enum DigitalTimeFormats: String {
    case HHMMSS,
    HHMM,
    HHMMPM,
    HH,
    MM,
    SS,
    PM,
    DADD,
    DDMM,
    MMDD,
    MO,
    DA,
    DD,
    DL,
    Battery,
    BatteryNum,
    Colon,
    Slash,
    None
    
    static let userSelectableValues = [
        DA,
        DD,
        DL,
        MMDD,
        DADD,
        DDMM,
        MO,
        HHMM,
        HHMMPM,
        HHMMSS,
        HH,
        MM,
        SS,
        PM,
        Battery,
        BatteryNum,
        Colon,
        Slash
    ]
}

enum DigitalTimeEffects: String {
    case  innerShadow,
    darkInnerShadow,
    lightInnerShadow,
    dropShadow,
    digital8,
    digital8Light,
    frame,
    darkFrame,
    roundedFrame,
    None
    
    static let userSelectableValues = [
        innerShadow,
        darkInnerShadow,
        lightInnerShadow,
        dropShadow,
        digital8,
        digital8Light,
        frame,
        darkFrame,
        roundedFrame,
        None
    ]
}

enum HorizontalPositionTypes: String {
    case Left,
    Centered,
    Right
    
    static let userSelectableValues = [
        Left,
        Centered,
        Right
    ]
}


class DigitalTimeNode: SKNode {
    var timeFormat: DigitalTimeFormats = .DD
    
    func updateTime( timeString: String ) {
        if let timeText = self.childNode(withName: "timeTextNode") as? SKLabelNode {
            let mutableAttributedText = timeText.attributedText!.mutableCopy() as! NSMutableAttributedString
            mutableAttributedText.mutableString.setString(timeString)
            
            timeText.attributedText = mutableAttributedText
        }
        if let timeTextShadow = self.childNode(withName: "textShadow") as? SKLabelNode {
            let mutableAttributedText = timeTextShadow.attributedText!.mutableCopy() as! NSMutableAttributedString
            mutableAttributedText.mutableString.setString(timeString)
            
            timeTextShadow.attributedText = mutableAttributedText
            timeTextShadow.isHidden = false
        }
    }
    
    func setToTime() {
        setToTime(force: false)
    }
    
    func setToTime(force: Bool) {
        // Called before each frame is rendered
        let date = ClockTimer.currentDate
        let calendar = Calendar.current
        let seconds = CGFloat(calendar.component(.second, from: date))
        
        // EXIT EARLY DEPENDING ON TYPE -- only move forward (do the update ) once per minute
        // saves on framerate & battery by not updating unless its needed
        if (timeFormat != .HHMMSS && timeFormat != .SS && seconds != 0 && force == false) {
            return
        }
        let timeString = getTimeString()
        updateTime(timeString: timeString)
    }
    
    func  getTimeString() -> String {
        
        if timeFormat == .Battery || timeFormat == .BatteryNum {
            let batteryPercent = BatteryNode.getLevel()
           
            var batteryLevel = Int(batteryPercent * 100).description
            if timeFormat == .Battery {
                batteryLevel = batteryLevel + "%"
            }
            return batteryLevel
        }
        
        func timeStringWithoutAMPM( dateFormatterTime: DateFormatter)->String {
            var timeStr = dateFormatterTime.string(from: ClockTimer.currentDate)
            if let rng = timeStr.range(of: dateFormatterTime.amSymbol) {
                timeStr.removeSubrange(rng)
            } else if let rng = timeStr.range(of: dateFormatterTime.pmSymbol) {
                timeStr.removeSubrange(rng)
            }
            return timeStr
        }
        
        func timeStringAMPM( dateFormatterTime: DateFormatter)->String {
            let timeStr = dateFormatterTime.string(from: ClockTimer.currentDate)
            var ampmStr = ""
            if let rng = timeStr.range(of: dateFormatterTime.amSymbol) {
                ampmStr = dateFormatterTime.amSymbol
                _ = rng.description
            } else if let rng = timeStr.range(of: dateFormatterTime.pmSymbol) {
                ampmStr = dateFormatterTime.pmSymbol
                _ = rng.description
            }
            return ampmStr
        }
        
        let date = ClockTimer.currentDate
        var calendar = Calendar.current
        calendar.locale = NSLocale.current
        
        //let month = CGFloat(calendar.component(.month, from: date))
        let day = CGFloat(calendar.component(.day, from: date))
        
        let minutes = CGFloat(calendar.component(.minute, from: date))
        let seconds = CGFloat(calendar.component(.second, from: date))

        let monthWord = calendar.shortMonthSymbols[calendar.component(.month, from: date)-1].uppercased()
        let dayWord = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date)-1].uppercased()
        let dayLongWord = calendar.standaloneWeekdaySymbols[calendar.component(.weekday, from: date)-1].uppercased()
   
        let dayString = String(format: "%02d", Int(day))
        
        let dateFormatterTime = DateFormatter()
        dateFormatterTime.dateStyle = .none
        dateFormatterTime.timeStyle = .short
        
        let hour12formatter = DateFormatter()
        hour12formatter.dateFormat = "hh"
        
        let hourString = hour12formatter.string(from: date)
        let minString = String(format: "%02d", Int(minutes))
        let secString = String(format: "%02d", Int(seconds))
        
        var timeString = ""
        switch timeFormat {
        case .Colon:
            timeString = ":"
        case .Slash:
            timeString = "/"
        case .DD:
            timeString = dayString
        case .DL:
            timeString = dayLongWord
        case .DA:
            timeString = dayWord
        case .DADD:
            timeString = dayWord + " " + dayString
        case .DDMM:
            timeString = dayString + " " + monthWord
        case .MMDD:
            timeString = monthWord + " " + dayString
        case .MO:
            timeString = monthWord
        case .HHMM:
            dateFormatterTime.timeStyle = .short
            timeString = timeStringWithoutAMPM(dateFormatterTime: dateFormatterTime)
        case .HHMMPM:
            dateFormatterTime.timeStyle = .short
            timeString = dateFormatterTime.string(from: ClockTimer.currentDate)
        case .HHMMSS:
            dateFormatterTime.timeStyle = .medium
            timeString = timeStringWithoutAMPM(dateFormatterTime: dateFormatterTime)
        case .HH:
            timeString = hourString
        case .MM:
            timeString = minString
        case .SS:
            timeString = secString
        case .PM:
            timeString = timeStringAMPM(dateFormatterTime: dateFormatterTime)
        default:
            timeString = " " //empty can cause crash on calcuating size  (calculateAccumulatedFrame)
        }
        
        return timeString
    }
    
    //used when generating node for digital time ( a mini digital clock )
    init(digitalTimeTextType: NumberTextTypes, timeFormat: DigitalTimeFormats, textSize: Float, effect: DigitalTimeEffects, horizontalPosition: HorizontalPositionTypes, fillColor: SKColor, strokeColor: SKColor?, lineWidth: Float ) {
    
        super.init()

        self.name = "digitalTimeNode"
        self.timeFormat = timeFormat
    
        //let textScale = Float(0.0175)
        let fontSize:CGFloat = 64.0
        let hourString = getTimeString()
        
        let timeText = SKLabelNode.init(text: hourString)
        timeText.name = "timeTextNode"
        
        switch horizontalPosition {
        case .Left:
            timeText.horizontalAlignmentMode = .left
        case .Right:
            timeText.horizontalAlignmentMode = .right
        default:
            timeText.horizontalAlignmentMode = .center
        }
        timeText.verticalAlignmentMode = .center
        
        let fontName = NumberTextNode.fontNameForNumberTextType(digitalTimeTextType)

        var attributes: [NSAttributedString.Key : Any] = [
                .foregroundColor: fillColor,
                .font: UIFont.init(name: fontName, size: fontSize )!
            ]
        if lineWidth > 0 {
            attributes[.strokeWidth] = -lineWidth
            attributes[.strokeColor] = strokeColor
        }
        timeText.attributedText = NSAttributedString(string: hourString, attributes: attributes)
        
        //needs to always come BEFORE calculateAccumulatedFrame since it will adjust the width
        setToTime(force: true) //update to latest time to start
        
        let shapeRect = timeText.calculateAccumulatedFrame()
        let physicsBody = SKPhysicsBody.init(rectangleOf: shapeRect.size, center: CGPoint.zero)
        physicsBody.isDynamic = false
        timeText.physicsBody = physicsBody
        
        //get boudary for adding frames
        let labelRect = timeText.calculateAccumulatedFrame()
        //re-use "dark color" for backgrounds
        let darkColor = SKColor.black.withAlphaComponent(0.2)
        let lightColor = SKColor.white.withAlphaComponent(0.4)
        
        //re-use an expanded frame
        let buffer:CGFloat = labelRect.height/2 //how much in pixels to expand the rectagle to draw the shadow past the text label
        let expandedRect = labelRect.insetBy(dx: -buffer, dy: -buffer)

        if (effect == .frame || effect == .darkFrame) {
            let frameNode = SKShapeNode.init(rect: expandedRect)
            frameNode.lineWidth = 2.0
            frameNode.strokeColor = fillColor
            
            if (effect == .darkFrame) {
                frameNode.fillColor = darkColor
            }
            
            self.addChild(frameNode)
        }
        
        if (effect == .roundedFrame) {
            let frameNode = SKShapeNode.init(rect: expandedRect, cornerRadius: labelRect.height/3)
            frameNode.lineWidth = 2.0
            frameNode.strokeColor = fillColor
            
            if (effect == .darkFrame) {
                frameNode.fillColor = darkColor
            }
            
            self.addChild(frameNode)
        }
        
        if (effect == .dropShadow) {
            let shadowNode = timeText.copy() as! SKLabelNode
            shadowNode.name = "textShadow"
            let shadowColor = SKColor.black.withAlphaComponent(0.3)
            let attributes: [NSAttributedString.Key : Any] = [
                .foregroundColor: shadowColor,
                .font: UIFont.init(name: fontName, size: fontSize)!
            ]
            shadowNode.attributedText = NSAttributedString(string: hourString, attributes: attributes)
            //shadowNode.zPosition = -0.5
            let shadowOffset = CGFloat(labelRect.size.height/15)
            shadowNode.position = CGPoint.init(x: timeText.position.x+shadowOffset, y: timeText.position.y-shadowOffset)
            self.addChild(shadowNode)
        }
        
        if (effect == .digital8 || effect == .digital8Light) {
            var digital8String = ""
            for i in 0..<hourString.count {
                let index = hourString.index(hourString.startIndex, offsetBy: i)
                let char = hourString[index]
                if char == ":" || char == " " {
                    digital8String.append(contentsOf: char.description)
                } else {
                    digital8String.append(contentsOf: "8")
                }
            }
            
            let digital8Node = timeText.copy() as! SKLabelNode
            digital8Node.name = "textDigital8"
            var darkMult:CGFloat = 0.075
            if effect == .digital8Light {
                darkMult = 0.2
            }
            var fillRed:CGFloat = 0.0
            var fillGreen:CGFloat = 0.0
            var fillBlue:CGFloat = 0.0
            var fillAlpha:CGFloat = 0.0
            fillColor.getRed(&fillRed, green: &fillGreen, blue: &fillBlue, alpha: &fillAlpha)
            let darkColor = SKColor.init(red: fillRed*darkMult, green: fillRed*darkMult, blue: fillRed*darkMult, alpha: fillAlpha*darkMult)
            
            let attributes: [NSAttributedString.Key : Any] = [
                .foregroundColor: darkColor,
                .font: UIFont.init(name: fontName, size: fontSize)!
            ]
            digital8Node.attributedText = NSAttributedString(string: digital8String, attributes: attributes)
            //digital8Node.zPosition = -0.5
            //let shadowOffset:CGFloat = 0
            digital8Node.isHidden = false
            digital8Node.horizontalAlignmentMode = .right
            
            //reposition for always right just
            let parentRect = timeText.calculateAccumulatedFrame()
            digital8Node.position = CGPoint.init(x: parentRect.origin.x + parentRect.size.width, y: timeText.position.y)
            
            self.addChild(digital8Node)
        }
        
        if (effect == .innerShadow || effect == .darkInnerShadow || effect == .lightInnerShadow) {
            let shadowNode = SKNode.init()
            shadowNode.name = "shadowNode"
            
            let shadowHeight:CGFloat = labelRect.height/2.5
            
            var shadowTexture = SKTexture.init(imageNamed: "dark-shadow.png")
            if effect == .lightInnerShadow { shadowTexture = SKTexture.init(imageNamed: "light-shadow.png") }
            
            let topShadowNode = SKSpriteNode.init(texture: shadowTexture, color: SKColor.clear, size: CGSize.init(width: expandedRect.width, height: shadowHeight*1.25))
            topShadowNode.position = CGPoint.init(x: 0, y: expandedRect.height/2 - shadowHeight/2)
            shadowNode.addChild(topShadowNode)
            
            let bottonShadowNode = SKSpriteNode.init(texture: shadowTexture, color: SKColor.clear, size: CGSize.init(width: expandedRect.width, height: shadowHeight))
            bottonShadowNode.position = CGPoint.init(x: 0, y: -expandedRect.height/2 + shadowHeight/2)
            bottonShadowNode.zRotation = CGFloat.pi
            shadowNode.addChild(bottonShadowNode)

            let leftShadowNode = SKSpriteNode.init(texture: shadowTexture, color: SKColor.clear, size: CGSize.init(width: expandedRect.height, height: shadowHeight))
            leftShadowNode.position = CGPoint.init(x: -expandedRect.width/2 + shadowHeight/2, y: 0)
            leftShadowNode.zRotation = CGFloat.pi/2
            shadowNode.addChild(leftShadowNode)
            
            let rightShadowNode = SKSpriteNode.init(texture: shadowTexture, color: SKColor.clear, size: CGSize.init(width: expandedRect.height, height: shadowHeight))
            rightShadowNode.position = CGPoint.init(x: expandedRect.width/2 - shadowHeight/2, y: 0)
            rightShadowNode.zRotation = -CGFloat.pi/2
            shadowNode.addChild(rightShadowNode)
            
            //reverse center for text rendering
            switch horizontalPosition {
            case .Left:
                shadowNode.position = CGPoint.init(x: labelRect.width/2, y: 0)
            case .Right:
                shadowNode.position = CGPoint.init(x: -labelRect.width/2, y: 0)
            default:
                shadowNode.position = CGPoint.init(x: 0, y: 0)
            }
            
            if (effect == .darkInnerShadow) {
                let frameNode = SKShapeNode.init(rect: expandedRect)
                frameNode.fillColor = darkColor
                frameNode.lineWidth = 0.0
                //frameNode.zPosition = -0.5
                
                self.addChild(frameNode)
            }
            
            if (effect == .lightInnerShadow) {
                let frameNode = SKShapeNode.init(rect: expandedRect)
                frameNode.fillColor = lightColor
                frameNode.lineWidth = 0.0
                //frameNode.zPosition = -0.5
                
                self.addChild(frameNode)
            }
            
            timeText.addChild(shadowNode)
            
            
        }
        
        self.addChild(timeText)
        
        //check to see if we need to update time every second
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForSecondsChanged(notification:)), name: ClockTimer.timeChangedSecondNotificationName, object: nil)
        //force update time if needed ( after restart )
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForForceUpdateTime(notification:)), name: SKWatchScene.timeForceUpdateNotificationName, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onNotificationForSecondsChanged(notification:Notification) {
        setToTime()
    }
    
    @objc func onNotificationForForceUpdateTime(notification:Notification) {
        setToTime(force: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func descriptionForTimeFormats(_ format: DigitalTimeFormats) -> String {
        var description = ""
        
        switch format {
        case .Battery:
            description = "Battery %"
        case .BatteryNum:
            description = "Battery"
        case .DA:
            description = "Tue - Day Short"
        case .DL:
            description = "Tuesday - Day Full"
        case .DADD:
            description = "Tue 5 - Day Short & Num"
        case .DD:
            description = "5 - Day Num"
        case .DDMM:
            description = "5 May - Day Num & Month"
        case .MMDD:
            description = "May 5 - Month & Day Num"
        case .MO:
            description = "May - Month"
        case .HHMM:
            description = "10:30 - Hour:Min"
        case .HHMMPM:
            description = "10:30 pm - hour:min pm"
        case .HHMMSS:
            description = "10:30:55 - hour:min:sec"
        case .HH:
            description = "10 - hour"
        case .MM:
            description = "30 - min"
        case .SS:
            description = "55 - sec"
        case .PM:
            description = "AM - am/pm"
        case .Colon:
            description = ": - colon"
        case .Slash:
            description = "/ - slash"
        default:
            description = "None"
        }
    
        return description
    }
    
    static func timeFormatsDescriptions() -> [String] {
        var typeDescriptionsArray = [String]()
        for nodeType in DigitalTimeFormats.userSelectableValues {
            typeDescriptionsArray.append(descriptionForTimeFormats(nodeType))
        }
        
        return typeDescriptionsArray
    }
    
    static func timeFormatsKeys() -> [String] {
        var typeKeysArray = [String]()
        for nodeType in DigitalTimeFormats.userSelectableValues {
            typeKeysArray.append(nodeType.rawValue)
        }
        
        return typeKeysArray
    }
    
    static func descriptionForTimeEffects(_ format: DigitalTimeEffects) -> String {
        var description = ""
        
        switch format {
        case .darkFrame:
            description = "Dark Frame"
        case .darkInnerShadow:
            description = "Dark Inner Shadow"
        case .lightInnerShadow:
            description = "Light Inner Shadow"
        case .dropShadow:
            description = "Drop Shadow"
        case .digital8:
            description = "Digital 8s"
        case .digital8Light:
            description = "Digital 8s Light"
        case .frame:
            description = "Frame"
        case .roundedFrame:
            description = "Rounded Frame"
        case .innerShadow:
            description = "Inner Shadow"
        default:
            description = "None"
        }
        
        return description
    }
    
    static func timeEffectsDescriptions() -> [String] {
        var typeDescriptionsArray = [String]()
        for nodeType in DigitalTimeEffects.userSelectableValues {
            typeDescriptionsArray.append(descriptionForTimeEffects(nodeType))
        }
        
        return typeDescriptionsArray
    }
    
    static func descriptionForPositionTypes(_ format: HorizontalPositionTypes) -> String {
        var description = ""
        
        switch format {
        case .Left:
            description = "Left"
        case .Centered:
            description = "Centered"
        case .Right:
            description = "Right"
        }
        
        return description
    }
    
    static func positionTypesDescriptions() -> [String] {
        var typeDescriptionsArray = [String]()
        for nodeType in HorizontalPositionTypes.userSelectableValues {
            typeDescriptionsArray.append(descriptionForPositionTypes(nodeType))
        }
        
        return typeDescriptionsArray
    }

}

public extension CGRect {
    
    enum Edge {
        case Bottom
        case Left
        case Right
        case Top
        
        func toCGRectEdge() -> CGRectEdge {
            switch self {
            case .Bottom: return .maxYEdge
            case .Left: return .minXEdge
            case .Right: return .maxXEdge
            case .Top: return .minYEdge
            }
        }
    }
    
    /**
     This method creates a new CGRect by strecting the specified `edge` to align with the `toEdge`.
     
     The result can end up with a negative width/height.
     
     - Note: This method DOES mutate the size of the rect.
     - SeeAlso: `algin(edge:toEdge:ofRect:withOffset:)`
     */
    func pin(edge: Edge, toEdge: Edge, ofRect rect: CGRect, withOffset offset: CGFloat = 0) -> CGRect {
        switch (edge, toEdge) {
        case (.Left, .Left):
            return CGRect(x: rect.minX - offset, y: minY, width: width + (minX - rect.minX) + offset, height: height)
        case (.Left, .Right):
            return CGRect(x: rect.maxX + offset, y: minY, width: width + (minX - rect.maxX) - offset, height: height)
        case (.Top, .Top):
            return CGRect(x: minX, y: rect.minY - offset, width: width, height: height + (minY - rect.minY) + offset)
        case (.Top, .Bottom):
            return CGRect(x: minX, y: rect.maxY + offset, width: width, height: height + (minY - rect.maxY) - offset)
        case (.Right, .Left):
            return CGRect(x: rect.minX, y: minY, width: width - (maxX - rect.minX) + offset, height: height)
        case (.Right, .Right):
            return CGRect(x: minX, y: minY, width: width - (maxX - rect.maxX) - offset, height: height)
        case (.Bottom, .Top):
            return CGRect(x: minX, y: minY, width: width, height: height - (maxY - rect.minY) + offset)
        case (.Bottom, .Bottom):
            return CGRect(x: minX, y: minY, width: width, height: height - (maxY - rect.maxY) - offset)
        default:
            preconditionFailure("Cannot align to this combination of edges")
        }
    }
    
    /**
     This method creates a new CGRect by aligning the specified `edge` to the `toEdge`.
     
     - SeeAlso: `pin(edge:toEdge:ofRect:withOffset:)`
     */
    func align(edge: Edge, toEdge: Edge, ofRect rect: CGRect, withOffset offset: CGFloat = 0) -> CGRect {
        return CGRect(origin: alignOrigin(edge: edge, toEdge: toEdge, ofRect: rect, withOffset: offset), size: size)
    }
    
    private func alignOrigin(edge: Edge, toEdge: Edge, ofRect rect: CGRect, withOffset offset: CGFloat) -> CGPoint {
        switch (edge, toEdge) {
        case (.Left, .Left):
            return CGPoint(x: rect.minX + offset, y: minY)
        case (.Left, .Right):
            return CGPoint(x: rect.maxX + offset, y: minY)
        case (.Top, .Top):
            return CGPoint(x: minX, y: rect.minY + offset)
        case (.Top, .Bottom):
            return CGPoint(x: minX, y: rect.maxY + offset)
        case (.Right, .Left):
            return CGPoint(x: rect.minX - width - offset, y: minY)
        case (.Right, .Right):
            return CGPoint(x: rect.maxX - width - offset, y: minY)
        case (.Bottom, .Top):
            return CGPoint(x: minX, y: rect.minY - height - offset)
        case (.Bottom, .Bottom):
            return CGPoint(x: minX, y: rect.maxY - height - offset)
        default:
            preconditionFailure("Cannot align to this combination of edges")
        }
    }
    
}




extension CGRect {
    
    public enum Direction {
        case Up
        case Down
        case Left
        case Right
    }
    
    public func move(direction: Direction, amount: CGFloat) -> CGRect {
        switch direction {
        case .Up: return CGRect.init(x: minX, y: minY - amount, width: width, height: height)
        case .Down: return CGRect.init(x: minX, y: minY + amount, width: width, height: height)
        case .Left: return CGRect.init(x: minX - amount, y: minY, width: width, height: height)
        case .Right: return CGRect.init(x: minX + amount, y: minY, width: width, height: height)
        }
    }
    
    public func expand(direction: Direction, amount: CGFloat) -> CGRect {
        switch direction {
        case .Up: return CGRect.init(x: minX, y: minY - amount, width: width, height: height + amount)
        case .Down: return CGRect.init(x: minX, y: minY, width: width, height: height + amount)
        case .Left: return CGRect.init(x: minX - amount, y: minY, width: width + amount, height: height)
        case .Right: return CGRect.init(x: minX, y: minY, width: width + amount, height: height)
        }
    }
    
}




extension CGRect {
    
    public enum Dimension {
        case Height
        case Width
    }
    
    public func setDimension(dimension: Dimension, toSize size: CGFloat) -> CGRect {
        switch dimension {
        case .Height: return CGRect.init(x: minX, y: minY, width: width, height: size)
        case .Width: return CGRect.init(x: minX,y:  minY, width: size, height: height)
        }
    }
    
}
