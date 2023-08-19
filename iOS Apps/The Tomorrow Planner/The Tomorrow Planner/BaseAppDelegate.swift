//
//  BaseAppDelegate.swift
//
//  Created by Cyril Chandelier on 21/04/2018.
//  Copyright © 2018 Cyril Chandelier. All rights reserved.
//

import UIKit

class BaseAppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Dependencies
    
    lazy var bundle: Bundle = Bundle.main
    lazy var userDefaults: UserDefaults = UserDefaults.standard
    
    // MARK: - UIApplicationDelegate methods
    
    @discardableResult func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Initializing app")
        print("My Super App delegate was CALLED")
        
        // test code REMOVE
        launchCount = 0
        
        // Try to detect first launch
        if launchCount == 0 {
            print("...first launch detected")
            applicationFirstLaunch()
        }
        
        // Update app launches count
        launchCount += 1
        print("...\(launchCount) launches")
        
        // Try to detect version upgrade
        let currentVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString")
            as! String
        if let lastLaunchVersion = lastLaunchVersion, currentVersion != lastLaunchVersion {
            print("...upgrade detected")
            applicationDidUpgrade(from: lastLaunchVersion, to: currentVersion)
        }
        
        // Update last known version if new
        if lastLaunchVersion != currentVersion {
            print("...saving new version: \(currentVersion)")
            lastLaunchVersion = currentVersion
        }
        
        // Update last known launch date
        print("...saving current launch date")
        appLastLaunchDate = Date()
        
        // Make sure user defaults are saved
        userDefaults.synchronize()
        
        return true
    }
    
    // MARK: - Optional methods to override
    
    func applicationFirstLaunch() {
        UserDefaults.standard.set(true, forKey: "isAppFirstRun") //Bool
        UserDefaults.standard.set(true, forKey: "showSwipeTutorial") //Bool
    }
    
    func applicationDidUpgrade(from: String, to: String) {}
    
    // MARK: - Utilities
    
    private(set) var launchCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.appLaunchCount)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.appLaunchCount)
        }
    }
    
    private(set) var lastLaunchVersion: String? {
        get {
            return userDefaults.string(forKey: Keys.appLastLaunchVersion)
        }
        set {
            if let newValue = newValue {
                userDefaults.set(newValue, forKey: Keys.appLastLaunchVersion)
            } else {
                userDefaults.removeObject(forKey: Keys.appLastLaunchVersion)
            }
        }
    }
    
    private(set) var appLastLaunchDate: Date? {
        get {
            return userDefaults.object(forKey: Keys.appLastLaunchDate) as? Date
        }
        set {
            if let newValue = newValue {
                userDefaults.set(newValue, forKey: Keys.appLastLaunchDate)
            } else {
                userDefaults.removeObject(forKey: Keys.appLastLaunchDate)
            }
        }
    }
    
    // MARK: - User default keys
    
    private struct Keys {
        static let appLaunchCount = "appLaunchCount"
        static let appLastLaunchVersion = "appLastLaunchVersion"
        static let appLastLaunchDate = "appLastLaunchDate"
    }
    
}


