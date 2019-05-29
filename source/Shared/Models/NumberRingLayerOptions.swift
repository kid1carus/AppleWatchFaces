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
    var isRotating: Bool
    
    var outlineWidth: Float
    var desiredThemeColorIndexForOutline: Int
    var pathShape: RingRenderShapes
    
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
        
        let pathShapeString = jsonObj["pathShape"].stringValue
        if let pathShape = RingRenderShapes(rawValue: pathShapeString) {
            self.pathShape = pathShape
        } else {
            self.pathShape = .RingRenderShapeCircle
        }
        
        self.textSize = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.6, key: "textSize")
        self.patternTotal = NSObject.intValueForJSONObj(jsonObj: jsonObj, defaultVal: 12, key: "patternTotal")
        self.patternArray = patternArrayTemp
        
        self.isRotating = NSObject.boolValueForJSONObj(jsonObj: jsonObj, defaultVal: false, key: "isRotating")
        self.outlineWidth = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.0, key: "outlineWidth")
        self.desiredThemeColorIndexForOutline = NSObject.intValueForJSONObj(jsonObj: jsonObj, defaultVal: 0, key: "desiredThemeColorIndexForOutline")
        
        super.init()
    }
    
    init(defaults: Bool ) {
        self.fontType = .NumberTextTypeSystem
        self.textSize = 0.6
        self.patternTotal = 12
        self.patternArray = [1]
        
        self.isRotating = false
        self.outlineWidth = 0.0
        self.desiredThemeColorIndexForOutline = 0
        self.pathShape = .RingRenderShapeCircle
        
        super.init()
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "fontType" ] = self.fontType.rawValue as AnyObject
        serializedDict[ "textSize" ] = self.textSize.description as AnyObject
        
        serializedDict[ "patternTotal" ] = self.patternTotal.description as AnyObject
        serializedDict[ "patternArray" ] = self.patternArray as AnyObject
        
        serializedDict[ "isRotating" ] = NSNumber.init(value: self.isRotating as Bool)
        serializedDict[ "outlineWidth" ] = self.outlineWidth.description as AnyObject
        serializedDict[ "desiredThemeColorIndexForOutline" ] = self.desiredThemeColorIndexForOutline.description as AnyObject
        
        serializedDict[ "pathShape" ] = self.pathShape.rawValue as AnyObject
        
        return serializedDict as NSDictionary
    }
    
}

//different types of things that can be assigned to a ring on the clock face
enum RingTypes: String {
    case RingTypeShapeNode, RingTypeTextNode, RingTypeTextRotatingNode, RingTypeDigitalTime, RingTypeSpacer
    
    static let userSelectableValues = [RingTypeShapeNode, RingTypeTextNode, RingTypeTextRotatingNode, RingTypeDigitalTime, RingTypeSpacer]
}

//different types of shapes rings can render in
enum RingRenderShapes: String {
    case RingRenderShapeCircle, RingRenderShapeOval, RingRenderShapeRoundedRect
    
    static let userSelectableValues = [RingRenderShapeCircle, RingRenderShapeOval, RingRenderShapeRoundedRect]
}

//position types for statically positioned items like date, digital time
enum RingVerticalPositionTypes: String {
    case Top,
    Centered,
    Bottom,
    Numeric,
    None
}

enum RingHorizontalPositionTypes: String {
    case Left,
    Centered,
    Right,
    Numeric,
    None
}

