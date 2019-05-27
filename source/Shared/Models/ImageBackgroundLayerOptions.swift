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
        
        super.init()
    }
    
    init(defaults: Bool ) {
        self.filename = ""
        self.backgroundType = .FaceBackgroundTypeFilled
        
        super.init()
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "filename" ] = self.filename as AnyObject
        serializedDict[ "backgroundType" ] = self.backgroundType.rawValue as AnyObject
    
        return serializedDict as NSDictionary
    }
    
}


