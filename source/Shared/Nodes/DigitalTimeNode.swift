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
    DADD,
    DDMM,
    MMDD,
    DA,
    DD,
    Battery,
    None
    
    static let userSelectableValues = [
        Battery,
        DA,
        DD,
        MMDD,
        DADD,
        DDMM,
        HHMM,
        HHMMPM,
        HHMMSS,
        HH,
        MM
    ]
}

enum DigitalTimeEffects: String {
    case  innerShadow,
    darkInnerShadow,
    lightInnerShadow,
    dropShadow,
    digital8,
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
        frame,
        darkFrame,
        roundedFrame,
        None
    ]
}

class DigitalTimeNode: SKNode {
    var timeFormat: DigitalTimeFormats = .DD
    
    func updateTime( timeString: String ) {
        if let timeText = self.childNode(withName: "timeTextNode") as? SKLabelNode {
            //let mutableAttributedString = NSMutableAttributedString(string: timeString, attributes: myAttributes)
            let mutableAttributedText = timeText.attributedText!.mutableCopy() as! NSMutableAttributedString
            mutableAttributedText.mutableString.setString(timeString)
            
            timeText.attributedText = mutableAttributedText
        }
        if let timeTextShadow = self.childNode(withName: "textShadow") as? SKLabelNode {
            //let mutableAttributedString = NSMutableAttributedString(string: timeString, attributes: myAttributes)
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
        if (timeFormat != .HHMMSS && seconds != 0 && force == false) {
            return
        }
        let timeString = getTimeString()
        updateTime(timeString: timeString)
    }
    
    func  getTimeString() -> String {
        
        if timeFormat == .Battery {
            
            #if os(watchOS)
                WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
                var batteryPercent = WKInterfaceDevice.current().batteryLevel
                //var batteryState = WKInterfaceDevice.current().batteryState
                WKInterfaceDevice.current().isBatteryMonitoringEnabled = false
            
                if batteryPercent > 1.0 {
                    batteryPercent = 1.0
                }
                if batteryPercent < 0.0 {
                    batteryPercent = 0.0
                }
            
                return Int(batteryPercent * 100).description + "%"
            #else
                return "100%"
            #endif
        }
        
        func timeStringWithoutAMPM( dateFormatterTime: DateFormatter)->String {
            var timeStr = dateFormatterTime.string(from: ClockTimer.currentDate)
            //var ampmStr = ""
            if let rng = timeStr.range(of: dateFormatterTime.amSymbol) {
                //ampmStr = dateFormatterTime.amSymbol
                timeStr.removeSubrange(rng)
            } else if let rng = timeStr.range(of: dateFormatterTime.pmSymbol) {
                //aampmStr = dateFormatterTime.pmSymbol
                timeStr.removeSubrange(rng)
            }
            return timeStr
        }
        
        let date = ClockTimer.currentDate
        var calendar = Calendar.current
        calendar.locale = NSLocale.current
        
        //let month = CGFloat(calendar.component(.month, from: date))
        let day = CGFloat(calendar.component(.day, from: date))
        
        let hour = CGFloat(calendar.component(.hour, from: date))
        let minutes = CGFloat(calendar.component(.minute, from: date))
//        let seconds = CGFloat(calendar.component(.second, from: date))

        let monthWord = calendar.shortMonthSymbols[calendar.component(.month, from: date)-1].uppercased()
        let dayWord = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date)-1].uppercased()
   
        let dayString = String(format: "%02d", Int(day))
        
        let dateFormatterTime = DateFormatter()
        dateFormatterTime.dateStyle = .none
        dateFormatterTime.timeStyle = .short
        
        let hourString = String(format: "%02d", Int(hour))
        let minString = String(format: "%02d", Int(minutes))
//        let secString = String(format: "%02d", Int(seconds))
        
        var timeString = ""
        switch timeFormat {
        case .DD:
            timeString = dayString
        case .DA:
            timeString = dayWord
        case .DADD:
            timeString = dayWord + " " + dayString
        case .DDMM:
            timeString = dayString + " " + monthWord
        case .MMDD:
            timeString = monthWord + " " + dayString
        case .HHMM:
            dateFormatterTime.timeStyle = .short
            timeString = timeStringWithoutAMPM(dateFormatterTime: dateFormatterTime)
        case .HHMMSS:
            dateFormatterTime.timeStyle = .medium
            timeString = timeStringWithoutAMPM(dateFormatterTime: dateFormatterTime)
        case .HH:
            timeString = hourString
        case .MM:
            timeString = minString
        default:
            timeString = " " //empty can cause crash on calcuating size  (calculateAccumulatedFrame)
        }
        
