//
//  ClockFaceSetting.swift
//  AppleWatchFaces
//
//  Created by Mike Hill on 11/12/15.
//  Copyright © 2015 Mike Hill. All rights reserved.
//

//import Cocoa
import SceneKit
import SpriteKit

//model object to hold instances of a clock face settings
class ClockFaceSetting: NSObject {
    
//    func applyDecoratorTheme( _ theme: ClockDecoratorTheme) {
//        self.ringRenderShape = theme.ringRenderShape
//        
//        //set the theme title in case we want to display it in the form
//        self.hourHandType = theme.hourHandType
//        self.minuteHandType = theme.minuteHandType
//        self.secondHandType = theme.secondHandType
//        
//        self.minuteHandMovement = theme.minuteHandMovement
//        self.secondHandMovement = theme.secondHandMovement
//        self.shouldShowRomanNumeralText = theme.shouldShowRomanNumeralText
//        self.shouldShowHandOutlines = theme.shouldShowHandOutlines
//        
//        self.ringSettings = theme.ringSettings
//    }
    
    //NOTE: ANY CHANGES HERE MIGHT NEED TO BE MADE IN DECORATOR THEMES
    
    var minuteHandMaterialName: String
    var secondHandMaterialName: String
    var hourHandMaterialName: String
    var handOutlineMaterialName: String
    
    // types
    var hourHandType:HourHandTypes
    var minuteHandType:MinuteHandTypes
    var secondHandType:SecondHandTypes
    
    //options
    var secondHandMovement:SecondHandMovements
    var minuteHandMovement:MinuteHandMovements
    var shouldShowRomanNumeralText: Bool
    var shouldShowHandOutlines: Bool
    var handEffectWidths: [Float]
    var handAlphas: [Float]
    
    var ringRenderShape: RingRenderShapes
    var ringMaterials: [String]
    var ringAlphas: [Float]
    var ringSettings: [ClockRingSetting]
    
    //tweaks
    
    init(secondHandMaterialName: String,
        hourHandMaterialName: String,
        minuteHandMaterialName: String,
        
        handOutlineMaterialName: String,
        
        hourHandType: HourHandTypes,
        minuteHandType: MinuteHandTypes,
        secondHandType: SecondHandTypes,
        
        minuteHandMovement: MinuteHandMovements,
        secondHandMovement: SecondHandMovements,
        shouldShowRomanNumeralText: Bool,
        shouldShowHandOutlines: Bool,
        handEffectWidths: [Float],
        handAlphas: [Float],
        
        ringRenderShape: RingRenderShapes,
        ringMaterials: [String],
        ringAlphas: [Float],
        ringSettings: [ClockRingSetting]
        )
    {
        self.secondHandMaterialName = secondHandMaterialName
        self.hourHandMaterialName = hourHandMaterialName
        self.minuteHandMaterialName = minuteHandMaterialName
        self.handOutlineMaterialName = handOutlineMaterialName
        
        self.hourHandType = hourHandType
        self.minuteHandType = minuteHandType
        self.secondHandType = secondHandType
    
        self.minuteHandMovement = minuteHandMovement
        self.secondHandMovement = secondHandMovement
        self.shouldShowRomanNumeralText = shouldShowRomanNumeralText
        self.shouldShowHandOutlines = shouldShowHandOutlines
        self.handEffectWidths = handEffectWidths
        self.handAlphas = handAlphas
        
        self.hourHandMaterialName = hourHandMaterialName
        self.minuteHandMaterialName = minuteHandMaterialName
        
        self.ringRenderShape = ringRenderShape
        self.ringMaterials = ringMaterials
        self.ringAlphas = ringAlphas
        self.ringSettings = ringSettings
    
        super.init()
    }

