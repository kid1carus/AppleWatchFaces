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
    
    var outlineWidth: Float
    var desiredThemeColorIndexForOutline: Int
    var handImage: String
    var handAnimation: SecondHandMovements
    var effectsStrength: Float
    
    //init from JSON, ( in from txt files )
    init(jsonObj: JSON ) {
        self.handType = SecondHandTypes(rawValue: jsonObj["handType"].stringValue)!
        self.outlineWidth = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.0, key: "outlineWidth")
        self.desiredThemeColorIndexForOutline = NSObject.intValueForJSONObj(jsonObj: jsonObj, defaultVal: 0, key: "desiredThemeColorIndexForOutline")
        self.handImage = NSObject.stringValueForJSONObj(jsonObj: jsonObj, defaultVal: "", key: "handImage")
        self.handAnimation = SecondHandMovements(rawValue: jsonObj["handAnimation"].stringValue)!
        self.effectsStrength = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.0, key: "effectsStrength")
        
        super.init()
    }
    
    init(defaults: Bool ) {
        self.handType = .SecondHandTypeBlocky
        self.outlineWidth = 0.0
        self.desiredThemeColorIndexForOutline = 0
        
        self.handImage = ""
        self.handAnimation = .SecondHandMovementStep
        self.effectsStrength = 0.0
        
        super.init()
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "handType" ] = self.handType.rawValue as AnyObject
        
        serializedDict[ "outlineWidth" ] = self.outlineWidth.description as AnyObject
        serializedDict[ "desiredThemeColorIndexForOutline" ] = self.desiredThemeColorIndexForOutline.description as AnyObject
        
        serializedDict[ "handImage" ] = self.handImage as AnyObject
        serializedDict[ "handAnimation" ] = self.handAnimation.rawValue as AnyObject
        serializedDict[ "effectsStrength" ] = self.effectsStrength.description as AnyObject
        
        return serializedDict as NSDictionary
    }
}