        return timeString
    }
    
    //used when generating node for digital time ( a mini digital clock )
    init(digitalTimeTextType: NumberTextTypes, timeFormat: DigitalTimeFormats, textSize: Float, effect: DigitalTimeEffects, horizontalPosition: RingHorizontalPositionTypes, fillColor: SKColor, strokeColor: SKColor? ) {
    
        super.init()

        self.name = "digitalTimeNode"
        self.timeFormat = timeFormat
        
        //TODO this should dependant on overall scale setting?
        let textScale = Float(0.0175)
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
        
        //attributed version
        let strokeWidth = -2 * textSize
        //debugPrint("strokeW: " + strokeWidth.description)

        var attributes: [NSAttributedString.Key : Any] = [
                .foregroundColor: fillColor,
                .font: UIFont.init(name: fontName, size: CGFloat( Float(textSize) / textScale ))!
            ]
        if strokeColor != nil {
            attributes[.strokeWidth] = round(strokeWidth)
            attributes[.strokeColor] = strokeColor
        }
        timeText.attributedText = NSAttributedString(string: hourString, attributes: attributes)
        self.addChild(timeText)
        
        //needs to always come BEFORE calculateAccumulatedFrame since it will adjust the width
        setToTime(force: true) //update to latest time to start
        
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
        
        if (effect == .dropShadow || effect == .digital8) {
            let shadowNode = timeText.copy() as! SKLabelNode
            shadowNode.name = "textShadow"
            let shadowColor = SKColor.black.withAlphaComponent(0.3)
            var attributes: [NSAttributedString.Key : Any] = [
                .foregroundColor: shadowColor,
                .font: UIFont.init(name: fontName, size: CGFloat( Float(textSize) / textScale ))!
            ]
            if strokeColor != nil {
                attributes[.strokeWidth] = round(strokeWidth)
                attributes[.strokeColor] = strokeColor
            }
            shadowNode.attributedText = NSAttributedString(string: hourString, attributes: attributes)
            shadowNode.zPosition = -0.5
            let shadowOffset = CGFloat(labelRect.size.height/15)
            shadowNode.position = CGPoint.init(x: timeText.position.x+shadowOffset, y: timeText.position.y-shadowOffset)
            self.addChild(shadowNode)
            
            if (effect == .digital8) {
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
                let shadowColor = SKColor.black.withAlphaComponent(0.2)
                var attributes: [NSAttributedString.Key : Any] = [
                    .foregroundColor: shadowColor,
                    .font: UIFont.init(name: fontName, size: CGFloat( Float(textSize) / textScale ))!
                ]
                if strokeColor != nil {
                    attributes[.strokeWidth] = round(strokeWidth)
                    attributes[.strokeColor] = strokeColor
                }
                digital8Node.attributedText = NSAttributedString(string: digital8String, attributes: attributes)
                digital8Node.zPosition = -0.5
                //let shadowOffset:CGFloat = 0
                digital8Node.position = CGPoint.init(x: timeText.position.x, y: timeText.position.y)
                digital8Node.isHidden = false
                self.addChild(digital8Node)
            }
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
                frameNode.zPosition = -0.5
                
                self.addChild(frameNode)
            }
            
            if (effect == .lightInnerShadow) {
                let frameNode = SKShapeNode.init(rect: expandedRect)
                frameNode.fillColor = lightColor
                frameNode.lineWidth = 0.0
                frameNode.zPosition = -0.5
                
                self.addChild(frameNode)
            }
            
            timeText.addChild(shadowNode)
        }
        
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
        case .DA:
            description = "DA"
        case .DADD:
            description = "DA&DD"
        case .DD:
            description = "DD"
        case .DDMM:
            description = "DD&MO"
        case .MMDD:
            description = "MO&DD"
        case .HHMM:
            description = "HH:MM"
        case .HHMMPM:
            description = "HH:MMpm"
        case .HHMMSS:
            description = "HH:MM:SS"
        case .HH:
            description = "HH"
        case .MM:
            description = "MM"
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
        for nodeType in DigitalTimeFormats.userSelectableValues {
            typeDescriptionsArray.append(descriptionForTimeFormats(nodeType))
        }
        
        return typeDescriptionsArray
    }

}
