//
//  ShapeLayerDigitalTimeOptions.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/18/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation

class ShapeLayerDigitalTimeOptions: FaceLayerOptions {
    var fontType: NumberTextTypes
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
        
        self.outlineWidth = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.0, key: "outlineWidth")
        self.desiredThemeColorIndexForOutline = NSObject.intValueForJSONObj(jsonObj: jsonObj, defaultVal: 0, key: "desiredThemeColorIndexForOutline")
        
        super.init()
    }
    
    init(defaults: Bool ) {
        self.fontType = .NumberTextTypeSystem
        self.outlineWidth = 0.0
        self.desiredThemeColorIndexForOutline = 0
        
        super.init()
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "fontType" ] = self.fontType.rawValue as AnyObject
        serializedDict[ "outlineWidth" ] = self.outlineWidth.description as AnyObject
        
        serializedDict[ "desiredThemeColorIndexForOutline" ] = self.desiredThemeColorIndexForOutline.description as AnyObject
        
        return serializedDict as NSDictionary
    }

}

