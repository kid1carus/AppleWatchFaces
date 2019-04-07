//
//  ClockOverlaySetting.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 4/7/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation

//different types of shapes rings can render in
enum OverlayShapeTypes: String {
    case Circle, Square, Snowflake, Star
    
    static let userSelectableValues = [Circle, Square, Snowflake, Star]
}

//hold settings like shape, strength, etc for properites esp the physics node types
class ClockOverlaySetting: NSObject {
    
    var shapeType: OverlayShapeTypes
    
    init(shapeType: OverlayShapeTypes) {
        self.shapeType = shapeType
    }
    
    static func defaults() -> ClockOverlaySetting {
        return ClockOverlaySetting.init(shapeType: .Circle)
    }
    
    convenience init( jsonObj: JSON ) {
        var shapeType:OverlayShapeTypes = .Circle
        if (jsonObj["shapeType"] != JSON.null) {
            shapeType = OverlayShapeTypes(rawValue: jsonObj["shapeType"].stringValue)!
        }
        
        self.init(shapeType: shapeType)
    }
    
    func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "shapeType" ] = self.shapeType.rawValue as AnyObject
        
        return serializedDict as NSDictionary
    }
    
    static func descriptionForOverlayShapeType(_ shapeType: OverlayShapeTypes) -> String {
        var typeDescription = ""
        
        if (shapeType == .Circle)  { typeDescription = "Circle" }
        if (shapeType == .Square)  { typeDescription = "Square" }
        if (shapeType == .Snowflake)  { typeDescription = "Snowflake" }
        if (shapeType == .Star)  { typeDescription = "Star" }
        
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
