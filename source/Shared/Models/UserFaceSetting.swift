//
//  UserFaceSetting.swift
//  Clockology
//
//  Created by Mike Hill on 5/4/19.
//  Copyright © 2019 Mike Hill. All rights reserved.
//

import SpriteKit

class UserFaceSetting: NSObject {
    
    static var fileName = "userFaceSettingsV01.json" //change this if significant schema changes are made and users will lose their data, but wont crash.  Otherwise, make migration code
    
    static var sharedFaceSettings = [FaceSetting]()

    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent(fileName)
    
    static func loadFromFile (_ forceLoadDefaults: Bool = false) {
        
//        //load the themes
//        if let path = Bundle.main.path(forResource: "Themes", ofType: "json") {
//            do {
//                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions.mappedIfSafe)
//                let jsonObj = try! JSON(data: data)
//                if jsonObj != JSON.null {
//                    //print("jsonDataThemes:\(jsonObj)")
//
//                    //load up the colors
//                    sharedColorThemeSettings = []
//
//                    let clockColorThemesSerializedArray = jsonObj["colors"].array
//                    for clockThemeSerialized in clockColorThemesSerializedArray! {
//                        //print("got title", clockSettingSerialized["title"])
//                        let newTheme = ClockColorTheme.init(jsonObj: clockThemeSerialized)
//                        sharedColorThemeSettings.append( newTheme )
//                    }
//
//                    //load up the decorators
//                    sharedDecoratorThemeSettings = []
//
//                    let clockDecoratorThemesSerializedArray = jsonObj["decorators"].array
//                    for clockThemeSerialized in clockDecoratorThemesSerializedArray! {
//                        let newTheme = ClockDecoratorTheme.init(jsonObj: clockThemeSerialized)
//                        //print("got decorator title", clockThemeSerialized["title"], "minuteHandMovement ", newTheme.minuteHandMovement)
//                        sharedDecoratorThemeSettings.append( newTheme )
//                    }
//
//                }
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//        }
        
        //clear it out
        sharedFaceSettings = []
        
        //make placeholder serial array
        var faceSettingsSerializedArray = [JSON]()

        let path = self.ArchiveURL.path
        faceSettingsSerializedArray = loadSettingArrayFromSaveFile( path: path)

        //if nothing found / loaded, load defaults
        if (faceSettingsSerializedArray.count==0 || forceLoadDefaults) {
            if let path = Bundle.main.path(forResource: "FaceSettings", ofType: "json") {
                faceSettingsSerializedArray = loadSettingArrayFromSaveFile( path: path)
            }
        }

        //load serialized data into shared clock settings
        for faceSettingSerialized in faceSettingsSerializedArray {
            print("face: got title", faceSettingSerialized["title"])
            let newFaceSetting = FaceSetting.init(jsonObj: faceSettingSerialized)
            debugPrint("n:" + newFaceSetting.title + " " + newFaceSetting.uniqueID)
            sharedFaceSettings.append( newFaceSetting )
        }
    }
    
    static func loadSettingArrayFromSaveFile(path: String) -> [JSON] {
        var clockSettingsSerializedArray = [JSON]()
        do {
            print("loading JSON file path = \(path)")
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions.mappedIfSafe) //Data.init(contentsOf: URL(fileURLWithPath: path))
            let jsonObj = try! JSON(data: jsonData)
            if jsonObj != JSON.null {
                //print("LOADED !!! jsonData:\(jsonObj)")
                clockSettingsSerializedArray = jsonObj["faceSettings"].array!
            } else {
                print("could not get json from file, make sure that file contains valid json.")
            }
        } catch let error as NSError {
            print("error", error.localizedDescription)
        }
        
