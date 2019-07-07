//
//  BatteryNode.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 7/7/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation
import SpriteKit

class BatteryNode: SKShapeNode {
    
    static func getLevel() -> Float {
        var batteryPercent:Float = 100
        
        #if os(watchOS)
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
        batteryPercent = WKInterfaceDevice.current().batteryLevel
        //var batteryState = WKInterfaceDevice.current().batteryState
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = false
        #else
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
    }
    
    init(percent: CGFloat, batteryfillColor: SKColor?, backgroundColor: SKColor, strokeColor: SKColor, lineWidth: CGFloat, innerPadding: CGFloat) {
        
        super.init()
        
        let batteryBGPath = UIBezierPath()
        batteryBGPath.move(to: CGPoint(x: 36.79, y: 24.5))
        batteryBGPath.addLine(to: CGPoint(x: 195.21, y: 24.5))
        batteryBGPath.addCurve(to: CGPoint(x: 203.8, y: 25.15), controlPoint1: CGPoint(x: 199.62, y: 24.5), controlPoint2: CGPoint(x: 201.82, y: 24.5))
        batteryBGPath.addLine(to: CGPoint(x: 204.19, y: 25.25))
        batteryBGPath.addCurve(to: CGPoint(x: 209.75, y: 30.81), controlPoint1: CGPoint(x: 206.77, y: 26.19), controlPoint2: CGPoint(x: 208.81, y: 28.23))
        batteryBGPath.addCurve(to: CGPoint(x: 210.5, y: 39.79), controlPoint1: CGPoint(x: 210.5, y: 33.18), controlPoint2: CGPoint(x: 210.5, y: 35.38))
        batteryBGPath.addLine(to: CGPoint(x: 210.5, y: 69.21))
        batteryBGPath.addCurve(to: CGPoint(x: 209.85, y: 77.8), controlPoint1: CGPoint(x: 210.5, y: 73.62), controlPoint2: CGPoint(x: 210.5, y: 75.82))
        batteryBGPath.addLine(to: CGPoint(x: 209.75, y: 78.19))
        batteryBGPath.addCurve(to: CGPoint(x: 204.19, y: 83.75), controlPoint1: CGPoint(x: 208.81, y: 80.77), controlPoint2: CGPoint(x: 206.77, y: 82.81))
        batteryBGPath.addCurve(to: CGPoint(x: 195.21, y: 84.5), controlPoint1: CGPoint(x: 201.82, y: 84.5), controlPoint2: CGPoint(x: 199.62, y: 84.5))
        batteryBGPath.addLine(to: CGPoint(x: 36.79, y: 84.5))
        batteryBGPath.addCurve(to: CGPoint(x: 28.2, y: 83.85), controlPoint1: CGPoint(x: 32.38, y: 84.5), controlPoint2: CGPoint(x: 30.18, y: 84.5))
        batteryBGPath.addLine(to: CGPoint(x: 27.81, y: 83.75))
        batteryBGPath.addCurve(to: CGPoint(x: 22.25, y: 78.19), controlPoint1: CGPoint(x: 25.23, y: 82.81), controlPoint2: CGPoint(x: 23.19, y: 80.77))
        batteryBGPath.addCurve(to: CGPoint(x: 21.5, y: 69.21), controlPoint1: CGPoint(x: 21.5, y: 75.82), controlPoint2: CGPoint(x: 21.5, y: 73.62))
        batteryBGPath.addLine(to: CGPoint(x: 21.5, y: 39.79))
        batteryBGPath.addCurve(to: CGPoint(x: 22.15, y: 31.2), controlPoint1: CGPoint(x: 21.5, y: 35.38), controlPoint2: CGPoint(x: 21.5, y: 33.18))
        batteryBGPath.addLine(to: CGPoint(x: 22.25, y: 30.81))
        batteryBGPath.addCurve(to: CGPoint(x: 27.81, y: 25.25), controlPoint1: CGPoint(x: 23.19, y: 28.23), controlPoint2: CGPoint(x: 25.23, y: 26.19))
        batteryBGPath.addCurve(to: CGPoint(x: 36.79, y: 24.5), controlPoint1: CGPoint(x: 30.18, y: 24.5), controlPoint2: CGPoint(x: 32.38, y: 24.5))
        batteryBGPath.close()
        batteryBGPath.move(to: CGPoint(x: 210.75, y: 37.5))
        batteryBGPath.addCurve(to: CGPoint(x: 210.5, y: 42.99), controlPoint1: CGPoint(x: 210.5, y: 38.9), controlPoint2: CGPoint(x: 210.5, y: 40.52))
        batteryBGPath.addLine(to: CGPoint(x: 210.5, y: 66.82))
        batteryBGPath.addCurve(to: CGPoint(x: 210.62, y: 71.5), controlPoint1: CGPoint(x: 210.5, y: 68.86), controlPoint2: CGPoint(x: 210.5, y: 70.32))
        batteryBGPath.addCurve(to: CGPoint(x: 211.23, y: 71.5), controlPoint1: CGPoint(x: 210.82, y: 71.5), controlPoint2: CGPoint(x: 211.02, y: 71.5))
        batteryBGPath.addLine(to: CGPoint(x: 212.77, y: 71.5))
        batteryBGPath.addCurve(to: CGPoint(x: 219.64, y: 71.08), controlPoint1: CGPoint(x: 216.29, y: 71.5), controlPoint2: CGPoint(x: 218.05, y: 71.5))
        batteryBGPath.addLine(to: CGPoint(x: 219.95, y: 71.01))
        batteryBGPath.addCurve(to: CGPoint(x: 224.4, y: 67.41), controlPoint1: CGPoint(x: 222.02, y: 70.41), controlPoint2: CGPoint(x: 223.65, y: 69.09))
        batteryBGPath.addCurve(to: CGPoint(x: 225, y: 61.6), controlPoint1: CGPoint(x: 225, y: 65.88), controlPoint2: CGPoint(x: 225, y: 64.45))
        batteryBGPath.addLine(to: CGPoint(x: 225, y: 47.4))
        batteryBGPath.addCurve(to: CGPoint(x: 224.48, y: 41.84), controlPoint1: CGPoint(x: 225, y: 44.55), controlPoint2: CGPoint(x: 225, y: 43.12))
        batteryBGPath.addLine(to: CGPoint(x: 224.4, y: 41.59))
        batteryBGPath.addCurve(to: CGPoint(x: 219.95, y: 37.99), controlPoint1: CGPoint(x: 223.65, y: 39.91), controlPoint2: CGPoint(x: 222.02, y: 38.59))
        batteryBGPath.addCurve(to: CGPoint(x: 212.77, y: 37.5), controlPoint1: CGPoint(x: 218.05, y: 37.5), controlPoint2: CGPoint(x: 216.29, y: 37.5))
        batteryBGPath.addLine(to: CGPoint(x: 211.23, y: 37.5))
        batteryBGPath.addCurve(to: CGPoint(x: 210.75, y: 37.5), controlPoint1: CGPoint(x: 211.07, y: 37.5), controlPoint2: CGPoint(x: 210.91, y: 37.5))
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
        
        let fillHeight = 57 - innerPadding*2
        let fillWidth = 186 - innerPadding*2
        let percFullIndicator = SKSpriteNode.init(color: batteryColor, size: CGSize.init(width: fillWidth, height: fillHeight))
        percFullIndicator.position = CGPoint.init(x: 22 + innerPadding, y: 26.0 + innerPadding )
        percFullIndicator.anchorPoint = CGPoint.init(x: 0, y: 0)
        percFullIndicator.xScale = CGFloat(percent)
        percFullIndicator.name = "percFullIndicator"
        
        batteryShapeNode.addChild(percFullIndicator)
        
        self.addChild(batteryShapeNode)
        
        //check to see if we need to update time every second
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
        if let percFullIndicator = self.childNode(withName: "percFullIndicator") {
            let batPercent = BatteryNode.getLevel()
            percFullIndicator.xScale = CGFloat(batPercent)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
