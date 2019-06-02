//
//  GearLayerOptions.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 6/3/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit

class GearLayerOptions: FaceLayerOptions {
    var gearType: GearTypes
    var anglePerSec: Float          // 1 = 6 seconds to go all the way around
    var outlineWidth: Float
    var desiredThemeColorIndexForOutline: Int
    
    //init from JSON, ( in from txt files )
    init(jsonObj: JSON ) {
        let typeString = jsonObj["gearType"].stringValue
        if let gearType = GearTypes(rawValue: typeString) {
            self.gearType = gearType
        } else {
            self.gearType = .Big
        }
        self.anglePerSec = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.0, key: "anglePerSec")
        self.outlineWidth = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.0, key: "outlineWidth")
        self.desiredThemeColorIndexForOutline = NSObject.intValueForJSONObj(jsonObj: jsonObj, defaultVal: 0, key: "desiredThemeColorIndexForOutline")
        
        super.init()
    }
    
    init(defaults: Bool ) {
        self.gearType = .Big
        self.anglePerSec = 0.0
        self.outlineWidth = 0.0
        self.desiredThemeColorIndexForOutline = 0
        
        super.init()
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "gearType" ] = self.gearType.rawValue as AnyObject
        serializedDict[ "anglePerSec" ] = self.anglePerSec as AnyObject
        serializedDict[ "outlineWidth" ] = self.outlineWidth.description as AnyObject
        serializedDict[ "desiredThemeColorIndexForOutline" ] = self.desiredThemeColorIndexForOutline.description as AnyObject
        
        return serializedDict as NSDictionary
    }
}
