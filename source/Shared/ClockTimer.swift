//
//  ClockTimer.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 1/19/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit

class ClockTimer {
    //keep time at highest level and send out notifications
    var currentSecond : Int = -1
    var secondHandTimer = Timer()
    static let timeChangedSecondNotificationName = Notification.Name("timeChangedSecond")
    static let timeChangedMinuteNotificationName = Notification.Name("timeChangedMinute")
    static let timeChangedHourNotificationName = Notification.Name("timeChangedHour")
    static var currentDate = Date()
    
    func stopTimer() {
        self.secondHandTimer.invalidate()
    }
    
    func startTimer() {
        stopTimer() //just in case
        
        let duration = 0.1
        self.secondHandTimer = Timer.scheduledTimer( timeInterval: duration, target:self, selector: #selector(ClockTimer.secondHandMovementCheck), userInfo: nil, repeats: true)
    }
    
    @objc func secondHandMovementCheck() {
        let date = Date()
        
        let calendar = Calendar.current
        let seconds = Int(calendar.component(.second, from: date))
        let minute = Int(calendar.component(.minute, from: date))
        
        if (self.currentSecond != seconds) {
            ClockTimer.currentDate = Date()
            NotificationCenter.default.post(name: ClockTimer.timeChangedSecondNotificationName, object: nil, userInfo:nil)
            if (seconds == 0) {
                NotificationCenter.default.post(name: ClockTimer.timeChangedMinuteNotificationName, object: nil, userInfo:nil)
                
                if (minute == 0) {
                    NotificationCenter.default.post(name: ClockTimer.timeChangedHourNotificationName, object: nil, userInfo:nil)
                }
            }
            self.currentSecond = seconds
        }
        
    }
}
