//
//  FaceLayer.swift
//  Clockology
//
//  Created by Mike Hill on 5/4/19.
//  Copyright © 2019 Mike Hill. All rights reserved.
//

//import Cocoa
import SpriteKit

class FaceLayer: NSObject {
    
    //TODO: stuff that applies to all layers
    
    //scale
    //position
    //alpha
    var alpha: Float = 1.0
    
    //type: secondHand, minuteHand, DTLabel, ShapeRing
    
    init(alpha: Float) {
        self.alpha = alpha
    
        super.init()
    }
    
    static func defaults() -> FaceLayer {
        return FaceLayer.init( alpha: 1.0 )
    }
    
    //init from JSON, ( in from txt files )
    init(jsonObj: JSON ) {
        self.alpha = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 1.0, key: "alpha")
        
        super.init()
    }
    
    //out to serialized . text files
    func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()

        serializedDict[ "alpha" ] = self.alpha.description as AnyObject

        return serializedDict as NSDictionary
    }
}
