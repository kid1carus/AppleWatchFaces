//
//  ShapeLayer.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/5/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation

class ShapeLayerOptions: FaceLayerOptions {
    var indicatorType: FaceIndicatorTypes
    var indicatorSize: Float
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
        
        let indicatorTypeString = jsonObj["indicatorType"].stringValue
        self.indicatorType = FaceIndicatorTypes(rawValue: indicatorTypeString)!
        
        self.indicatorSize = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.0, key: "indicatorSize")
        self.patternTotal = NSObject.intValueForJSONObj(jsonObj: jsonObj, defaultVal: 12, key: "patternTotal")
        self.patternArray = patternArrayTemp
        
        super.init()
    }
    
    init(defaults: Bool ) {
        self.indicatorType = .FaceIndicatorTypeBox
        self.indicatorSize = 1.0
        self.patternTotal = 12
        self.patternArray = []
        
        super.init()
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "indicatorType" ] = self.indicatorType.rawValue as AnyObject
        serializedDict[ "indicatorSize" ] = self.indicatorSize.description as AnyObject
        
        serializedDict[ "patternTotal" ] = self.patternTotal.description as AnyObject
        serializedDict[ "patternArray" ] = self.patternArray as AnyObject
        
        return serializedDict as NSDictionary
    }
}
