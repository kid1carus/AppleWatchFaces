//
//  ClockOverlaySetting.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 4/7/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit

//different types of shapes rings can render in
//enum OverlayShapeTypes: String {
//    case Circle, Square, Snowflake, Star, Triangle, Heart, Smiley, Skull, Poo
//    
//    static let userSelectableValues = [Circle, Square, Snowflake, Star, Heart, Smiley, Skull, Poo]
//}

//hold settings like shape, strength, etc for properites esp the physics node types
class ClockOverlaySetting: NSObject {
    
    var fieldType: PhysicsFieldTypes
    var shapeType: OverlayShapeTypes
    var itemSize: Float
    var itemStrength: Float
    
    init(shapeType: OverlayShapeTypes, fieldType: PhysicsFieldTypes, itemSize: Float, itemStrength: Float) {
        self.shapeType = shapeType
        self.fieldType = fieldType
        self.itemSize = itemSize
        self.itemStrength = itemStrength
    }
    
    static func defaults() -> ClockOverlaySetting {
        return ClockOverlaySetting.init(shapeType: .Circle, fieldType: .None, itemSize: 0, itemStrength: 1.0)
    }
    
    convenience init( jsonObj: JSON ) {
        var shapeType:OverlayShapeTypes = .Circle
        if (jsonObj["shapeType"] != JSON.null) {
            shapeType = OverlayShapeTypes(rawValue: jsonObj["shapeType"].stringValue)!
        }
        
        var fieldType:PhysicsFieldTypes = .None
        if (jsonObj["fieldType"] != JSON.null) {
            fieldType = PhysicsFieldTypes(rawValue: jsonObj["fieldType"].stringValue)!
        }
        let itemSize:Float = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.0, key: "itemSize")
        let itemStrength:Float = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 1.0, key: "itemStrength")
        
        self.init(shapeType: shapeType, fieldType: fieldType, itemSize: itemSize, itemStrength: itemStrength)
    }
    
    func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "shapeType" ] = self.shapeType.rawValue as AnyObject
        serializedDict[ "fieldType" ] = self.fieldType.rawValue as AnyObject
        serializedDict[ "itemSize" ] = self.itemSize.description as AnyObject
        serializedDict[ "itemStrength" ] = self.itemStrength.description as AnyObject
        
        return serializedDict as NSDictionary
    }
    
    static func multiplierForOverlayShape( shapeType: OverlayShapeTypes) -> CGFloat {
        //depending on the enoji render, we need to create a ratio for sizing to match physics shapes
        var mult:CGFloat = 0.04
        
        if (shapeType == .Circle)       { mult = 0.04 }
        if (shapeType == .Square)       { mult = 0.04 }
        if (shapeType == .Snowflake)    { mult = 0.05 }
        if (shapeType == .Star)         { mult = 0.07 }
        if (shapeType == .Triangle)     { mult = 0.06 }
        if (shapeType == .Heart)        { mult = 0.07 }
        if (shapeType == .Smiley)       { mult = 0.04 }
        if (shapeType == .Skull)        { mult = 0.05 }
        if (shapeType == .Poo)          { mult = 0.05 }
        
        return mult
    }
    
    static func descriptionForOverlayShapeType(_ shapeType: OverlayShapeTypes) -> String {
        var typeDescription = ""
        
        if (shapeType == .Circle)  { typeDescription = "●" }
        if (shapeType == .Square)  { typeDescription = "■" }
        if (shapeType == .Snowflake)  { typeDescription = "❆" }
        if (shapeType == .Star)  { typeDescription = "✦" }
        if (shapeType == .Triangle)  { typeDescription = "▲" }
        if (shapeType == .Heart)  { typeDescription = "❤︎" }
        if (shapeType == .Smiley)  { typeDescription = "😃" }
        if (shapeType == .Skull)  { typeDescription = "💀" }
        if (shapeType == .Poo)  { typeDescription = "💩" }
        
        return typeDescription
    }
    
    static func overlayShapeTypeDescriptions() -> [String] {
        var typeDescriptionsArray = [String]()
        for nodeType in OverlayShapeTypes.userSelectableValues {
            typeDescriptionsArray.append(descriptionForOverlayShapeType(nodeType))
        }
        
        return typeDescriptionsArray
    }
    
    static func overlayShapeTypeKeys() -> [String] {
        var typeKeysArray = [String]()
        for nodeType in OverlayShapeTypes.userSelectableValues {
            typeKeysArray.append(nodeType.rawValue)
        }
        
        return typeKeysArray
    }
    
}
