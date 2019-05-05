//
//  SecondHandLayerOptions.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/5/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation

class SecondHandLayerOptions: FaceLayerOptions {
    var handType: SecondHandTypes
    var handColor: String
    var handImage: String
    var handAnimation: SecondHandMovements
    var handOutline: Bool
    var effectsStrength: Float
    
    //init from JSON, ( in from txt files )
    init(jsonObj: JSON ) {
        self.handType = SecondHandTypes(rawValue: jsonObj["handType"].stringValue)!
        self.handColor = NSObject.stringValueForJSONObj(jsonObj: jsonObj, defaultVal: "#ffffffff", key: "handColor")
        self.handImage = NSObject.stringValueForJSONObj(jsonObj: jsonObj, defaultVal: "", key: "handImage")
        self.handAnimation = SecondHandMovements(rawValue: jsonObj["handAnimation"].stringValue)!
        self.handOutline = NSObject.boolValueForJSONObj(jsonObj: jsonObj, defaultVal: false, key: "handOutline")
        self.effectsStrength = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.0, key: "effectsStrength")
        
        super.init()
    }
    
    init(defaults: Bool ) {
        self.handType = .SecondHandTypeBlocky
        self.handColor = "#ffffffff"
        self.handImage = ""
        self.handAnimation = .SecondHandMovementStep
        self.handOutline = false
        self.effectsStrength = 0.0
        
        super.init()
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "handType" ] = self.handType.rawValue as AnyObject
        serializedDict[ "handColor" ] = self.handColor as AnyObject
        serializedDict[ "handImage" ] = self.handImage as AnyObject
        serializedDict[ "handAnimation" ] = self.handAnimation.rawValue as AnyObject
        serializedDict[ "handOutline" ] = NSNumber.init(value: self.handOutline as Bool)
        serializedDict[ "effectsStrength" ] = self.effectsStrength.description as AnyObject
        
        return serializedDict as NSDictionary
    }
}
