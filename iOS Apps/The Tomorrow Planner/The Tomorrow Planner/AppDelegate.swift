//
//  AppDelegate.swift
//  The Tomorrow Planner
//
//  Created by Abram Andis on 4/21/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: BaseAppDelegate {

    var window: UIWindow?

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        print("App finished launching and running code")
        let gradientColors = GradientColors()
        if let backgroundLayer = gradientColors.gl {
            backgroundLayer.frame = (self.window?.frame)!
            self.window?.layer.insertSublayer(backgroundLayer, at: 0)
        }
        
        //printAllFontNames()
        
        // caches the keyboard. 
        _ = KeyboardService()
        
        return (super.application(application, didFinishLaunchingWithOptions: launchOptions))
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("App will resign active")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("App will enter background")
        //saveAllModelData()
        saveAllDataToJSON()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("App will enter foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("App became active")
        
        // NOTE::: even though this is on the local disk these are DATA tasks.
        // eventually this will be on FIREBASE and will take time to get a response
        // the UI should update with delegate methods once the data is returned.
        //initializeAllData()
        initializeSingletons()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("App terminating")
        saveAllModelData()
        saveAllDataToJSON()
    }

    // MARK: - initilization functions
    
    func initializeAllData() {
        // these calls take time so all of this code needs to be nested
        initializeTomorrowPlanData(completionHandler: { success -> Void in
            if success {
                updateTomorrowPlanData(didUpdate: { (didUpdate) -> Void in
                        if didUpdate {
                            saveTodayModel()
                        }
                        if !didUpdate {
                            initializeTodayPlanData(completionHandler: { success -> Void in })
                        }
                })
            }
        })
        initializeFuturePlanData(completionHandler: { (success) -> Void in})
    }
    
    func initializeTomorrowPlanData(completionHandler: CompletionHandler){
        // load data
        if let tomorrowModel = loadTomorrowModel(){
            TPTomorrowClass.sharedInstance.tomorrowModel = tomorrowModel
        } else {
            // make a new default model object and create a new local .json
            TPTomorrowClass.sharedInstance.tomorrowModel = TPTomorrowModel()
        }
        completionHandler(true)
    }
    
    func initializeTodayPlanData(completionHandler: CompletionHandler){
        // load data
        if let loadedTodayModel = loadTodayModel(){
            if Calendar.current.isDateInToday(loadedTodayModel.data.date) {
                TPTodayClass.sharedInstance.todayModel = loadedTodayModel
            } else {
                TPTodayClass.sharedInstance.todayModel = TPTodayModel()
            }
        } else {
            TPTodayClass.sharedInstance.todayModel = TPTodayModel()
        }
        completionHandler(true)
    }
    
    func initializeFuturePlanData(completionHandler: CompletionHandler){
        // load data
        if let futureModel = loadFutureModel(){
            TPFutureClass.sharedInstance.futureModel = futureModel
        } else {
            let model = TPFutureModel()
            TPFutureClass.sharedInstance.futureModel = model
        }
    }
    
    // auto change tomorrow object to today object
    func updateTomorrowPlanData(didUpdate: CompletionHandler){
        // check this..
        let tomorrowPlan = TPTomorrowClass.sharedInstance.tomorrowModel.dataArray[0]
        if Calendar.current.isDateInToday(tomorrowPlan.date) {
            // ** IMPORTANT ** // (moves tomorrow to today)
            TPTodayClass.sharedInstance.todayModel = TPTodayModel(data: tomorrowPlan)
            if let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                let newTomorrowModelObject = TPModel(date: tomorrowDate, title: TomorrowTitleKeys.tomorrow)
                TPTomorrowClass.sharedInstance.tomorrowModel.dataArray[0] = newTomorrowModelObject
            }
            didUpdate(true)
        } else {
            // if the loaded file is old ->
            if !Calendar.current.isDateInTomorrow(tomorrowPlan.date) && !Calendar.current.isDateInToday(tomorrowPlan.date) {
                if let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                    let newTomorrowModelObject = TPModel(date: tomorrowDate, title: TomorrowTitleKeys.tomorrow)
                    TPTomorrowClass.sharedInstance.tomorrowModel.dataArray[0] = newTomorrowModelObject
                }
            }
            didUpdate(false)
        }
        
        
    }
    
    func refreshModelDelegates(){
        
        // Refreshes UI
        if let TPTomorrowClassDelegate = TPTomorrowClass.sharedInstance.delegate {
            TPTomorrowClassDelegate.TPTomorrowClassDidRecieveDataUpdate()
        }
        if let TPTodayClassDelegate = TPTodayClass.sharedInstance.delegate {
            TPTodayClassDelegate.TPTodayClassDidRecieveDataUpdate()
        }
        if let TPFutureClassDelegate = TPFutureClass.sharedInstance.delegate {
            TPFutureClassDelegate.TPFutureClassDidRecieveDataUpdate()
        }
    }
    
}

