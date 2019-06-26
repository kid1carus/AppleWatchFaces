//
//  ShapeLayerDigitalTimeOptions.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/18/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation

class DigitalTimeLayerOptions: FaceLayerOptions {
    var fontType: NumberTextTypes
    var formatType: DigitalTimeFormats
    var justificationType: HorizontalPositionTypes
    var effectType: DigitalTimeEffects
    var outlineWidth: Float
    var desiredThemeColorIndexForOutline: Int
    
    //init from JSON, ( in from txt files )
    init(jsonObj: JSON ) {
    
        let fontTypeString = jsonObj["fontType"].stringValue
        if let fontType = NumberTextTypes(rawValue: fontTypeString) {
            self.fontType = fontType
        } else {
            self.fontType = .NumberTextTypeSystem
        }
        let formatTypeString = jsonObj["formatType"].stringValue
        if let formatType = DigitalTimeFormats(rawValue: formatTypeString) {
            self.formatType = formatType
        } else {
            self.formatType = .HHMM
        }
        let effectTypeString = jsonObj["effectType"].stringValue
        if let effectType = DigitalTimeEffects(rawValue: effectTypeString) {
            self.effectType = effectType
        } else {
            self.effectType = .None
        }
        let justificationTypeString = jsonObj["justificationType"].stringValue
        if let justificationType = HorizontalPositionTypes(rawValue: justificationTypeString) {
            self.justificationType = justificationType
        } else {
            self.justificationType = .Centered
        }
        
        self.outlineWidth = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.0, key: "outlineWidth")
        self.desiredThemeColorIndexForOutline = NSObject.intValueForJSONObj(jsonObj: jsonObj, defaultVal: 0, key: "desiredThemeColorIndexForOutline")
        
        super.init()
    }
    
    init(defaults: Bool ) {
        self.fontType = .NumberTextTypeSystem
        self.formatType = .HHMM
        self.effectType = .None
        self.outlineWidth = 0.0
        self.desiredThemeColorIndexForOutline = 0
        self.justificationType = .Centered
        
        super.init()
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "fontType" ] = self.fontType.rawValue as AnyObject
        serializedDict[ "formatType" ] = self.formatType.rawValue as AnyObject
        serializedDict[ "effectType" ] = self.effectType.rawValue as AnyObject
        serializedDict[ "justificationType" ] = self.justificationType.rawValue as AnyObject
        
        serializedDict[ "outlineWidth" ] = self.outlineWidth.description as AnyObject
        serializedDict[ "desiredThemeColorIndexForOutline" ] = self.desiredThemeColorIndexForOutline.description as AnyObject
        
        return serializedDict as NSDictionary
    }

}