        return clockSettingsSerializedArray
    }
    
    static func loadSettingArrayFromURL(url: URL) -> [JSON] {
        return loadSettingArrayFromSaveFile(path: url.absoluteString)
    }
    
    static func sharedSettingHasThisClockSetting(uniqueID : String) -> Bool {
//        for clockSetting in sharedClockSettings {
//            if clockSetting.uniqueID == uniqueID { return true }
//        }
        return false
    }
    
    static func addNewFromPath(path: String, importDuplicatesAsNew: Bool) {
        var clockSettingsSerializedArray = [JSON]()
        clockSettingsSerializedArray = loadSettingArrayFromSaveFile( path: path)

        let numOriginalClocks = sharedFaceSettings.count
        //loop thru all settings in defaults, and insert any new ones to our clock settings
        for clockSettingSerialized in clockSettingsSerializedArray {
            //print("got title", clockSettingSerialized["title"])=
            var newClockSetting = FaceSetting.init(jsonObj: clockSettingSerialized)

            if clockSettingSerialized["embeddedImages"] != JSON.null {
            
                if let imagesSerialized = clockSettingSerialized["embeddedImages"].array {
                    for imageJSONObj in imagesSerialized {
                        let filename = imageJSONObj["filename"].stringValue
                        let base64JPGString = imageJSONObj["imageData"].stringValue
                        
                        if let imageData = NSData(base64Encoded: base64JPGString, options: NSData.Base64DecodingOptions.init(rawValue: 0) ) as Data? {
                            let newImageURL = UIImage.getImageURL(imageName: filename)
                            do {
                                try imageData.write(to: newImageURL)
                            }
                            catch {
                                debugPrint("cant write new JPG")
                            }
                            
                            
                        }
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
                sharedFaceSettings.insert(newClockSetting, at: 0)
                //try re-copying the file just in case it was deleted and will be recovered
                if let image = UIImage.init(named: newClockSetting.uniqueID + ".jpg") {
                    _ = image.save(imageName: newClockSetting.uniqueID)
                }
            }
        }

        //if there are new ones, save it
        if sharedFaceSettings.count > numOriginalClocks {
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
        let dictionary = ["faceSettings": serializedArray]
        
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
        for faceSetting in sharedFaceSettings {
            serializedArray.append(faceSetting.serializedSettings() )
            debugPrint("saving setting: ", faceSetting.title)
        }
        let archiveURL = self.ArchiveURL
        saveDictToFile(serializedArray: serializedArray, pathURL: archiveURL)
    }
    
    //return an array of clockSettings that are missing thumbnail images
    static func settingsWithoutThumbNails() -> [FaceSetting] {
        var clockSettingsMissing:[FaceSetting] = []
        for clockSetting in sharedFaceSettings {
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
        
//        var clockThemesMissing:[ClockColorTheme] = []
//        for themeSetting in sharedColorThemeSettings {
//            let fileManager = FileManager.default
//            // check if the image is stored already
//            let url = UIImage.getImageURL(imageName: themeSetting.filename() )
//            if !fileManager.fileExists(atPath: url.path ) {
//                clockThemesMissing.append(themeSetting)
//            }
//        }
//        return clockThemesMissing
        
        return []
    }
    
    
    
//    static func firstColorTheme() -> ClockColorTheme {
//        return sharedColorThemeSettings[0]
//    }
//
//    static func randomColorTheme() -> ClockColorTheme {
//        let randomIndex = Int(arc4random_uniform(UInt32(sharedColorThemeSettings.count)))
//        return sharedColorThemeSettings[randomIndex]
//    }
//
//    static func colorThemesList() -> [String] {
//        var themesArray = [String]()
//
//        for themeSetting in sharedColorThemeSettings {
//            themesArray.append(themeSetting.title)
//        }
//
//        return themesArray
//    }
//
//    static func firstDecoratorTheme() -> ClockDecoratorTheme {
//        return sharedDecoratorThemeSettings[0]
//    }
//
//    static func randomDecoratorTheme() -> ClockDecoratorTheme {
//        let randomIndex = Int(arc4random_uniform(UInt32(sharedDecoratorThemeSettings.count)))
//        return sharedDecoratorThemeSettings[randomIndex]
//    }
//
//    static func decoratorThemesList() -> [String] {
//        var themesArray = [String]()
//
//        for themeSetting in sharedDecoratorThemeSettings {
//            themesArray.append(themeSetting.title)
//        }
//
//        return themesArray
//    }
    

}
