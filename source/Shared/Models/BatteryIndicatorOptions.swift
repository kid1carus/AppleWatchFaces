//
//  BatteryIndicatorOptions.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 7/7/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit

class BatteryIndicatorOptions: FaceLayerOptions {
    var indicatorType: BatteryIndicatorTypes

    var outlineWidth: Float
    var innerPadding: Float

    var autoBatteryColor: Bool //will ignore desiredThemeColorIndexForBatteryLevel
    var desiredThemeColorIndexForOutline: Int
    var desiredThemeColorIndexForBatteryLevel: Int
    
    
    //init from JSON, ( in from txt files )
    init(jsonObj: JSON ) {
        
        let defaultOptions = BatteryIndicatorOptions.init(defaults: true)
        
        let typeString = jsonObj["indicatorType"].stringValue
        if let indicatorType = BatteryIndicatorTypes(rawValue: typeString) {
            self.indicatorType = indicatorType
        } else {
            self.indicatorType = defaultOptions.indicatorType
        }
        self.innerPadding = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: defaultOptions.innerPadding, key: "innerPadding")
        self.outlineWidth = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: defaultOptions.outlineWidth, key: "outlineWidth")
        self.desiredThemeColorIndexForOutline = NSObject.intValueForJSONObj(jsonObj: jsonObj, defaultVal: defaultOptions.desiredThemeColorIndexForOutline, key: "desiredThemeColorIndexForOutline")
        self.desiredThemeColorIndexForBatteryLevel = NSObject.intValueForJSONObj(jsonObj: jsonObj, defaultVal: defaultOptions.desiredThemeColorIndexForBatteryLevel, key: "desiredThemeColorIndexForBatteryLevel")
        
        self.autoBatteryColor = NSObject.boolValueForJSONObj(jsonObj: jsonObj, defaultVal: defaultOptions.autoBatteryColor, key: "autoBatteryColor")
        
        super.init()
    }
    
    init(defaults: Bool ) {
        self.indicatorType = .normal
        self.innerPadding = 5.0
        self.outlineWidth = 3.0
        self.desiredThemeColorIndexForOutline = 0
        self.desiredThemeColorIndexForBatteryLevel = 0
        self.autoBatteryColor = true
        
        super.init()
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "indicatorType" ] = self.indicatorType.rawValue as AnyObject
        
        serializedDict[ "autoBatteryColor" ] = NSNumber.init(value: self.autoBatteryColor as Bool)
        
        serializedDict[ "innerPadding" ] = self.innerPadding.description as AnyObject
        serializedDict[ "outlineWidth" ] = self.outlineWidth.description as AnyObject
        serializedDict[ "desiredThemeColorIndexForOutline" ] = self.desiredThemeColorIndexForOutline.description as AnyObject
        serializedDict[ "desiredThemeColorIndexForBatteryLevel" ] = self.desiredThemeColorIndexForBatteryLevel.description as AnyObject
        
        return serializedDict as NSDictionary
    }
}

