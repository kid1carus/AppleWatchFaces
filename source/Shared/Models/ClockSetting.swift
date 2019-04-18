//
//  ClockSetting.swift
//  AppleWatchFaces
//
//  Created by Mike Hill on 11/12/15.
//  Copyright © 2015 Mike Hill. All rights reserved.
//

//import Cocoa
import SceneKit
import SpriteKit

class ClockSetting: NSObject {
    //model object to hold instances of a clock settings
    
    func applyColorTheme( _ theme: ClockColorTheme) {
        print("using color theme: ", theme.title)
        //set the theme title in case we want to display it in the form
        self.themeTitle = theme.title
        
        //take the them and apply it
        self.clockFaceMaterialName = theme.clockFaceMaterialName
        self.clockCasingMaterialName = theme.clockCasingMaterialName
        
        self.clockFaceSettings?.hourHandMaterialName = theme.hourHandMaterialName
        self.clockFaceSettings?.minuteHandMaterialName = theme.minuteHandMaterialName
        self.clockFaceSettings?.secondHandMaterialName = theme.secondHandMaterialName
        
        self.clockFaceSettings?.ringMaterials = theme.ringMaterials
    }
    
    func applyDecoratorTheme ( _ theme: ClockDecoratorTheme ) {
        print("using face theme: ", theme.title)
        self.decoratorThemeTitle = theme.title
        self.faceBackgroundType = theme.faceBackgroundType
        
        self.clockFaceSettings?.applyDecoratorTheme( theme )
    }
    
