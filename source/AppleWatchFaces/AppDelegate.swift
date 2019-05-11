//
//  AppDelegate.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 10/17/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var clockTimer =  ClockTimer()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        printFonts()
        
        clockTimer.startTimer()
        
        //TODO: do this only once on initial launch ( save a pref to skip it )
        AppUISettings.createFolders()
        
        return true
    }
    
    // MARK: - Handle File Sharing
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard url.pathExtension == "awf" else { return false }
        
        UserClockSetting.loadFromFile()
        UserClockSetting.addNewFromPath(path: url.path, importDuplicatesAsNew: true)
        
        //tell chooser view to reload its cells and regen thumbs
        NotificationCenter.default.post(name: FaceChooserViewController.faceChooserRegenerateChangeNotificationName, object: nil, userInfo:nil)

        return true
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics renderixng callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func stopTimerForScreenShot() {
        clockTimer.stopTimer()
        //set time to screenShotime
        let calendar = NSCalendar.current
        if let screenshotDate = calendar.date(bySettingHour: Int(AppUISettings.screenShotHour), minute: Int(AppUISettings.screenShotMinutes), second: Int(AppUISettings.screenShotSeconds), of: Date()) {
            ClockTimer.currentDate = screenshotDate
        }
    }
    
    func stopTimerForThemeShots() {
        clockTimer.stopTimer()
        //set time to theme time, this time works well to put hands in upper right
        let calendar = NSCalendar.current
        if let screenshotDate = calendar.date(bySettingHour: Int(12), minute: Int(7), second: Int(4), of: Date()) {
            ClockTimer.currentDate = screenshotDate
        }
    }
    
    func resumeTimer() {
        clockTimer.startTimer()
    }
    
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }


}

