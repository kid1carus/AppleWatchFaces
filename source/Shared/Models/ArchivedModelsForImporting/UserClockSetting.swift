//
//  UserClockSetting.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 12/29/15.
//  Copyright © 2015 Mike Hill. All rights reserved.
//

import SpriteKit

class UserClockSetting: NSObject {
    
    static var fileName = "userClockSettingsV05.json" //change this if significant schema changes are made and users will lose their data, but wont crash.  Otherwise, make migration code
    
    static var sharedClockSettings = [ClockSetting]()
    static var sharedColorThemeSettings = [ClockColorTheme]()
    static var sharedDecoratorThemeSettings = [ClockDecoratorTheme]()

    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent(fileName)
    

    static func importToFaceSettings() -> Int {
        
        var countOfImported = 0
        //var colorIndex = 0
        
        for clockSetting in sharedClockSettings {
            
            func alterLayerForColorOrImage(newFaceSetting: FaceSetting, faceLayer: FaceLayer, materialToTest: String, colorIndex: Int, backgroundType: FaceBackgroundTypes ) {
                
                let layerOptions = ImageBackgroundLayerOptions.init(defaults: true)
                layerOptions.backgroundType = backgroundType
                
                if AppUISettings.materialIsColor(materialName: materialToTest) {
                    faceLayer.layerType = .ColorTexture
                    
                    newFaceSetting.faceColors[colorIndex] = materialToTest
                    faceLayer.desiredThemeColorIndex = colorIndex
                } else {
                    faceLayer.layerType = .ImageTexture
                    
                    layerOptions.filename = materialToTest
                }
                
                faceLayer.layerOptions = layerOptions
            }
            
            let newFaceSetting = FaceSetting.defaults()
            
            //copy in the basics
            newFaceSetting.uniqueID = clockSetting.uniqueID
            newFaceSetting.title = clockSetting.title
            debugPrint("importing: " + clockSetting.title)
            
            let bottomLayerMaterial = clockSetting.clockCasingMaterialName
            let topLayerMaterial = clockSetting.clockFaceMaterialName
            let overlayMaterial = clockSetting.clockForegroundMaterialName
            
            let bottomLayer = FaceLayer.defaults()
            //set layer props
            bottomLayer.alpha = clockSetting.clockCasingMaterialAlpha
            
            alterLayerForColorOrImage(newFaceSetting: newFaceSetting, faceLayer: bottomLayer, materialToTest: bottomLayerMaterial, colorIndex: 0, backgroundType: .FaceBackgroundTypeFilled)
        
            newFaceSetting.faceLayers.append(bottomLayer)
            
            
//            let backgroundNode = FaceBackgroundNode.init(backgroundType: FaceBackgroundTypes.FaceBackgroundTypeFilled , material: bottomLayerMaterial)
//            backgroundNode.name = "background"
//            backgroundNode.zPosition = CGFloat(PartsZPositions.background.rawValue)
//            backgroundNode.alpha = CGFloat(clockSetting.clockCasingMaterialAlpha)
//
//            self.addChild(backgroundNode)

            let middleLayer = FaceLayer.defaults()
            middleLayer.alpha = clockSetting.clockFaceMaterialAlpha
            
            if clockSetting.faceBackgroundType == .FaceBackgroundTypeDiagonalGradient ||
                clockSetting.faceBackgroundType == .FaceBackgroundTypeHorizontalGradient || clockSetting.faceBackgroundType == .FaceBackgroundTypeVerticalGradient {
                
                middleLayer.layerType = .GradientTexture
                
                var layerOptions = GradientBackgroundLayerOptions.init(defaults: true)
                
                switch clockSetting.faceBackgroundType {
                case .FaceBackgroundTypeDiagonalGradient:
                    layerOptions.directionType = .Diagonal
                case .FaceBackgroundTypeVerticalGradient:
                    layerOptions.directionType = .Vertical
                case .FaceBackgroundTypeHorizontalGradient:
                    layerOptions.directionType = .Horizontal
                default:
                    layerOptions.directionType = .Diagonal
                }
                
                middleLayer.desiredThemeColorIndex = 0
                
                newFaceSetting.faceColors[1] = topLayerMaterial
                layerOptions.desiredThemeColorIndexForDestination = 1
                
                middleLayer.layerOptions = layerOptions
            } else {
                alterLayerForColorOrImage(newFaceSetting: newFaceSetting, faceLayer: middleLayer, materialToTest: topLayerMaterial, colorIndex: 1, backgroundType: clockSetting.faceBackgroundType)
            }
            
            newFaceSetting.faceLayers.append(middleLayer)
            
//            let backgroundShapeNode = FaceBackgroundNode.init(backgroundType: clockSetting.faceBackgroundType , material: topLayerMaterial, material2: bottomLayerMaterial)
//            backgroundShapeNode.name = "backgroundShape"
//            backgroundShapeNode.zPosition = CGFloat(PartsZPositions.backgroundShape.rawValue)
//            backgroundShapeNode.alpha = CGFloat(clockSetting.clockFaceMaterialAlpha)
//
//            self.addChild(backgroundShapeNode)
//
//            var shapeType: OverlayShapeTypes = .Circle
//            var itemSize:CGFloat = 0
//            var itemStrength:CGFloat = 0
//            if let clockOverlaySettings = clockSetting.clockOverlaySettings {
//                shapeType = clockOverlaySettings.shapeType
//                itemSize = CGFloat(clockOverlaySettings.itemSize)
//                itemStrength = CGFloat(clockOverlaySettings.itemStrength)
//            }
//
//            let foregroundNode = FaceForegroundNode.init(foregroundType: clockSetting.faceForegroundType, material: overlayMaterial, material2: bottomLayerMaterial, strokeColor: SKColor.clear, lineWidth: 0.0, shapeType: shapeType, itemSize: itemSize, itemStrength: itemStrength)
//            foregroundNode.name = "foregroundNode"
//            foregroundNode.zPosition = CGFloat(PartsZPositions.foreground.rawValue)
//            foregroundNode.alpha = CGFloat(clockSetting.clockForegroundMaterialAlpha)
//
//            self.addChild(foregroundNode)
         
            UserFaceSetting.sharedFaceSettings.append(newFaceSetting)
            countOfImported += 1
        }
        // dont save yet?
        
        return countOfImported // number of things imported
    }
    
