//
//  BatteryNode.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 7/7/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation
import SpriteKit

#if os(watchOS)
import WatchKit
import ClockKit
#endif

enum BatteryIndicatorTypes: String {
    case normal

    static let userSelectableValues = [normal]
    
    static let randomizableValues = userSelectableValues
    
    static func random() -> BatteryIndicatorTypes {
        let randomIndex = Int(arc4random_uniform(UInt32(randomizableValues.count)))
        return randomizableValues[randomIndex]
    }
}


class BatteryNode: SKShapeNode {
    
    static func getLevel() -> Float {
        //just return full in sim
        #if targetEnvironment(simulator)
            return 1.0
        #else
            var batteryPercent:Float = 1.0
        
            #if os(watchOS)
                WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
                batteryPercent = WKInterfaceDevice.current().batteryLevel
                //var batteryState = WKInterfaceDevice.current().batteryState
                WKInterfaceDevice.current().isBatteryMonitoringEnabled = false
            #else //phone & iPad
                UIDevice.current.isBatteryMonitoringEnabled = true
                batteryPercent = UIDevice.current.batteryLevel
            #endif
        
            if batteryPercent > 1.0 {
                batteryPercent = 1.0
            }
            if batteryPercent < 0.0 {
                batteryPercent = 0.0
            }
        
            return batteryPercent
        #endif
    }
    
