//
//  NumberRingLayerOptions.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/20/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation

class NumberRingLayerOptions: FaceLayerOptions {
    var fontType: NumberTextTypes
    var textSize: Float
    var patternTotal: Int
    var patternArray: [Int]
    
    //init from JSON, ( in from txt files )
    init(jsonObj: JSON ) {
        
        var patternArrayTemp = [Int]()
        if let patternArraySerialized = jsonObj["patternArray"].array {
            for patternSerialized in patternArraySerialized {
                patternArrayTemp.append( patternSerialized.intValue )
            }
        }
        
        let fontTypeString = jsonObj["fontType"].stringValue
        if let fontType = NumberTextTypes(rawValue: fontTypeString) {
            self.fontType = fontType
        } else {
            self.fontType = .NumberTextTypeSystem
        }
        
        self.textSize = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.6, key: "textSize")
        self.patternTotal = NSObject.intValueForJSONObj(jsonObj: jsonObj, defaultVal: 12, key: "patternTotal")
        self.patternArray = patternArrayTemp
        
        super.init()
    }
    
    init(defaults: Bool ) {
        self.fontType = .NumberTextTypeSystem
        self.textSize = 0.6
        self.patternTotal = 12
        self.patternArray = [1]
        
        super.init()
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "fontType" ] = self.fontType.rawValue as AnyObject
        serializedDict[ "textSize" ] = self.textSize.description as AnyObject
        
        serializedDict[ "patternTotal" ] = self.patternTotal.description as AnyObject
        serializedDict[ "patternArray" ] = self.patternArray as AnyObject
        
        return serializedDict as NSDictionary
    }
    
}