    func toJSONData() -> Data? {
        let settingsDict = self.serializedSettings()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: settingsDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            return jsonData
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    func toJSON() -> JSON? {
        let settingsDict = self.serializedSettings()
        //let settingsData = NSKeyedArchiver.archivedDataWithRootObject(settingsDict)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: settingsDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonObj = try! JSON(data: jsonData)
            return jsonObj
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    func clone() -> ClockSetting? {
        return clone(keepUniqueID: true)
    }
    
    func clone( keepUniqueID: Bool ) -> ClockSetting? {
        // use JSON to clone it cause, you know , you can!
        
        let settingsDict = self.serializedSettings()
        //let settingsData = NSKeyedArchiver.archivedDataWithRootObject(settingsDict)
    
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: settingsDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonObj = try! JSON(data: jsonData)
            
            if jsonObj != JSON.null {
                let newSetting = ClockSetting.init(jsonObj: jsonObj)
                
                if !keepUniqueID {
                    //re-assing the uid
                    newSetting.uniqueID = UUID().uuidString
                }
                return newSetting
            } else {
                print("could not get json from clone, make sure that contains valid json.")
            }
        } catch let error as NSError {
            print(error)
        }
        
        print("could not get json from clone, make sure that contains valid json.")
        return nil
    }
    
    // background types
    var faceBackgroundType:FaceBackgroundTypes
    var faceForegroundType:FaceForegroundTypes
    
    // overlay settings
    var clockOverlaySettings:ClockOverlaySetting?
    
    // face settings
    var clockFaceSettings:ClockFaceSetting?
    
    var title:String
    var themeTitle:String
    var decoratorThemeTitle:String
    
    var clockFaceMaterialName:String
    var clockCasingMaterialName:String
    var clockForegroundMaterialName:String
    
    var clockFaceMaterialAlpha:Float = 1.0
    var clockCasingMaterialAlpha:Float = 1.0
    var clockForegroundMaterialAlpha:Float = 1.0
    
    var uniqueID:String
    
    init(clockFaceMaterialName: String,
        faceBackgroundType: FaceBackgroundTypes,
        faceForegroundType: FaceForegroundTypes,
        
        clockCasingMaterialName: String,
        clockForegroundMaterialName: String,
        
        clockFaceMaterialAlpha:Float,
        clockCasingMaterialAlpha:Float,
        clockForegroundMaterialAlpha:Float,
        
        clockOverlaySettings: ClockOverlaySetting,
        clockFaceSettings: ClockFaceSetting,
        title: String,
        uniqueID: String)
    {
        self.faceBackgroundType = faceBackgroundType
        self.faceForegroundType = faceForegroundType
        self.clockOverlaySettings = clockOverlaySettings
        self.clockFaceSettings = clockFaceSettings
        self.title = title
        
        self.clockFaceMaterialName = clockFaceMaterialName
        self.clockCasingMaterialName = clockCasingMaterialName
        self.clockForegroundMaterialName = clockForegroundMaterialName
        
        self.clockFaceMaterialAlpha = clockFaceMaterialAlpha
        self.clockCasingMaterialAlpha = clockCasingMaterialAlpha
        self.clockForegroundMaterialAlpha = clockForegroundMaterialAlpha
        
        
        self.themeTitle = ""
        self.decoratorThemeTitle = ""
        
        //create this on init
        self.uniqueID = uniqueID
        
        super.init()
    }
    
    func filename()->String {
        let newName = self.title.components(separatedBy: CharacterSet.alphanumerics.inverted).joined().lowercased()
        return newName
    }
    
    static func defaults() -> ClockSetting {
        return ClockSetting.init(
            clockFaceMaterialName: "#000000FF",
            faceBackgroundType: FaceBackgroundTypes.FaceBackgroundTypeFilled,
            faceForegroundType: FaceForegroundTypes.None,
            
            clockCasingMaterialName: "#1c1c1cff",
            clockForegroundMaterialName: "",
            
            clockFaceMaterialAlpha: 1.0,
            clockCasingMaterialAlpha: 1.0,
            clockForegroundMaterialAlpha: 1.0,
            
            clockOverlaySettings: ClockOverlaySetting.defaults(),
            clockFaceSettings: ClockFaceSetting.defaults(),
            title: "Untitled"
        )
    }
    
    func randomize( newColors: Bool, newBackground: Bool, newFace: Bool ) {
        if (newBackground) {
            self.faceBackgroundType = FaceBackgroundTypes.random()
        }
        if (newFace) {
            self.applyDecoratorTheme(UserClockSetting.randomDecoratorTheme())
        }
        if (newColors) {
            self.applyColorTheme(UserClockSetting.randomColorTheme())
        }
    
        //self.setTitleForRandomClock()
    }
    
    static func random() -> ClockSetting {

        let faceBackgroundType = FaceBackgroundTypes.random()
        let clockSetting = ClockSetting.init(
            clockFaceMaterialName: "#FFFFFFFF",
            faceBackgroundType: faceBackgroundType,
            faceForegroundType: .None,

            clockCasingMaterialName: "#FF0000FF",
            clockForegroundMaterialName: "",
            
            clockFaceMaterialAlpha: 1.0,
            clockCasingMaterialAlpha: 1.0,
            clockForegroundMaterialAlpha: 1.0,

            clockOverlaySettings: ClockOverlaySetting.defaults(),
            clockFaceSettings: ClockFaceSetting.random(),
            title: "random"
        )

        //add a random theme
        let randoDecoTheme = UserClockSetting.randomDecoratorTheme() //UserClockSetting.sharedDecoratorThemeSettings[1]
        clockSetting.applyDecoratorTheme(randoDecoTheme)

        //add a random theme
        let randoTheme =  UserClockSetting.randomColorTheme() //UserClockSetting.sharedColorThemeSettings[0]
        clockSetting.applyColorTheme(randoTheme)

        clockSetting.setTitleForRandomClock()

        return clockSetting
    }
    
    //no uniqueID ( generate one )
    convenience init(clockFaceMaterialName: String,
                     faceBackgroundType: FaceBackgroundTypes,
                     faceForegroundType: FaceForegroundTypes,
                     clockCasingMaterialName: String,
                     clockForegroundMaterialName: String,
                     
                     clockFaceMaterialAlpha:Float,
                     clockCasingMaterialAlpha:Float,
                     clockForegroundMaterialAlpha:Float,
                     
                     clockOverlaySettings: ClockOverlaySetting,
                     clockFaceSettings: ClockFaceSetting,
                     title: String) {
        
        self.init(clockFaceMaterialName: clockFaceMaterialName,
                  faceBackgroundType: faceBackgroundType,
                  faceForegroundType: faceForegroundType,
                  clockCasingMaterialName: clockCasingMaterialName,
                  clockForegroundMaterialName: clockForegroundMaterialName,
                  
                  clockFaceMaterialAlpha:clockFaceMaterialAlpha,
                  clockCasingMaterialAlpha:clockCasingMaterialAlpha,
                  clockForegroundMaterialAlpha:clockForegroundMaterialAlpha,
                  
                  clockOverlaySettings: clockOverlaySettings,
                  clockFaceSettings: clockFaceSettings,
                  title: title ,
                  uniqueID: UUID().uuidString)
    }
    
    //init from serialized
    convenience init( jsonObj: JSON ) {
        
        var faceForegroundTypeTmp:FaceForegroundTypes = .None
        var faceBackgroundTypeTmp:FaceBackgroundTypes = FaceBackgroundTypes.FaceBackgroundTypeNone
        
        let faceForegroundTypeString = jsonObj["faceForegroundType"].stringValue
        if let faceForegroundTypeFound = FaceForegroundTypes(rawValue: faceForegroundTypeString) {
            
            //import old (messy) types into new ones, moved into overlay settings
            if (faceForegroundTypeString == "FaceIndicatorTypeAnimatedPhysicsFieldSmall" || faceForegroundTypeString == "FaceIndicatorTypeAnimatedPhysicsFieldLarge") {
                faceForegroundTypeTmp = .AnimatedPhysicsField
            } else {
                faceForegroundTypeTmp = faceForegroundTypeFound
            }
        }
                    
        let faceBackgroundTypeString = jsonObj["faceBackgroundType"].stringValue
        if let faceBackgroundTypeFound = FaceBackgroundTypes(rawValue: faceBackgroundTypeString) {
            faceBackgroundTypeTmp = faceBackgroundTypeFound
        } else {
            //import old (messy) types into foreground
            switch faceBackgroundTypeString {
            case "FaceIndicatorTypeAnimatedPhysicsField":
                faceForegroundTypeTmp = .AnimatedPhysicsField
            case "FaceIndicatorTypeAnimatedPhysicsFieldSmall":
                faceForegroundTypeTmp = .AnimatedPhysicsField
            case "FaceIndicatorTypeAnimatedPhysicsFieldLarge":
                faceForegroundTypeTmp = .AnimatedPhysicsField
            case "FaceBackgroundTypeAnimatedPong":
                faceForegroundTypeTmp = .AnimatedPong
            case "FaceIndicatorTypeAnimatedSnowField":
                faceForegroundTypeTmp = .AnimatedSnowField
            case "FaceIndicatorTypeAnimatedStarField":
                faceForegroundTypeTmp = .AnimatedStarField
            default:
                faceForegroundTypeTmp = .None
            }
        }
        
        self.init(
            clockFaceMaterialName: jsonObj["clockFaceMaterialName"].stringValue,
            faceBackgroundType: faceBackgroundTypeTmp,
            faceForegroundType: faceForegroundTypeTmp,
            
            clockCasingMaterialName: jsonObj["clockCasingMaterialName"].stringValue,
            clockForegroundMaterialName: jsonObj["clockForegroundMaterialName"].stringValue,
            
            clockFaceMaterialAlpha: NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 1.0, key: "clockFaceMaterialAlpha"),
            clockCasingMaterialAlpha: NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 1.0, key: "clockCasingMaterialAlpha"),
            clockForegroundMaterialAlpha: NSObject.floatValueForJSONObj(jsonObj: jsonObj, defaultVal: 1.0, key: "clockForegroundMaterialAlpha"),
            
            clockOverlaySettings: ClockOverlaySetting.init(jsonObj: jsonObj["clockOverlaySettings"]),
            clockFaceSettings: ClockFaceSetting.init(jsonObj: jsonObj["clockFaceSettings"]),
            title: jsonObj["title"].stringValue,
            uniqueID: jsonObj["uniqueID"].stringValue
        )
    
    }
    
    func setTitleForRandomClock() {
        self.title = "randomClock-" + String.random(20)
    }
    
    //returns a JSON serializable safe version ( 
    
    /*
    - Top level object is an NSArray or NSDictionary
    - All objects are NSString, NSNumber, NSArray, NSDictionary, or NSNull
    - All dictionary keys are NSStrings
    */
    
    //floats to a string (description) feels safest since we have cross platform floats w/ NSNumber to worry about

    func serializedSettings() -> NSDictionary {
        var serializedDict = [String:AnyObject]()
        
        serializedDict[ "title" ] = self.title as AnyObject
        serializedDict[ "uniqueID" ] = self.uniqueID as AnyObject
        serializedDict[ "clockFaceMaterialName" ] = self.clockFaceMaterialName as AnyObject
        serializedDict[ "faceBackgroundType" ] = self.faceBackgroundType.rawValue as AnyObject
        serializedDict[ "faceForegroundType" ] = self.faceForegroundType.rawValue as AnyObject
        
        //only add this if it applies
        if self.faceForegroundType != .None {
            serializedDict[ "clockOverlaySettings" ] = self.clockOverlaySettings!.serializedSettings()
        }
        serializedDict[ "clockFaceSettings" ] = self.clockFaceSettings!.serializedSettings()
        
        serializedDict[ "clockCasingMaterialName" ] = self.clockCasingMaterialName as AnyObject
        serializedDict[ "clockForegroundMaterialName" ] = self.clockForegroundMaterialName as AnyObject
        
        if self.clockFaceMaterialAlpha != 1.0 {
            serializedDict[ "clockFaceMaterialAlpha" ] = self.clockFaceMaterialAlpha.description as AnyObject
        }
        if self.clockCasingMaterialAlpha != 1.0 {
            serializedDict[ "clockCasingMaterialAlpha" ] = self.clockCasingMaterialAlpha.description as AnyObject
        }
        if self.clockForegroundMaterialAlpha != 1.0 {
            serializedDict[ "clockForegroundMaterialAlpha" ] = self.clockForegroundMaterialAlpha.description as AnyObject
        }
        
        return serializedDict as NSDictionary
    }

}
