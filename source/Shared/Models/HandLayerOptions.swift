//
//  HandLayerOptions.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/5/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation

class SecondHandLayerOptions: HandLayerOptions {
    var handType: SecondHandTypes
    var handAnimation: SecondHandMovements
    var physicsFieldType: PhysicsFieldTypes
    var physicFieldStrength: Float
    
    override init(jsonObj: JSON ) {
        self.handType = SecondHandTypes(rawValue: jsonObj["handType"].stringValue)!
        if (jsonObj["physicsFieldType"] != JSON.null) {
            self.physicsFieldType = PhysicsFieldTypes(rawValue: jsonObj["physicsFieldType"].stringValue)!
        } else {
            self.physicsFieldType = .None
        }
        self.physicFieldStrength = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 2.0, key: "physicFieldStrength")
        self.handAnimation = SecondHandMovements(rawValue: jsonObj["handAnimation"].stringValue)!
        
        super.init(jsonObj: jsonObj)
    }
    
    override init(defaults: Bool ) {
        self.handType = .SecondHandTypeBlocky
        self.physicsFieldType = .None
        self.physicFieldStrength = 2.0
        self.handAnimation = .SecondHandMovementStep
        
        super.init(defaults: defaults)
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = super.serializedSettings() as! [String:AnyObject]
        
        serializedDict[ "handType" ] = self.handType.rawValue as AnyObject
        serializedDict[ "physicsFieldType" ] = self.physicsFieldType.rawValue as AnyObject
        serializedDict[ "physicFieldStrength" ] = self.physicFieldStrength.description as AnyObject
        serializedDict[ "handAnimation" ] = self.handAnimation.rawValue as AnyObject
        
        return serializedDict as NSDictionary
    }
}

class MinuteHandLayerOptions: HandLayerOptions {
    var handType: MinuteHandTypes
    var handAnimation: MinuteHandMovements
    
    override init(jsonObj: JSON ) {
        self.handType = MinuteHandTypes(rawValue: jsonObj["handType"].stringValue)!
        if (jsonObj["handAnimation"] != JSON.null), let handAnimation = MinuteHandMovements(rawValue: jsonObj["handAnimation"].stringValue) {
            self.handAnimation = handAnimation
        } else {
            self.handAnimation = .MinuteHandMovementStep
        }
        
        super.init(jsonObj: jsonObj)
    }
    
    override init(defaults: Bool ) {
        self.handType = .MinuteHandTypeBoxy
        self.handAnimation = .MinuteHandMovementStep
        super.init(defaults: defaults)
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = super.serializedSettings() as! [String:AnyObject]
        
        serializedDict[ "handType" ] = self.handType.rawValue as AnyObject
        serializedDict[ "handAnimation" ] = self.handAnimation.rawValue as AnyObject
        
        return serializedDict as NSDictionary
    }
}

class HourHandLayerOptions: HandLayerOptions {
    var handType: HourHandTypes
    
    override init(jsonObj: JSON ) {
        self.handType = HourHandTypes(rawValue: jsonObj["handType"].stringValue)!
        super.init(jsonObj: jsonObj)
    }
    
    override init(defaults: Bool ) {
        self.handType = .HourHandTypeBoxy
        super.init(defaults: defaults)
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = super.serializedSettings() as! [String:AnyObject]
        serializedDict[ "handType" ] = self.handType.rawValue as AnyObject
        return serializedDict as NSDictionary
    }
}

class HandLayerOptions: FaceLayerOptions {

    var outlineWidth: Float
    var desiredThemeColorIndexForOutline: Int
    var handImage: String
    var effectsStrength: Float
    
    //init from JSON, ( in from txt files )
    init(jsonObj: JSON ) {
        
        self.outlineWidth = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.0, key: "outlineWidth")
        self.desiredThemeColorIndexForOutline = NSObject.intValueForJSONObj(jsonObj: jsonObj, defaultVal: 0, key: "desiredThemeColorIndexForOutline")
        self.handImage = NSObject.stringValueForJSONObj(jsonObj: jsonObj, defaultVal: "", key: "handImage")
        self.effectsStrength = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.0, key: "effectsStrength")
        
        super.init()
    }
    
    init(defaults: Bool ) {
        self.outlineWidth = 0.0
        self.desiredThemeColorIndexForOutline = 0
        
        self.handImage = ""
        self.effectsStrength = 0.0
        
        super.init()
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()

        serializedDict[ "outlineWidth" ] = self.outlineWidth.description as AnyObject
        serializedDict[ "desiredThemeColorIndexForOutline" ] = self.desiredThemeColorIndexForOutline.description as AnyObject
        
        serializedDict[ "handImage" ] = self.handImage as AnyObject
        serializedDict[ "effectsStrength" ] = self.effectsStrength.description as AnyObject
        
        return serializedDict as NSDictionary
    }
}
