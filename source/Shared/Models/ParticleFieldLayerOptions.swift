//
//  FieldLayerOptions.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/25/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation
import UIKit

//different types of shapes rings can render in
enum OverlayShapeTypes: String {
    case Circle, Square, Snowflake, Star, Triangle, Heart, Smiley, Skull, Poo
    
    static let userSelectableValues = [Circle, Square, Snowflake, Star, Heart, Smiley, Skull, Poo]
}

//hold settings like shape, strength, etc for properites esp the physics node types
class ParticleFieldLayerOptions: FaceLayerOptions {
    
    var nodeType: FaceForegroundTypes
    
    var shapeType: OverlayShapeTypes
    var itemSize: Float
    
    init(nodeType: FaceForegroundTypes, shapeType: OverlayShapeTypes, itemSize: Float) {
        
        self.nodeType = nodeType
        
        self.shapeType = shapeType
        self.itemSize = itemSize
    }
    
    static func defaults() -> ParticleFieldLayerOptions {
        return ParticleFieldLayerOptions.init(nodeType: .AnimatedPhysicsField, shapeType: .Circle, itemSize: 0)
    }
    
    init(defaults: Bool ) {
        self.nodeType = .AnimatedPhysicsField
        self.itemSize = 0
        self.shapeType = .Circle
        
        super.init()
    }
    
    convenience init( jsonObj: JSON ) {
        
        var nodeType:FaceForegroundTypes = .AnimatedPhysicsField
        if (jsonObj["nodeType"] != JSON.null) {
            nodeType = FaceForegroundTypes(rawValue: jsonObj["nodeType"].stringValue)!
        }
        
        var shapeType:OverlayShapeTypes = .Circle
        if (jsonObj["shapeType"] != JSON.null) {
            shapeType = OverlayShapeTypes(rawValue: jsonObj["shapeType"].stringValue)!
        }
        
        let itemSize:Float = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0.0, key: "itemSize")
        
        self.init(nodeType: nodeType, shapeType: shapeType, itemSize: itemSize)
    }
    
    override func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "nodeType" ] = self.nodeType.rawValue as AnyObject
        serializedDict[ "shapeType" ] = self.shapeType.rawValue as AnyObject
        serializedDict[ "itemSize" ] = self.itemSize.description as AnyObject
        
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
