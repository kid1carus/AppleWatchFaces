//
//  FaceLayer.swift
//  Clockology
//
//  Created by Mike Hill on 5/4/19.
//  Copyright © 2019 Mike Hill. All rights reserved.
//

//import Cocoa
import SpriteKit

enum FaceLayerTypes: String {
    case SecondHand,
    MinuteHand,
    HourHand,
    ImageTexture,
    ColorTexture,
    GradientTexture,
    ParticleField,
    DateTimeLabel,
    ShapeRing,
    NumberRing
    
    static let userSelectableValues = [
        SecondHand, MinuteHand, HourHand, ImageTexture, ColorTexture, GradientTexture, DateTimeLabel, ShapeRing, NumberRing, ParticleField]
}

class FaceLayerOptions: NSObject {
    //will be subclassed for each type
    func serializedSettings() -> NSDictionary {
        return [String:AnyObject]() as NSDictionary
    }
}

class FaceLayer: NSObject {
    // stuff that applies to all layers

    var layerType: FaceLayerTypes = .SecondHand
    var alpha: Float = 1.0
    var horizontalPosition: Float = 0
    var verticalPosition: Float = 0
    var scale: Float = 1.0
    var angleOffset: Float = 0
    
    var filenameForImage: String = ""
    var desiredThemeColorIndex: Int = 0
    
    // specific to each layer by type
    var layerOptions: FaceLayerOptions

    init(layerType: FaceLayerTypes, alpha: Float, horizontalPosition: Float, verticalPosition: Float, scale: Float, angleOffset: Float,
         desiredThemeColorIndex: Int, layerOptions: FaceLayerOptions, filenameForImage: String) {
        self.layerType = layerType
        self.alpha = alpha
        self.horizontalPosition = horizontalPosition
        self.verticalPosition = verticalPosition
        self.scale = scale
        self.angleOffset = angleOffset
        
        self.desiredThemeColorIndex = desiredThemeColorIndex
        self.layerOptions = layerOptions
        
        self.filenameForImage = filenameForImage
    
        super.init()
    }
    
    static func defaults() -> FaceLayer {
        return FaceLayer.init( layerType: .SecondHand, alpha: 1.0 , horizontalPosition: 0, verticalPosition: 0, scale: 1.0, angleOffset: 0,
                               desiredThemeColorIndex: 0, layerOptions: FaceLayerOptions(), filenameForImage: "" )
    }
    
    //init from JSON, ( in from txt files )
    init(jsonObj: JSON ) {
        let layerTypeString = jsonObj["layerType"].stringValue
        self.layerType = FaceLayerTypes(rawValue: layerTypeString)!
        self.alpha = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 1.0, key: "alpha")
        
        self.horizontalPosition = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0, key: "horizontalPosition")
        self.verticalPosition = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 0, key: "verticalPosition")
        self.scale = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 1.0, key: "scale")
        self.angleOffset = NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 1.0, key: "angleOffset")
        
        self.desiredThemeColorIndex = NSObject.intValueForJSONObj(jsonObj: jsonObj, defaultVal: 0, key: "desiredThemeColorIndex")
        
        self.filenameForImage = NSObject.stringValueForJSONObj(jsonObj: jsonObj, defaultVal: "", key: "filenameForImage")
        
        //init layerOptions depending on type
        self.layerOptions = FaceLayerOptions()
        
        switch self.layerType {
        case .ShapeRing:
            self.layerOptions = ShapeLayerOptions.init(jsonObj: jsonObj["layerOptions"])
        case .NumberRing:
            self.layerOptions = NumberRingLayerOptions.init(jsonObj: jsonObj["layerOptions"])
        case .DateTimeLabel:
            self.layerOptions = DigitalTimeLayerOptions.init(jsonObj: jsonObj["layerOptions"])
        case .GradientTexture:
            self.layerOptions = GradientBackgroundLayerOptions.init(jsonObj: jsonObj["layerOptions"])
        case .SecondHand:
            self.layerOptions = SecondHandLayerOptions.init(jsonObj: jsonObj["layerOptions"])
        case .MinuteHand:
            self.layerOptions = MinuteHandLayerOptions.init(jsonObj: jsonObj["layerOptions"])
        case .HourHand:
            self.layerOptions = HourHandLayerOptions.init(jsonObj: jsonObj["layerOptions"])
        case .ImageTexture:
            self.layerOptions = ImageBackgroundLayerOptions.init(jsonObj: jsonObj["layerOptions"])
        case .ColorTexture:
            self.layerOptions = ImageBackgroundLayerOptions.init(jsonObj: jsonObj["layerOptions"])
        case .ParticleField:
            self.layerOptions = ParticleFieldLayerOptions.init(jsonObj: jsonObj["layerOptions"])
        //default:
        //    self.layerOptions = FaceLayerOptions()
        }
        
        super.init()
    }
    
    //out to serialized . text files
    func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()

        serializedDict[ "layerType" ] = self.layerType.rawValue as AnyObject
        serializedDict[ "alpha" ] = self.alpha.description as AnyObject
        
        serializedDict[ "horizontalPosition" ] = self.horizontalPosition.description as AnyObject
        serializedDict[ "verticalPosition" ] = self.verticalPosition.description as AnyObject
        serializedDict[ "scale" ] = self.scale.description as AnyObject
        serializedDict[ "angleOffset" ] = self.angleOffset.description as AnyObject
        
        serializedDict[ "desiredThemeColorIndex" ] = self.desiredThemeColorIndex as AnyObject
        
        serializedDict[ "layerOptions" ] = self.layerOptions.serializedSettings()
        
        serializedDict[ "filenameForImage" ] = self.filenameForImage as AnyObject

        return serializedDict as NSDictionary
    }
    
    static func descriptionForType(_ layerType: FaceLayerTypes) -> String {
        var typeDescription = ""
        
        if (layerType == .SecondHand)  { typeDescription = "Second Hand" }
        if (layerType == .MinuteHand)  { typeDescription = "Minute Hand" }
        if (layerType == .HourHand)  { typeDescription = "Hour Hand" }
        
        if (layerType == .DateTimeLabel) { typeDescription = "Digital/Time Label"}
        
        if (layerType == .NumberRing)  { typeDescription = "Number Ring" }
        if (layerType == .ShapeRing)  { typeDescription = "Shape Ring" }
        
        if (layerType == .ImageTexture)  { typeDescription = "Image Texture" }
        if (layerType == .ColorTexture)  { typeDescription = "Color Texture" }
        if (layerType == .GradientTexture)  { typeDescription = "Gradient Texture" }
        
        if (layerType == .ParticleField)  { typeDescription = "Particle Field" }
        
        return typeDescription
    }
}
