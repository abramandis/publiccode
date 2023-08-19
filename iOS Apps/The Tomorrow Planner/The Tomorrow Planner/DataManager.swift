//
//  DataManager.swift
//  The Tomorrow Planner
//
//  Created by ABRAM ANDIS on 8/24/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import Foundation

private struct JSONFileNameKeys {
    static let today = "todayX.json"
    static let tomorrow = "tomorrowX.json"
    static let history = "historyX.json"
    static let future = "futureX.json"
}

// MARK: - Save and Load Functions
func saveLocalJSONData(toFileName: String, data: TPContainerModelX, completionHandler: CompletionHandler) {
    let flag = Storage.store(data, to: .documents, as: toFileName)
    completionHandler(flag)
}

func loadLocalJSONData(fromFileName: String) -> TPContainerModelX? {
    // retrieve JSON data
    if let retrievedPlan = Storage.retrieve(fromFileName, from: .documents, as: TPContainerModelX.self) {
        return retrievedPlan
    } else {
        return nil
    }
}

func saveAllDataToJSON(){
    saveLocalJSONData(toFileName: JSONFileNameKeys.tomorrow, data: TPTomorrowClassX.sharedInstance.model, completionHandler: { success -> Void in })
    saveLocalJSONData(toFileName: JSONFileNameKeys.today, data: TPTodayClassX.sharedInstance.model, completionHandler: { success -> Void in })
    saveLocalJSONData(toFileName: JSONFileNameKeys.future, data: TPFutureClassX.sharedInstance.model, completionHandler: { success -> Void in })
}

// MARK: - initializeSingletons
/** This function creates 3 Singletons and loads appropriate data from JSON files stores locally on disk, and creates new default instances if necessary.
    It also updates the current 'tomorrow' plan to the 'today' plan if it sees the date changes **/

func initializeSingletons() {
    initializeData(withType: .tomorrow, completionHandler: { success -> Void in
        if success {
            updateTomorrowToToday(didUpdate: { (didUpdate) -> Void in
                if didUpdate {
                    saveLocalJSONData(toFileName: JSONFileNameKeys.today, data: TPTodayClassX.sharedInstance.model, completionHandler: { success -> Void in })
                }
                if !didUpdate {
                    initializeData(withType: .today, completionHandler: { success -> Void in })
                }
            })
        }
    })
    initializeData(withType: .future, completionHandler: { (success) -> Void in })
}

// MARK: - initializeData
/** loads appropriate data from disk and creates new default instances of data if nothing loads from disk **/
func initializeData(withType: DataSourceEnum, completionHandler: CompletionHandler) {
    
    switch withType {
    case .tomorrow:
        // load tomorrow data
        if let model = loadLocalJSONData(fromFileName: JSONFileNameKeys.tomorrow){
            TPTomorrowClassX.sharedInstance.model = model
        } else {
            TPTomorrowClassX.sharedInstance.model = TPContainerModelX(withType: .tomorrow)
        }
        completionHandler(true)
        
    case .today:
        // load today data
        if let model = loadLocalJSONData(fromFileName: JSONFileNameKeys.today){
            if Calendar.current.isDateInToday(model.planArray[0].date) {
                TPTodayClassX.sharedInstance.model = model
                } else {
                TPTodayClassX.sharedInstance.model = TPContainerModelX(withType: .today)
                }
        } else {
            TPTodayClassX.sharedInstance.model = TPContainerModelX(withType: .today)
        }
        completionHandler(true)
        
    case .future:
        // load future data
        if let model = loadLocalJSONData(fromFileName: JSONFileNameKeys.future){
            TPFutureClassX.sharedInstance.model = model
        } else {
            let model = TPContainerModelX.init(withType: .future)
            TPFutureClassX.sharedInstance.model = model
        }
        completionHandler(true)
    }
}

// MARK: - updateTomorrowToToday
/** turns the current 'tomorrow' plan into the 'today' plan if the date changes **/