    init(type: BatteryIndicatorTypes, percent: CGFloat, batteryfillColor: SKColor?, backgroundColor: SKColor, strokeColor: SKColor, lineWidth: CGFloat, innerPadding: CGFloat) {
        
        super.init()
        
        let batteryBGPath = UIBezierPath()
        batteryBGPath.move(to: CGPoint(x: -86.21, y: -29.5))
        batteryBGPath.addLine(to: CGPoint(x: 72.21, y: -29.5))
        batteryBGPath.addCurve(to: CGPoint(x: 80.8, y: -28.85), controlPoint1: CGPoint(x: 76.62, y: -29.5), controlPoint2: CGPoint(x: 78.82, y: -29.5))
        batteryBGPath.addLine(to: CGPoint(x: 81.19, y: -28.75))
        batteryBGPath.addCurve(to: CGPoint(x: 86.75, y: -23.19), controlPoint1: CGPoint(x: 83.77, y: -27.81), controlPoint2: CGPoint(x: 85.81, y: -25.77))
        batteryBGPath.addCurve(to: CGPoint(x: 87.5, y: -14.21), controlPoint1: CGPoint(x: 87.5, y: -20.82), controlPoint2: CGPoint(x: 87.5, y: -18.62))
        batteryBGPath.addLine(to: CGPoint(x: 87.5, y: 15.21))
        batteryBGPath.addCurve(to: CGPoint(x: 86.85, y: 23.8), controlPoint1: CGPoint(x: 87.5, y: 19.62), controlPoint2: CGPoint(x: 87.5, y: 21.82))
        batteryBGPath.addLine(to: CGPoint(x: 86.75, y: 24.19))
        batteryBGPath.addCurve(to: CGPoint(x: 81.19, y: 29.75), controlPoint1: CGPoint(x: 85.81, y: 26.77), controlPoint2: CGPoint(x: 83.77, y: 28.81))
        batteryBGPath.addCurve(to: CGPoint(x: 72.21, y: 30.5), controlPoint1: CGPoint(x: 78.82, y: 30.5), controlPoint2: CGPoint(x: 76.62, y: 30.5))
        batteryBGPath.addLine(to: CGPoint(x: -86.21, y: 30.5))
        batteryBGPath.addCurve(to: CGPoint(x: -94.8, y: 29.85), controlPoint1: CGPoint(x: -90.62, y: 30.5), controlPoint2: CGPoint(x: -92.82, y: 30.5))
        batteryBGPath.addLine(to: CGPoint(x: -95.19, y: 29.75))
        batteryBGPath.addCurve(to: CGPoint(x: -100.75, y: 24.19), controlPoint1: CGPoint(x: -97.77, y: 28.81), controlPoint2: CGPoint(x: -99.81, y: 26.77))
        batteryBGPath.addCurve(to: CGPoint(x: -101.5, y: 15.21), controlPoint1: CGPoint(x: -101.5, y: 21.82), controlPoint2: CGPoint(x: -101.5, y: 19.62))
        batteryBGPath.addLine(to: CGPoint(x: -101.5, y: -14.21))
        batteryBGPath.addCurve(to: CGPoint(x: -100.85, y: -22.8), controlPoint1: CGPoint(x: -101.5, y: -18.62), controlPoint2: CGPoint(x: -101.5, y: -20.82))
        batteryBGPath.addLine(to: CGPoint(x: -100.75, y: -23.19))
        batteryBGPath.addCurve(to: CGPoint(x: -95.19, y: -28.75), controlPoint1: CGPoint(x: -99.81, y: -25.77), controlPoint2: CGPoint(x: -97.77, y: -27.81))
        batteryBGPath.addCurve(to: CGPoint(x: -86.21, y: -29.5), controlPoint1: CGPoint(x: -92.82, y: -29.5), controlPoint2: CGPoint(x: -90.62, y: -29.5))
        batteryBGPath.close()
        batteryBGPath.move(to: CGPoint(x: 87.75, y: -16.5))
        batteryBGPath.addCurve(to: CGPoint(x: 87.5, y: -11.01), controlPoint1: CGPoint(x: 87.5, y: -15.1), controlPoint2: CGPoint(x: 87.5, y: -13.48))
        batteryBGPath.addLine(to: CGPoint(x: 87.5, y: 12.82))
        batteryBGPath.addCurve(to: CGPoint(x: 87.62, y: 17.5), controlPoint1: CGPoint(x: 87.5, y: 14.86), controlPoint2: CGPoint(x: 87.5, y: 16.32))
        batteryBGPath.addCurve(to: CGPoint(x: 88.23, y: 17.5), controlPoint1: CGPoint(x: 87.82, y: 17.5), controlPoint2: CGPoint(x: 88.02, y: 17.5))
        batteryBGPath.addLine(to: CGPoint(x: 89.77, y: 17.5))
        batteryBGPath.addCurve(to: CGPoint(x: 96.64, y: 17.08), controlPoint1: CGPoint(x: 93.29, y: 17.5), controlPoint2: CGPoint(x: 95.05, y: 17.5))
        batteryBGPath.addLine(to: CGPoint(x: 96.95, y: 17.01))
        batteryBGPath.addCurve(to: CGPoint(x: 101.4, y: 13.41), controlPoint1: CGPoint(x: 99.02, y: 16.41), controlPoint2: CGPoint(x: 100.65, y: 15.09))
        batteryBGPath.addCurve(to: CGPoint(x: 102, y: 7.6), controlPoint1: CGPoint(x: 102, y: 11.88), controlPoint2: CGPoint(x: 102, y: 10.45))
        batteryBGPath.addLine(to: CGPoint(x: 102, y: -6.6))
        batteryBGPath.addCurve(to: CGPoint(x: 101.48, y: -12.16), controlPoint1: CGPoint(x: 102, y: -9.45), controlPoint2: CGPoint(x: 102, y: -10.88))
        batteryBGPath.addLine(to: CGPoint(x: 101.4, y: -12.41))
        batteryBGPath.addCurve(to: CGPoint(x: 96.95, y: -16.01), controlPoint1: CGPoint(x: 100.65, y: -14.09), controlPoint2: CGPoint(x: 99.02, y: -15.41))
        batteryBGPath.addCurve(to: CGPoint(x: 89.77, y: -16.5), controlPoint1: CGPoint(x: 95.05, y: -16.5), controlPoint2: CGPoint(x: 93.29, y: -16.5))
        batteryBGPath.addLine(to: CGPoint(x: 88.23, y: -16.5))
        batteryBGPath.addCurve(to: CGPoint(x: 87.75, y: -16.5), controlPoint1: CGPoint(x: 88.07, y: -16.5), controlPoint2: CGPoint(x: 87.91, y: -16.5))
        batteryBGPath.close()
        
        var batteryColor = SKColor.green
        if batteryfillColor != nil {
            batteryColor = batteryfillColor!
        } else {
            if percent < 0.65 { batteryColor = SKColor.yellow }
            if percent < 0.3 { batteryColor = SKColor.red }
        }
        
        let batteryShapeNode = SKShapeNode.init(path: batteryBGPath.cgPath)
        batteryShapeNode.lineWidth = lineWidth
        batteryShapeNode.strokeColor = strokeColor
        batteryShapeNode.fillColor = backgroundColor
        
        let overallSize = CGSize.init(width: 57.0, height: 186.0)
        let pathCenter = CGPoint.init(x: -100, y: -28)
        
        let fillHeight = overallSize.width - innerPadding*2
        let fillWidth = overallSize.height - innerPadding*2
        let percFullIndicator = SKSpriteNode.init(color: batteryColor, size: CGSize.init(width: fillWidth, height: fillHeight))
        percFullIndicator.position = CGPoint.init(x: pathCenter.x + innerPadding, y: pathCenter.y + innerPadding )
        percFullIndicator.anchorPoint = CGPoint.init(x: 0, y: 0)
        percFullIndicator.xScale = CGFloat(percent)
        percFullIndicator.name = "percFullIndicator"
        
        batteryShapeNode.addChild(percFullIndicator)
        
        let scaleMult:CGFloat = 0.25
        
        batteryShapeNode.xScale = scaleMult
        batteryShapeNode.yScale = scaleMult
        
        batteryShapeNode.name = "batteryShape"
        
        self.addChild(batteryShapeNode)
        
        //check to see if we need to update time every minute
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForMinutesChanged(notification:)), name: ClockTimer.timeChangedMinuteNotificationName, object: nil)
        //force update time if needed ( after restart )
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForForceUpdateTime(notification:)), name: SKWatchScene.timeForceUpdateNotificationName, object: nil)
    }
    
    @objc func onNotificationForMinutesChanged(notification:Notification) {
        setToTime()
    }
    
    @objc func onNotificationForForceUpdateTime(notification:Notification) {
        setToTime()
    }
    
    func setToTime() {
        if let batteryShapeNode = self.childNode(withName: "batteryShape"), let percFullIndicator = batteryShapeNode.childNode(withName: "percFullIndicator") {
            let batPercent = BatteryNode.getLevel()
            percFullIndicator.xScale = CGFloat(batPercent)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
