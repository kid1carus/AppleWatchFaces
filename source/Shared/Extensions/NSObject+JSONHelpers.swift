//
//  NSObject+JSONHelpers.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 4/7/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation

public extension NSObject {
    
    static func intValueForJSONObj( jsonObj: JSON, defaultVal: Int, key: String) -> Int {
        var intValue:Int = defaultVal
        if (jsonObj[key] != JSON.null) {
            intValue = Int( jsonObj[key].intValue )
        }
        return intValue
    }
    
    static func floatValueForJSONObj( jsonObj: JSON, defaultVal: Float, key: String) -> Float {
        var floatVal:Float = defaultVal
        if (jsonObj[key] != JSON.null) {
            floatVal = Float( jsonObj[key].floatValue )
        }
        return floatVal
    }
    
    static func boolValueForJSONObj( jsonObj: JSON, defaultVal: Bool, key: String) -> Bool {
        var boolVal:Bool = defaultVal
        if (jsonObj[key] != JSON.null) {
            boolVal = Bool( jsonObj[key].boolValue )
        }
        return boolVal
    }
    
    static func stringValueForJSONObj( jsonObj: JSON, defaultVal: String, key: String) -> String {
        var stringVal:String = defaultVal
        if (jsonObj[key] != JSON.null) {
            stringVal = jsonObj[key].stringValue
        }
        return stringVal
    }
    
    
}
