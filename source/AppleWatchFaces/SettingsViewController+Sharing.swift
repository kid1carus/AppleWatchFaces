//
//  SettingsView+ShareProviders.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/17/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation
import UIKit

extension SettingsViewController {
    static func attachmentURL()->URL {
        let filename = SettingsViewController.currentFaceSetting.filename() + ".clk"
        return UserFaceSetting.DocumentsDirectory.appendingPathComponent(filename)
    }
    
    static func createTempTextFile(embedImages: Bool) {
        //TODO: move this to temporary folder to be less cleanup later / trash on device
        var serializedArray = [NSDictionary]()
        let serializedSettings = NSMutableDictionary.init(dictionary: SettingsViewController.currentFaceSetting.serializedSettings())
        
        if embedImages {
            var embeddedImages:[NSDictionary] = []
            for layer in SettingsViewController.currentFaceSetting.faceLayers {
                let layerImageDict = NSMutableDictionary.init()
                if layer.filenameForImage != "" {
                    if let jpgDataString = UIImage.getValidatedImageJPGData(imageName: layer.filenameForImage) {
                        layerImageDict["imageData"] = jpgDataString
                        layerImageDict["filename"] = layer.filenameForImage
                        
                        if let layerOptions = layer.layerOptions as? ImageBackgroundLayerOptions {
                            layerImageDict["hasTransparency"] = layerOptions.hasTransparency
                        }
                        
                        embeddedImages.append(layerImageDict)
                    }
                }
            }
            //add to serialized
            serializedSettings["embeddedImages"] = embeddedImages
        }
        
        serializedArray.append(serializedSettings)

        //delete existing file if its there
        let fileManagerIs = FileManager.default
        if fileManagerIs.fileExists(atPath: attachmentURL().path) {
            try? fileManagerIs.removeItem(at: attachmentURL())
        }
        UserFaceSetting.saveDictToFile(serializedArray: serializedArray, pathURL: attachmentURL())
    }
    
    func makeThumb( fileName: String) {
        makeThumb(fileName: fileName, cornerCrop: false)
    }
    
    func makeThumb( fileName: String, cornerCrop: Bool ) {
        //make thumbnail
        if let watchVC = watchPreviewViewController {
            
            if watchVC.makeThumb( imageName: fileName, cornerCrop: cornerCrop ) {
                //self.showMessage( message: "Screenshot successful.")
            } else {
                self.showError(errorMessage: "Problem creating screenshot.")
            }
            
        }
    }
    
    @IBAction func shareAll() {
        makeThumb(fileName: SettingsViewController.currentFaceSetting.uniqueID)
        let activityViewController = UIActivityViewController(activityItems: [TextProvider(), ImageProvider(),
                                                                              BackgroundImageProvider(), AttachmentProvider()], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}

class TextProvider: NSObject, UIActivityItemSource {
    
    let myWebsiteURL = NSURL(string:"clockology")!.absoluteString!
    //let appName = "AppleWatchFaces on github"
    let watchFaceCreatedText = "Watch face \"" + SettingsViewController.currentFaceSetting.title + "\" I created."
    let authorAtText = " @orffy "
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return NSObject()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        
        return watchFaceCreatedText
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        let promoText = watchFaceCreatedText + " using " + myWebsiteURL + "."
        
        //copy to clipboard for insta / FB
        UIPasteboard.general.string = promoText
        
        if activityType == .postToFacebook  {
            return nil
        }
        
        if activityType == .postToTwitter {
            return promoText + authorAtText
        }
        
        return promoText
    }
}

class AttachmentProvider: NSObject, UIActivityItemSource {
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return NSObject()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        if activityType == .postToFacebook  {
            return nil
        }
        
        SettingsViewController.createTempTextFile(embedImages: true)
        return SettingsViewController.attachmentURL()
        
    }
}

class ImageProvider: NSObject, UIActivityItemSource {
    
    func getThumbImageURL() -> URL? {
        if let newImageURL = UIImage.getValidatedImageURL(imageName: SettingsViewController.currentFaceSetting.uniqueID) {
            //copy as new file to send out friendly URL / filename
            let fileManagerIs = FileManager.default
            do {
                let newURL = newImageURL.deletingLastPathComponent().appendingPathComponent(SettingsViewController.currentFaceSetting.filename()+".jpg")
                if fileManagerIs.fileExists(atPath: newURL.path) {
                    try fileManagerIs.removeItem(at: newURL)
                }
                try fileManagerIs.copyItem(at: newImageURL, to: newURL)
                return newURL
            } catch {
                debugPrint("error copying new thumbnail file: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage.init()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return getThumbImageURL()
    }
}

class BackgroundTextProvider: NSObject, UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return NSObject()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
        //        if activityType == .postToFacebook  {
        //            return nil
        //        }
        //        let material = SettingsViewController.currentClockSetting.clockFaceMaterialName
        //        if !AppUISettings.materialIsColor(materialName: material) && UIImage.getImageFor(imageName: material) != nil {
        //            return "Background and settings file attached."
        //        }
        //        return "Settings file attached."
    }
    
}

class BackgroundImageProvider: NSObject, UIActivityItemSource {
    
    func getBackgroundImageURL() -> URL? {
        //        let material = SettingsViewController.currentClockSetting.clockFaceMaterialName
        //        if !AppUISettings.materialIsColor(materialName: material) {
        //            if let newImageURL = UIImage.getValidatedImageURL(imageName: material) {
        //                //copy as new file to send out friendly URL / filename
        //                let fileManagerIs = FileManager.default
        //                do {
        //                    let newURL = newImageURL.deletingLastPathComponent().appendingPathComponent(SettingsViewController.currentClockSetting.filename()+"-background.jpg")
        //                    if fileManagerIs.fileExists(atPath: newURL.path) {
        //                        try fileManagerIs.removeItem(at: newURL)
        //                    }
        //                    try fileManagerIs.copyItem(at: newImageURL, to: newURL)
        //                    return newURL
        //                } catch {
        //                    debugPrint("error copying new thumbnail file: " + error.localizedDescription)
        //                }
        //            }
        //        }
        return nil
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        if let newImageURL = getBackgroundImageURL() {
            return newImageURL
        } else {
            return UIImage.init()
        }
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if let newImageURL = getBackgroundImageURL() {
            return newImageURL
        } else {
            return nil
        }
    }
}