    static func loadFromFile (_ forceLoadDefaults: Bool = false) {
        
        //load the themes
        if let path = Bundle.main.path(forResource: "Themes", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions.mappedIfSafe)
                let jsonObj = try! JSON(data: data)
                if jsonObj != JSON.null {
                    //print("jsonDataThemes:\(jsonObj)")
                    
                    //load up the colors
                    sharedColorThemeSettings = []
                    
                    let clockColorThemesSerializedArray = jsonObj["colors"].array
                    for clockThemeSerialized in clockColorThemesSerializedArray! {
                        //print("got title", clockSettingSerialized["title"])
                        let newTheme = ClockColorTheme.init(jsonObj: clockThemeSerialized)
                        sharedColorThemeSettings.append( newTheme )
                    }
                    
                    //load up the decorators
                    sharedDecoratorThemeSettings = []
                    
                    let clockDecoratorThemesSerializedArray = jsonObj["decorators"].array
                    for clockThemeSerialized in clockDecoratorThemesSerializedArray! {
                        let newTheme = ClockDecoratorTheme.init(jsonObj: clockThemeSerialized)
                        //print("got decorator title", clockThemeSerialized["title"], "minuteHandMovement ", newTheme.minuteHandMovement)
                        sharedDecoratorThemeSettings.append( newTheme )
                    }
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        //clear it out
        sharedClockSettings = []
        
        //make placeholder serial array
        var clockSettingsSerializedArray = [JSON]()
        
        let path = self.ArchiveURL.path
        clockSettingsSerializedArray = loadSettingArrayFromSaveFile( path: path)
        
        //if nothing found / loaded, load defaults
        if (clockSettingsSerializedArray.count==0 || forceLoadDefaults) {
            if let path = Bundle.main.path(forResource: "Settings", ofType: "json") {
                clockSettingsSerializedArray = loadSettingArrayFromSaveFile( path: path)
            }
        }
        
        //load serialized data into shared clock settings
        for clockSettingSerialized in clockSettingsSerializedArray {
            //print("got title", clockSettingSerialized["title"])
            let newClockSetting = ClockSetting.init(jsonObj: clockSettingSerialized)
            //debugPrint("n:" + newClockSetting.title + " " + newClockSetting.uniqueID)
            sharedClockSettings.append( newClockSetting )
        }
    }
    
    static func loadSettingArrayFromSaveFile(path: String) -> [JSON] {
        var clockSettingsSerializedArray = [JSON]()
        do {
            print("loading JSON file path = \(path)")
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions.mappedIfSafe)
            let jsonObj = try! JSON(data: jsonData)
            if jsonObj != JSON.null {
                //print("LOADED !!! jsonData:\(jsonObj)")
                clockSettingsSerializedArray = jsonObj["clockSettings"].array!
            } else {
                print("could not get json from file, make sure that file contains valid json.")
            }
        } catch let error as NSError {
            print("error", error.localizedDescription)
        }
        
        return clockSettingsSerializedArray
    }
    
