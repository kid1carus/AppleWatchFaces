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
    //
    
    //init from JSON, ( in from txt files )
    init(jsonObj: JSON ) {
        self.filename = jsonObj["filename"].stringValue
        
        super.init()
    }
    
    init(defaults: Bool ) {
        self.filename = ""
        
        super.init()
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "filename" ] = self.filename as AnyObject
    
        return serializedDict as NSDictionary
    }
    
}


