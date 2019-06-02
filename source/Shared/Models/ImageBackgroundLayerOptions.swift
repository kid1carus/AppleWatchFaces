//
//  ImageBackgroundLayerOptions.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/19/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation

class ImageBackgroundLayerOptions: FaceLayerOptions {
    var filename: String
    var backgroundType: FaceBackgroundTypes
    
    var hasTransparency: Bool       // will save and load as PNG to preserve transp
    var anglePerSec: Float          // 1 = 6 seconds to go all the way around
    
    //
    
    //init from JSON, ( in from txt files )
    init(jsonObj: JSON ) {
        self.filename = jsonObj["filename"].stringValue
        let backgroundTypeString = jsonObj["backgroundType"].stringValue
        if let backgroundType = FaceBackgroundTypes(rawValue: backgroundTypeString) {
            self.backgroundType = backgroundType
        } else {
            self.backgroundType = .FaceBackgroundTypeFilled
        }
        self.hasTransparency = NSObject.boolValueForJSONObj(jsonObj: jsonObj, defaultVal: false, key: "hasTransparency")
        self.anglePerSec = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.0, key: "anglePerSec")
        
        
        super.init()
    }
    
    init(defaults: Bool ) {
        self.filename = ""
        self.backgroundType = .FaceBackgroundTypeFilled
        self.hasTransparency = false
        self.anglePerSec = 0.0
        
        super.init()
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "filename" ] = self.filename as AnyObject
        serializedDict[ "backgroundType" ] = self.backgroundType.rawValue as AnyObject
        serializedDict[ "hasTransparency" ] = NSNumber.init(value: self.hasTransparency as Bool)
        serializedDict[ "anglePerSec" ] = self.anglePerSec as AnyObject
    
        return serializedDict as NSDictionary
    }
    
}


