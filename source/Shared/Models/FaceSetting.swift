//
//  FaceSetting.swift
//  Clockology
//
//  Created by Mike Hill on 5/4/19.
//  Copyright © 2019 Mike Hill. All rights reserved.
//

//import Cocoa
import SceneKit
import SpriteKit

class FaceSetting: NSObject {
    //model object to hold instances of a clock face settings
    
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
    
    func clone() -> FaceSetting? {
        return clone(keepUniqueID: true)
    }
    
    func clone( keepUniqueID: Bool ) -> FaceSetting? {
        // use JSON to make a new copy (clone it) -- cause, you know , you can!
        
        let settingsDict = self.serializedSettings()
    
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: settingsDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonObj = try! JSON(data: jsonData)
            
            if jsonObj != JSON.null {
                let newSetting = FaceSetting.init(jsonObj: jsonObj)
                
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
    
    var title:String
    var uniqueID:String
    
    var faceLayers: [FaceLayer]
    var faceColors: [String]
    
    init(title: String, uniqueID: String, faceLayers: [FaceLayer], faceColors: [String])
    {
        self.title = title
                
        //create this on init
        self.uniqueID = uniqueID
        
        self.faceLayers = faceLayers
        self.faceColors = faceColors
        
        super.init()
    }
    
    func filename()->String {
        let newName = self.title.components(separatedBy: CharacterSet.alphanumerics.inverted).joined().lowercased()
        return newName
    }
    
    static func defaults() -> FaceSetting {
        return FaceSetting.init(
            title: "Untitled",
            uniqueID: UUID().uuidString,
            faceLayers: [],
            faceColors: ["#FFFFFFFF", "#c6c6c6ff", "#8e8e8eff", "#545454ff", "#1c1c1cff", "#000000ff"]
        )
    }
    
    //init from JSON, ( in from txt files )
    init(jsonObj: JSON ) {
        
        self.title = jsonObj["title"].stringValue
        self.uniqueID = jsonObj["uniqueID"].stringValue
        
        // parse the faceColors
        self.faceColors = [String]()
        
        if let faceColorSerializedArray = jsonObj["faceColors"].array {
            for faceColorSerialized in faceColorSerializedArray {
                faceColors.append( faceColorSerialized.stringValue )
            }
        }
        
        // parse the faceLayers
        self.faceLayers = [FaceLayer]()
        
        if let faceLayersSerializedArray = jsonObj["faceLayers"].array {
            for faceLayerSerialized in faceLayersSerializedArray {
                let newFaceLayer = FaceLayer.init(jsonObj: faceLayerSerialized)
                faceLayers.append( newFaceLayer )
            }
        }
        
        super.init()
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
        
        serializedDict[ "faceColors" ] = self.faceColors as AnyObject
        
        var faceLayersArray = [NSDictionary]()
        for faceLayer in self.faceLayers {
            faceLayersArray.append ( faceLayer.serializedSettings() )
        }
        serializedDict[ "faceLayers" ] = faceLayersArray as AnyObject
        
        return serializedDict as NSDictionary
    }

}