    static func loadSettingArrayFromURL(url: URL) -> [JSON] {
        var clockSettingsSerializedArray = [JSON]()
        do {
            print("loading JSON file path = \(url.absoluteString)")
            let jsonData = try Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
            let jsonObj = try! JSON(data: jsonData)
            if jsonObj != JSON.null {
                //print("LOADED !!! jsonData:\(jsonObj)")
                clockSettingsSerializedArray = jsonObj["clockSettings"].array!
            } else {
                print("could not get json from file, make sure that file contains valid json.")
            }
        } catch let error as NSError {
            print("error", error.localizedDescription)
        }
        
        return clockSettingsSerializedArray
    }
    
    static func sharedSettingHasThisClockSetting(uniqueID : String) -> Bool {
        for clockSetting in sharedClockSettings {
            if clockSetting.uniqueID == uniqueID { return true }
        }
        return false
    }
    
    static func addNewFromPath(path: String, importDuplicatesAsNew: Bool) {
        var clockSettingsSerializedArray = [JSON]()
        clockSettingsSerializedArray = loadSettingArrayFromSaveFile( path: path)
        
        let numOriginalClocks = sharedClockSettings.count
        //loop thru all settings in defaults, and insert any new ones to our clock settings
        for clockSettingSerialized in clockSettingsSerializedArray {
            //print("got title", clockSettingSerialized["title"])
            var newClockSetting = ClockSetting.init(jsonObj: clockSettingSerialized)
            
            if clockSettingSerialized["clockFaceMaterialJPGData"] != JSON.null {
                let base64JPGString = clockSettingSerialized["clockFaceMaterialJPGData"].stringValue
                if let imageData = NSData(base64Encoded: base64JPGString, options: NSData.Base64DecodingOptions.init(rawValue: 0) ) as Data? {
                    let newImageURL = UIImage.getImageURL(imageName: newClockSetting.clockFaceMaterialName)
                    do {
                        try imageData.write(to: newImageURL)
                    }
                    catch {
                        debugPrint("cant write new JPG")
                    }
                }
            }
            
            if (importDuplicatesAsNew && sharedSettingHasThisClockSetting(uniqueID: newClockSetting.uniqueID)) {
                if let clonedSetting = newClockSetting.clone(keepUniqueID: false) {
                    let newTitle = newClockSetting.title + " copy"
                    newClockSetting = clonedSetting
                    newClockSetting.title = newTitle
                }
            }
            
            //if this one already in our list?
            if !sharedSettingHasThisClockSetting(uniqueID: newClockSetting.uniqueID) {
                sharedClockSettings.insert(newClockSetting, at: 0)
                //try re-copying the file just in case it was deleted and will be recovered
                if let image = UIImage.init(named: newClockSetting.uniqueID + ".jpg") {
                    _ = image.save(imageName: newClockSetting.uniqueID)
                }
            }
        }
        
        //if there are new ones, save it
        if sharedClockSettings.count > numOriginalClocks {
            saveToFile()
        }
    }
    
