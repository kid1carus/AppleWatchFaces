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
        for clockSetting in sharedClockSettings {
            guard let clockFaceSettings = clockSetting.clockFaceSettings else { continue }
            
            func getIndexForMaterial(newFaceSetting: FaceSetting, materialToTest: String ) -> Int {
                
                if let index = newFaceSetting.faceColors.index(of: materialToTest) {
                    return index
                } else {
                    newFaceSetting.faceColors.append(materialToTest)
                }
                
                return newFaceSetting.faceColors.count-1
            }
            
            func alterLayerForColorOrImage(newFaceSetting: FaceSetting, faceLayer: FaceLayer, materialToTest: String, backgroundType: FaceBackgroundTypes ) {
                
                let layerOptions = ImageBackgroundLayerOptions.init(defaults: true)
                layerOptions.backgroundType = backgroundType
                
                if AppUISettings.materialIsColor(materialName: materialToTest) {
                    faceLayer.layerType = .ColorTexture
       
                    faceLayer.desiredThemeColorIndex = getIndexForMaterial(newFaceSetting: newFaceSetting, materialToTest: materialToTest)
                } else {
                    faceLayer.layerType = .ImageTexture
                    
                    layerOptions.filename = materialToTest
                }
                
                faceLayer.layerOptions = layerOptions
            }
            
            let newFaceSetting = FaceSetting.defaults()
            
            //empty out all the colors
            newFaceSetting.faceColors = []
            
            //copy in the basics
            newFaceSetting.uniqueID = clockSetting.uniqueID
            newFaceSetting.title = clockSetting.title
            debugPrint("importing: " + clockSetting.title)
            
            //BOTTOM BG LAYER
            let bottomLayerMaterial = clockSetting.clockCasingMaterialName
            let topLayerMaterial = clockSetting.clockFaceMaterialName
            let overlayMaterial = clockSetting.clockForegroundMaterialName
            
            let bottomLayer = FaceLayer.defaults()
            //set layer props
            bottomLayer.alpha = clockSetting.clockCasingMaterialAlpha
            
            alterLayerForColorOrImage(newFaceSetting: newFaceSetting, faceLayer: bottomLayer, materialToTest: bottomLayerMaterial, backgroundType: .FaceBackgroundTypeFilled)
    
            newFaceSetting.faceLayers.append(bottomLayer)
    
            //MIDDLE BG LAYER
            let middleLayer = FaceLayer.defaults()
            middleLayer.alpha = clockSetting.clockFaceMaterialAlpha
            
            if clockSetting.faceBackgroundType == .FaceBackgroundTypeDiagonalGradient ||
                clockSetting.faceBackgroundType == .FaceBackgroundTypeHorizontalGradient || clockSetting.faceBackgroundType == .FaceBackgroundTypeVerticalGradient {
                
                middleLayer.layerType = .GradientTexture
                
                let layerOptions = GradientBackgroundLayerOptions.init(defaults: true)
                
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
                
                layerOptions.desiredThemeColorIndexForDestination = getIndexForMaterial(newFaceSetting: newFaceSetting, materialToTest: topLayerMaterial)
                
                middleLayer.layerOptions = layerOptions
            } else {
                alterLayerForColorOrImage(newFaceSetting: newFaceSetting, faceLayer: middleLayer, materialToTest: topLayerMaterial, backgroundType: clockSetting.faceBackgroundType)
            }
            
            if clockSetting.faceBackgroundType != .FaceBackgroundTypeNone {
                newFaceSetting.faceLayers.append(middleLayer)
            }
        
            //FIELD BG LAYER
            if clockSetting.faceForegroundType != .None {
            
                let fieldLayer = FaceLayer.defaults()
                fieldLayer.alpha = clockSetting.clockForegroundMaterialAlpha
                fieldLayer.layerType = .ParticleField
            
                let layerOptions = ParticleFieldLayerOptions.init(defaults: true)
                layerOptions.nodeType = clockSetting.faceForegroundType

                if let clockOverlaySettings = clockSetting.clockOverlaySettings {
                    layerOptions.shapeType = clockOverlaySettings.shapeType
                    layerOptions.itemSize = clockOverlaySettings.itemSize
                }

                fieldLayer.desiredThemeColorIndex = getIndexForMaterial(newFaceSetting: newFaceSetting, materialToTest: overlayMaterial)
                fieldLayer.layerOptions = layerOptions

                newFaceSetting.faceLayers.append(fieldLayer)
            }
                        
            //RING SETTINGS LOOP
            var currentDistance = Float(1.0)
            
            for ringSetting in clockFaceSettings.ringSettings {
                
                //grab material
                var material = ""
                let desiredMaterialIndex = ringSetting.ringMaterialDesiredThemeColorIndex
                if (desiredMaterialIndex<=clockFaceSettings.ringMaterials.count-1) {
                    material = clockFaceSettings.ringMaterials[desiredMaterialIndex]
                } else {
                    material = clockFaceSettings.ringMaterials[clockFaceSettings.ringMaterials.count-1]
                }
                
                let layerDesiredColorIndex = getIndexForMaterial(newFaceSetting: newFaceSetting, materialToTest: material)
                let scale = currentDistance * 1.3 // TODO: whats this magic number?
                
                if ringSetting.ringType == .RingTypeShapeNode {

                    let shapeLayerOptions = ShapeLayerOptions.init(defaults: true)
                    shapeLayerOptions.indicatorSize = ringSetting.indicatorSize / scale
                    shapeLayerOptions.indicatorType = ringSetting.indicatorType
                    shapeLayerOptions.pathShape = clockFaceSettings.ringRenderShape
                    shapeLayerOptions.patternArray = ringSetting.ringPattern
                    shapeLayerOptions.patternTotal = ringSetting.ringPatternTotal
                    
                    //TODO: figure out ring alpha
                    
                    let newRingLayer = FaceLayer.init(layerType: FaceLayerTypes.ShapeRing, alpha: 1.0, horizontalPosition: 0, verticalPosition: 0, scale: scale, angleOffset: 0, desiredThemeColorIndex: layerDesiredColorIndex, layerOptions: shapeLayerOptions, filenameForImage: "")
                    newFaceSetting.faceLayers.append(newRingLayer)
                }
                if ringSetting.ringType == .RingTypeTextNode || ringSetting.ringType == .RingTypeTextRotatingNode {
                    
                    let shapeLayerOptions = NumberRingLayerOptions.init(defaults: true)
                    shapeLayerOptions.textSize = ringSetting.textSize / scale
                    shapeLayerOptions.fontType = ringSetting.textType
                    shapeLayerOptions.pathShape = clockFaceSettings.ringRenderShape
                    shapeLayerOptions.patternArray = ringSetting.ringPattern
                    shapeLayerOptions.patternTotal = ringSetting.ringPatternTotal
                    if ringSetting.ringType == .RingTypeTextRotatingNode {
                        shapeLayerOptions.isRotating = true
                    }
                    
                    //TODO: figure out ring alpha
                    
                    let newRingLayer = FaceLayer.init(layerType: FaceLayerTypes.NumberRing, alpha: 1.0, horizontalPosition: 0, verticalPosition: 0, scale: scale, angleOffset: 0, desiredThemeColorIndex: layerDesiredColorIndex, layerOptions: shapeLayerOptions, filenameForImage: "")
                    newFaceSetting.faceLayers.append(newRingLayer)
                }
                if ringSetting.ringType == .RingTypeDigitalTime {
                    
                    let magicSize = CGSize.init(width: 105, height: 130) //translation in view
                    
                    func positionInViewForRingItem( ringSettings: ClockRingSetting) -> CGPoint {
                        //debugPrint("setting pos h:" + ringSettings.ringStaticHorizontalPositionNumeric.description)
                        let xPos = magicSize.width * 2 * (CGFloat(ringSettings.ringStaticHorizontalPositionNumeric) - 0.5)
                        let yPos = -magicSize.height * 2 * (CGFloat(ringSettings.ringStaticVerticalPositionNumeric) - 0.5)
                        
                        return CGPoint.init(x: xPos, y: yPos)
                    }
                    
                    //positioning code from watchNode
                    var xPos:CGFloat = 0
                    var yPos:CGFloat = 0
                    let xDist = magicSize.width * CGFloat(currentDistance) - CGFloat(ringSetting.textSize * 15)
                    let yDist = magicSize.height * CGFloat(currentDistance) - CGFloat(ringSetting.textSize * 10)
                    
                    let horizNumericForPos = currentDistance
                    let vertNumericForPos = currentDistance
                    
                    //debugPrint("hPos:" + ringSetting.ringStaticItemVerticalPosition.rawValue)
                    
                    if (ringSetting.ringStaticItemHorizontalPosition == .Centered) {
                        ringSetting.ringStaticHorizontalPositionNumeric = 0.5
                    }
                    if (ringSetting.ringStaticItemVerticalPosition == .Centered) {
                        ringSetting.ringStaticVerticalPositionNumeric = 0.5
                    }
                    
                    if (ringSetting.ringStaticItemHorizontalPosition == .Left) {
                        xPos = -xDist
                        ringSetting.ringStaticHorizontalPositionNumeric = 1.0 - horizNumericForPos
                        //debugPrint("hPos L:" + ringSetting.ringStaticHorizontalPositionNumeric.description)
                    }
                    if (ringSetting.ringStaticItemHorizontalPosition == .Right) {
                        xPos = xDist
                        ringSetting.ringStaticHorizontalPositionNumeric = horizNumericForPos
                        //debugPrint("hPos R:" + ringSetting.ringStaticHorizontalPositionNumeric.description)
                    }
                    if (ringSetting.ringStaticItemVerticalPosition == .Top) {
                        yPos = yDist
                        ringSetting.ringStaticVerticalPositionNumeric = 1.0 - vertNumericForPos
                        //debugPrint("hPos T:" + ringSetting.ringStaticVerticalPositionNumeric.description)
                    }
                    if (ringSetting.ringStaticItemVerticalPosition == .Bottom) {
                        yPos = -yDist
                        ringSetting.ringStaticVerticalPositionNumeric = vertNumericForPos
                        //debugPrint("hPos B:" + ringSetting.ringStaticVerticalPositionNumeric.description)
                    }
                    if (ringSetting.ringStaticItemHorizontalPosition == .Numeric) {
                        //debugPrint("hPos:" + ringSetting.ringStaticHorizontalPositionNumeric.description)
                        xPos = positionInViewForRingItem(ringSettings: ringSetting).x
                    }
                    if (ringSetting.ringStaticItemVerticalPosition == .Numeric) {
                        yPos = positionInViewForRingItem(ringSettings: ringSetting).y
                    }
                    
                    let shapeLayerOptions = DigitalTimeLayerOptions.init(defaults: true)
                    let textScale = ringSetting.textSize * 0.9
                    shapeLayerOptions.fontType = ringSetting.textType
                    shapeLayerOptions.effectType = ringSetting.ringStaticEffects
                    shapeLayerOptions.formatType = ringSetting.ringStaticTimeFormat
                    
                    let hPos = (xPos / (312/2)) * 1.25
                    let vPos = (yPos / (390/2)) * 1.45
                    
                    //adjust for positions ?
                    
                    let newRingLayer = FaceLayer.init(layerType: FaceLayerTypes.DateTimeLabel, alpha: 1.0, horizontalPosition: Float(hPos), verticalPosition: Float(vPos), scale: textScale, angleOffset: 0, desiredThemeColorIndex: layerDesiredColorIndex, layerOptions: shapeLayerOptions, filenameForImage: "")
                    newFaceSetting.faceLayers.append(newRingLayer)
                }
                
                //move it closer to center
                currentDistance = currentDistance - ringSetting.ringWidth
                
            }
            // END RING SETTINGS LOOP
            
            //HANDS
            var secondHandGlowWidth:CGFloat = 0
            var minuteHandGlowWidth:CGFloat = 0
            var hourHandGlowWidth:CGFloat = 0
            var secondHandAlpha:CGFloat = 1
            var minuteHandAlpha:CGFloat = 1
            var hourHandAlpha:CGFloat = 1
            
            var desiredThemeColorIndexForOutline = -1
            if clockFaceSettings.shouldShowHandOutlines {
                desiredThemeColorIndexForOutline = getIndexForMaterial(newFaceSetting: newFaceSetting, materialToTest: clockFaceSettings.handOutlineMaterialName)
            }
            
            //HOUR HAND
            if clockFaceSettings.handEffectWidths.count>2 {
                hourHandGlowWidth = CGFloat(clockFaceSettings.handEffectWidths[2])
            }
            if clockFaceSettings.handAlphas.count>2 {
                hourHandAlpha = CGFloat(clockFaceSettings.handAlphas[2])
            }
        
            let hourdesiredThemeColorIndex = getIndexForMaterial(newFaceSetting: newFaceSetting, materialToTest: clockFaceSettings.hourHandMaterialName)
            
            //set up layer options
            let hourHandLayerOptions = HourHandLayerOptions.init(defaults: true)
            hourHandLayerOptions.handType = clockFaceSettings.hourHandType
            hourHandLayerOptions.effectsStrength = Float(hourHandGlowWidth)
            if clockFaceSettings.shouldShowHandOutlines {
                hourHandLayerOptions.outlineWidth = 1.0
                hourHandLayerOptions.desiredThemeColorIndexForOutline = desiredThemeColorIndexForOutline
            }
            
            let hourHandLayer = FaceLayer.init(layerType: .HourHand, alpha: Float(hourHandAlpha), horizontalPosition: 0, verticalPosition: 0, scale: 1.0, angleOffset: 0,
                                               desiredThemeColorIndex: hourdesiredThemeColorIndex, layerOptions: hourHandLayerOptions, filenameForImage: "")
            
            if clockFaceSettings.hourHandType != .HourHandTypeNone {
                newFaceSetting.faceLayers.append(hourHandLayer)
            }
            // END HOUR HAND
            
            //MINUTE HAND
            if clockFaceSettings.handEffectWidths.count>1 {
                minuteHandGlowWidth = CGFloat(clockFaceSettings.handEffectWidths[1])
            }
            if clockFaceSettings.handAlphas.count>1 {
                minuteHandAlpha = CGFloat(clockFaceSettings.handAlphas[1])
            }
            
            let minutedesiredThemeColorIndex = getIndexForMaterial(newFaceSetting: newFaceSetting, materialToTest: clockFaceSettings.minuteHandMaterialName)
            
            //set up layer options
            let minuteHandLayerOptions = MinuteHandLayerOptions.init(defaults: true)
            minuteHandLayerOptions.handType = clockFaceSettings.minuteHandType
            minuteHandLayerOptions.handAnimation = clockFaceSettings.minuteHandMovement
            minuteHandLayerOptions.effectsStrength = Float(minuteHandGlowWidth)
            if clockFaceSettings.shouldShowHandOutlines {
                minuteHandLayerOptions.outlineWidth = 1.0
                minuteHandLayerOptions.desiredThemeColorIndexForOutline = desiredThemeColorIndexForOutline
            }
            
            let minuteHandLayer = FaceLayer.init(layerType: .MinuteHand, alpha: Float(minuteHandAlpha), horizontalPosition: 0, verticalPosition: 0, scale: 1.0, angleOffset: 0,
                                                 desiredThemeColorIndex: minutedesiredThemeColorIndex, layerOptions: minuteHandLayerOptions, filenameForImage: "")
            
            //set props
            minuteHandLayer.alpha = Float(minuteHandAlpha)
            
            if clockFaceSettings.minuteHandType != .MinuteHandTypeNone {
                newFaceSetting.faceLayers.append(minuteHandLayer)
            }
            // END MINUTE HAND
            
            //SECOND HAND
            if clockFaceSettings.handEffectWidths.count>0 {
                secondHandGlowWidth = CGFloat(clockFaceSettings.handEffectWidths[0])
            }
            if clockFaceSettings.handAlphas.count>0 {
                secondHandAlpha = CGFloat(clockFaceSettings.handAlphas[0])
            }
            
            let secondHandDesiredThemeColorIndex = getIndexForMaterial(newFaceSetting: newFaceSetting, materialToTest: clockFaceSettings.secondHandMaterialName)

            //set up layer options
            let secondHandLayerOptions = SecondHandLayerOptions.init(defaults: true)
            secondHandLayerOptions.handType = clockFaceSettings.secondHandType
            secondHandLayerOptions.handAnimation = clockFaceSettings.secondHandMovement
            secondHandLayerOptions.effectsStrength = Float(secondHandGlowWidth)
            if clockFaceSettings.shouldShowHandOutlines {
                secondHandLayerOptions.outlineWidth = 1.0
                secondHandLayerOptions.desiredThemeColorIndexForOutline = desiredThemeColorIndexForOutline
            }
            if let overlaySettings = clockSetting.clockOverlaySettings {
                secondHandLayerOptions.physicsFieldType = overlaySettings.fieldType
                secondHandLayerOptions.physicFieldStrength = overlaySettings.itemStrength
            }
            
            let secondHandLayer = FaceLayer.init(layerType: .SecondHand, alpha: Float(secondHandAlpha), horizontalPosition: 0, verticalPosition: 0, scale: 1.0, angleOffset: 0,
                        desiredThemeColorIndex: secondHandDesiredThemeColorIndex, layerOptions: secondHandLayerOptions, filenameForImage: "")

            //set props
            secondHandLayer.alpha = Float(secondHandAlpha)
            
            if clockFaceSettings.secondHandType != .SecondHandNodeTypeNone {
                newFaceSetting.faceLayers.append(secondHandLayer)
            }
            // END SECOND HAND
         
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
