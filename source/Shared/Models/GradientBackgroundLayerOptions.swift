//
//  GradientBackgroundLayerOptions.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/19/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation

class GradientBackgroundLayerOptions: FaceLayerOptions {
    var directionType: GradientBackgroundDirectionTypes
    var desiredThemeColorIndexForDestination: Int
    
    //init from JSON, ( in from txt files )
    init(jsonObj: JSON ) {
        
        let directionTypeString = jsonObj["directionType"].stringValue
        if let directionType = GradientBackgroundDirectionTypes(rawValue: directionTypeString) {
            self.directionType = directionType
        } else {
            self.directionType = .Horizontal
        }
    
        self.desiredThemeColorIndexForDestination = NSObject.intValueForJSONObj(jsonObj: jsonObj, defaultVal: 0, key: "desiredThemeColorIndexForDestination")
        
        super.init()
    }
    
    init(defaults: Bool ) {
        self.directionType = .Horizontal
        self.desiredThemeColorIndexForDestination = 1
        
        super.init()
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "directionType" ] = self.directionType.rawValue as AnyObject
        
        serializedDict[ "desiredThemeColorIndexForDestination" ] = self.desiredThemeColorIndexForDestination.description as AnyObject
        
        return serializedDict as NSDictionary
    }
    
}