    static func defaults() -> ClockFaceSetting {
        return ClockFaceSetting.init(
            secondHandMaterialName: "#FF0000FF",
            hourHandMaterialName: "#FFFFFFFF",
            minuteHandMaterialName: "#FFFFFFFF",
            handOutlineMaterialName: "#8e8e8eff",
            
            hourHandType: HourHandTypes.HourHandTypeSwiss,
            minuteHandType: MinuteHandTypes.MinuteHandTypeSwiss,
            secondHandType: SecondHandTypes.SecondHandTypeRail,
            
            minuteHandMovement: MinuteHandMovements.MinuteHandMovementStep, //lowest power impact
            secondHandMovement: SecondHandMovements.SecondHandMovementStep, //lowest power impact
            shouldShowRomanNumeralText: false,
            shouldShowHandOutlines: false,
            handEffectWidths: [0,0,0],
            handAlphas: [1,1,1],
            
            ringRenderShape: RingRenderShapes.RingRenderShapeCircle,
            ringMaterials: [ "#FFFFFFFF","#e2e2e2ff","#c6c6c6ff" ],
            ringAlphas: [1,1,1],
            ringSettings: [ ClockRingSetting.defaults() ]
        )
    }
    
    static func random() -> ClockFaceSetting {
        
        return ClockFaceSetting.init(
            secondHandMaterialName: "#FF0000FF",
            hourHandMaterialName: "#000000FF",
            minuteHandMaterialName: "#000000FF",
            handOutlineMaterialName: "#8e8e8eff",
            
            hourHandType: HourHandTypes.HourHandTypeSwiss,
            minuteHandType: MinuteHandTypes.MinuteHandTypeSwiss,
            secondHandType: SecondHandTypes.random(),
            
            minuteHandMovement: MinuteHandMovements.random(),
            secondHandMovement: SecondHandMovements.random(),
            shouldShowRomanNumeralText: false,
            shouldShowHandOutlines: false,
            handEffectWidths: [0,0,0],
            handAlphas: [1,1,1],
        
            ringRenderShape: RingRenderShapes.RingRenderShapeCircle,
            ringMaterials: [ "#FFFFFFFF","#e2e2e2ff","#c6c6c6ff" ],
            ringAlphas: [1,1,1],
            ringSettings: [ ClockRingSetting.defaults() ]
        )
    }
    
    //init from serialized
    convenience init( jsonObj: JSON ) {
        
        //print("minuteTextType", jsonObj["minuteTextType"].stringValue)
        
        // parse the ringSettings
        var ringSettings = [ClockRingSetting]()
        
        if let ringSettingsSerializedArray = jsonObj["ringSettings"].array {
            for ringSettingSerialized in ringSettingsSerializedArray {
                let newRingSetting = ClockRingSetting.init(jsonObj: ringSettingSerialized)
                ringSettings.append( newRingSetting )
                }
        }
        
        var handEffectWidthsTemp = [Float]()
        if let handEffectWidthsdSerializedArray = jsonObj["handEffectWidths"].array {
            for handEffectWidthsdSerialized in handEffectWidthsdSerializedArray {
                handEffectWidthsTemp.append( handEffectWidthsdSerialized.floatValue )
            }
        }
        
        var handAlphasTemp = [Float]()
        if let handAlphasSerializedArray = jsonObj["handAlphas"].array {
            for handAlphasSerialized in handAlphasSerializedArray {
                handAlphasTemp.append( handAlphasSerialized.floatValue )
            }
        }
        
        var ringMaterialsTemp = [String]()
        if let ringMaterialsSerializedArray = jsonObj["ringMaterials"].array {
            for ringMaterialsSerialized in ringMaterialsSerializedArray {
                ringMaterialsTemp.append( ringMaterialsSerialized.stringValue )
            }
        }
        
        var ringAlphasTemp = [Float]()
        if let ringAlphasSerializedArray = jsonObj["ringAlphas"].array {
            for ringAlphasSerialized in ringAlphasSerializedArray {
                ringAlphasTemp.append( ringAlphasSerialized.floatValue )
            }
        }
        var minuteHandMovement = MinuteHandMovements.MinuteHandMovementStep
        if (jsonObj["minuteHandMovement"] != JSON.null) {
            minuteHandMovement = MinuteHandMovements(rawValue: jsonObj["minuteHandMovement"].stringValue)!
        }
        
        var ringRenderShape = RingRenderShapes.RingRenderShapeCircle
        if (jsonObj["ringRenderShape"] != JSON.null) {
            ringRenderShape = RingRenderShapes(rawValue: jsonObj["ringRenderShape"].stringValue)!
        }
        
        self.init(
            secondHandMaterialName: jsonObj["secondHandMaterialName"].stringValue,
            hourHandMaterialName: jsonObj["hourHandMaterialName"].stringValue,
            minuteHandMaterialName: jsonObj["minuteHandMaterialName"].stringValue,
            handOutlineMaterialName: jsonObj["handOutlineMaterialName"].stringValue,
            
            hourHandType: HourHandTypes(rawValue: jsonObj["hourHandType"].stringValue)!,
            minuteHandType: MinuteHandTypes(rawValue: jsonObj["minuteHandType"].stringValue)!,
            secondHandType: SecondHandTypes(rawValue: jsonObj["secondHandType"].stringValue)!,
            
            minuteHandMovement: minuteHandMovement,
            secondHandMovement: SecondHandMovements(rawValue: jsonObj["secondHandMovement"].stringValue)!,
            shouldShowRomanNumeralText: jsonObj[ "shouldShowRomanNumeralText" ].boolValue ,
            shouldShowHandOutlines: jsonObj[ "shouldShowHandOutlines" ].boolValue ,
            handEffectWidths: handEffectWidthsTemp,
            handAlphas: handAlphasTemp,
            
            ringRenderShape: ringRenderShape,
            ringMaterials : ringMaterialsTemp,
            ringAlphas: ringAlphasTemp,
            ringSettings : ringSettings
        )
    }
    