    static func addMissingFromDefaults() {
        guard let path = Bundle.main.path(forResource: "Settings", ofType: "json") else { return }
        addNewFromPath(path: path, importDuplicatesAsNew: false)
    }
    
    static func resetToDefaults() {
        loadFromFile(true)
        saveToFile()
    }

    static func saveDictToFile(serializedArray:[NSDictionary], pathURL: URL) {
        let dictionary = ["clockSettings": serializedArray]
        
        if JSONSerialization.isValidJSONObject(dictionary) {
            do {
                
                let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.prettyPrinted )
                // here "jsonData" is the dictionary encoded in JSON data
                let theJSONText = NSString(data: jsonData, encoding: String.Encoding.ascii.rawValue)
                print("JSON string = \(theJSONText!)")
                
                //save to a file
                let path = pathURL.path
                debugPrint("SAVING: JSON file path = \(path)")
                
                //writing
                do {
                    try theJSONText!.write(toFile: path, atomically: false, encoding: String.Encoding.utf8.rawValue)
                }
                catch let error as NSError {
                    debugPrint("save write file error: ", error.localizedDescription)
                }
                
                
            } catch let error as NSError {
                debugPrint("save JSON serialization error: ", error.localizedDescription)
            }
        } else {
            debugPrint("ERROR: settings cant be coverted to JSON")
        }
    }
    
    static func saveToFile () {
        //JSON save to file
        var serializedArray = [NSDictionary]()
        for clockSetting in sharedClockSettings {
            serializedArray.append(clockSetting.serializedSettings() )
            //debugPrint("saving setting: ", clockSetting.title)
        }
        let archiveURL = self.ArchiveURL
        saveDictToFile(serializedArray: serializedArray, pathURL: archiveURL)
    }
    
    //return an array of clockSettings that are missing thumbnail images
    static func settingsWithoutThumbNails() -> [ClockSetting] {
        var clockSettingsMissing:[ClockSetting] = []
        for clockSetting in sharedClockSettings {
            let fileManager = FileManager.default
            // check if the image is stored already
            let url = UIImage.getImageURL(imageName: clockSetting.uniqueID)
            if !fileManager.fileExists(atPath: url.path ) {
                clockSettingsMissing.append(clockSetting)
            }
        }
        return clockSettingsMissing
    }
    
    //return an array of themes that are missing thumbnail images
    static func themesWithoutThumbNails() -> [ClockColorTheme] {
        var clockThemesMissing:[ClockColorTheme] = []
        for themeSetting in sharedColorThemeSettings {
            let fileManager = FileManager.default
            // check if the image is stored already
            let url = UIImage.getImageURL(imageName: themeSetting.filename() )
            if !fileManager.fileExists(atPath: url.path ) {
                clockThemesMissing.append(themeSetting)
            }
        }
        return clockThemesMissing
    }
    
    
    
    static func firstColorTheme() -> ClockColorTheme {
        return sharedColorThemeSettings[0]
    }
    
    static func randomColorTheme() -> ClockColorTheme {
        let randomIndex = Int(arc4random_uniform(UInt32(sharedColorThemeSettings.count)))
        return sharedColorThemeSettings[randomIndex]
    }
    
    static func colorThemesList() -> [String] {
        var themesArray = [String]()
        
        for themeSetting in sharedColorThemeSettings {
            themesArray.append(themeSetting.title)
        }
        
        return themesArray
    }
    
    static func firstDecoratorTheme() -> ClockDecoratorTheme {
        return sharedDecoratorThemeSettings[0]
    }
    
    static func randomDecoratorTheme() -> ClockDecoratorTheme {
        let randomIndex = Int(arc4random_uniform(UInt32(sharedDecoratorThemeSettings.count)))
        return sharedDecoratorThemeSettings[randomIndex]
    }
    
    static func decoratorThemesList() -> [String] {
        var themesArray = [String]()
        
        for themeSetting in sharedDecoratorThemeSettings {
            themesArray.append(themeSetting.title)
        }
        
        return themesArray
    }
    

}