func updateTomorrowToToday(didUpdate: CompletionHandler){
    // get the first plan
    let tomorrowPlan = TPTomorrowClassX.sharedInstance.model.planArray[0]
    if Calendar.current.isDateInToday(tomorrowPlan.date) {
        // MAKE THE TOMORROW PLAN THE TODAY PLAN
        TPTodayClassX.sharedInstance.model = TPContainerModelX(planArray: [tomorrowPlan], titles: [TodayTitleKeys.today])
        if let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
            // manually creates a TPPlanModelX based on tomorrowNameKeys
            let newTomorrowPlan = TPPlanModelX(date: tomorrowDate, title: TomorrowTitleKeys.tomorrow, objectStackTitles: TomorrowNameKeys.indexedArrayOfNameKeys)
            TPTomorrowClassX.sharedInstance.model.planArray[0] = newTomorrowPlan
        }
        didUpdate(true)
    } else {
        if !Calendar.current.isDateInTomorrow(tomorrowPlan.date) && !Calendar.current.isDateInToday(tomorrowPlan.date) {
            if let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                let newTomorrowModelObject = TPPlanModelX(date: tomorrowDate, title: TomorrowTitleKeys.tomorrow, objectStackTitles: TomorrowNameKeys.indexedArrayOfNameKeys)
                TPTomorrowClassX.sharedInstance.model.planArray[0] = newTomorrowModelObject
            }
        }
        didUpdate(false)
    }
}

// MARK: - Singleton Classes

// MARK: - TPTomorrowClassX
class TPTomorrowClassX: NSObject {
    
    // Init Singleton
    class var sharedInstance: TPTomorrowClassX {
        struct Singleton {
            static let instance = TPTomorrowClassX()
        }
        return Singleton.instance
    }
    // default initialization
    var model : TPContainerModelX = TPContainerModelX(withType: .tomorrow)

    override init() {
        super.init()
    }
}

// MARK: - TPTodayClassX
class TPTodayClassX: NSObject {
    
    // Init Singleton
    class var sharedInstance: TPTodayClassX {
        struct Singleton {
            static let instance = TPTodayClassX()
        }
        return Singleton.instance
    }
    // default initialization
    var model : TPContainerModelX = TPContainerModelX(withType: .today)

    override init() {
        super.init()
    }
}

// MARK: - TPFutureClassX
class TPFutureClassX: NSObject {
    
    // Init Singleton
    class var sharedInstance: TPFutureClassX {
        struct Singleton {
            static let instance = TPFutureClassX()
        }
        return Singleton.instance
    }
    // default initialization
    var model : TPContainerModelX = TPContainerModelX(withType: .future)

    override init() {
        super.init()
    }
}

func updateModelStackText(type: DataSourceEnum, pageIndex: Int, stackIndex: Int, text: String ){
    switch type {
    case .tomorrow:
        TPTomorrowClassX.sharedInstance.model.planArray[pageIndex].objectStack[stackIndex].text = text
    case .today:
        TPTodayClassX.sharedInstance.model.planArray[pageIndex].objectStack[stackIndex].text = text
    case .future:
        TPFutureClassX.sharedInstance.model.planArray[pageIndex].objectStack[stackIndex].text = text
    }
    // notify delegate
}

func updateModelNotes(type: DataSourceEnum, pageIndex: Int, text: String ) {
    switch type {
    case .tomorrow:
        TPTomorrowClassX.sharedInstance.model.planArray[pageIndex].notes = text
    case .today:
        TPTodayClassX.sharedInstance.model.planArray[pageIndex].notes = text
    case .future:
        TPFutureClassX.sharedInstance.model.planArray[pageIndex].notes = text
    }
    // notify delegate
}

func getModelData(type: DataSourceEnum) -> TPContainerModelX {
    switch type {
    case .tomorrow:
        return TPTomorrowClassX.sharedInstance.model
    case .today:
        return TPTodayClassX.sharedInstance.model
    case .future:
        return TPFutureClassX.sharedInstance.model
    }
}

func getModelPlanData(type: DataSourceEnum, planArrayIndex: Int) -> TPPlanModelX {
    switch type {
    case .tomorrow:
        return TPTomorrowClassX.sharedInstance.model.planArray[planArrayIndex]
    case .today:
        return TPTodayClassX.sharedInstance.model.planArray[planArrayIndex]
    case .future:
        return TPFutureClassX.sharedInstance.model.planArray[planArrayIndex]
    }
}