    func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "secondHandMaterialName" ] = self.secondHandMaterialName as AnyObject
        serializedDict[ "hourHandMaterialName" ] = self.hourHandMaterialName as AnyObject
        serializedDict[ "minuteHandMaterialName" ] = self.minuteHandMaterialName as AnyObject
        serializedDict[ "handOutlineMaterialName" ] = self.handOutlineMaterialName as AnyObject
    
        serializedDict[ "hourHandType" ] = self.hourHandType.rawValue as AnyObject
        serializedDict[ "minuteHandType" ] = self.minuteHandType.rawValue as AnyObject
        serializedDict[ "secondHandType" ] = self.secondHandType.rawValue as AnyObject
        
        serializedDict[ "minuteHandMovement" ] = self.minuteHandMovement.rawValue as AnyObject
        serializedDict[ "secondHandMovement" ] = self.secondHandMovement.rawValue as AnyObject
        serializedDict[ "shouldShowRomanNumeralText" ] = NSNumber.init(value: self.shouldShowRomanNumeralText as Bool)
        serializedDict[ "shouldShowHandOutlines" ] = NSNumber.init(value: self.shouldShowHandOutlines as Bool)
        
        //only add this if its not default
        if self.handEffectWidths != [0,0,0] {
            serializedDict[ "handEffectWidths" ] = self.handEffectWidths as AnyObject
        }
        
        //only add this if its not default
        if self.handAlphas != [1,1,1] {
            serializedDict[ "handAlphas" ] = self.handAlphas as AnyObject
        }
        
        serializedDict[ "ringRenderShape" ] = self.ringRenderShape.rawValue as AnyObject
        serializedDict[ "ringMaterials" ] = self.ringMaterials as AnyObject

        //only add this if its not default
        if self.ringAlphas != [1,1,1] {
            serializedDict[ "ringAlphas" ] = self.ringAlphas as AnyObject
        }
        
        var ringSettingsArray = [NSDictionary]()
        for ringSetting in self.ringSettings {
            ringSettingsArray.append ( ringSetting.serializedSettings() )
        }
        serializedDict[ "ringSettings" ] = ringSettingsArray as AnyObject
        
        return serializedDict as NSDictionary
    }

}
