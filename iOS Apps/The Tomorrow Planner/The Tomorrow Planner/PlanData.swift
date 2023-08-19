//
//  PlanData.swift
//  The Tomorrow Planner
//
//  Created by Abram Andis on 4/25/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//
//  Creates persistent data structures and models of TheTomorrowPlan
//  and TheTodayPlan for use across the application

import UIKit
import os.log

enum DataSourceEnum {
    case tomorrow
    case today
    case future
}

public struct ModelNameKeys {
    static let quoteOfTheDay = "Quote Of The Day"
    static let goals = "Goals"
    static let grateful = "What I'm grateful for"
    static let fourToSix = "4am to 6am"
    static let sixToNine = "6am to 9am"
    static let nineToTwelve = "9am to 12pm"
    static let twelveToThree = "12pm to 3pm"
    static let threeToSix = "3pm to 6pm"
    static let sixToNinePM = "6pm to 9pm"
    static let nineAndAfter = "9pm and After"
    // this array sets the order of how objects are displayed in the UI
    static let indexedArrayOfNameKeys : [String] = [ModelNameKeys.quoteOfTheDay,
                                                    ModelNameKeys.goals,
                                                    ModelNameKeys.grateful,
                                                    ModelNameKeys.fourToSix,
                                                    ModelNameKeys.sixToNine,
                                                    ModelNameKeys.nineToTwelve,
                                                    ModelNameKeys.twelveToThree,
                                                    ModelNameKeys.threeToSix,
                                                    ModelNameKeys.sixToNinePM,
                                                    ModelNameKeys.nineAndAfter]
}

public struct FutureModelMainTitleKeys {
    static let thisYear = "This Year"
    static let threeYears = "3 Years"
    static let lifeTime = "Lifetime"
    static let indexedArrayOfNameKeys : [String] = [FutureModelMainTitleKeys.thisYear,                                               FutureModelMainTitleKeys.threeYears,                                             FutureModelMainTitleKeys.lifeTime]
    
}

public struct FutureModelNameKeys {
    static let whatDoIWant = "What do I want"
    static let whyDoIWantIt = "Why do I want these things"
    static let howWillIGetIt = "How will I get these things"
    static let indexedArrayOfNameKeys : [String] = [FutureModelNameKeys.whatDoIWant,                                                 FutureModelNameKeys.whyDoIWantIt,                                                FutureModelNameKeys.howWillIGetIt]
}

public struct TomorrowTitleKeys {
    static let tomorrow = "Tomorrow"
    static let thisWeek = "This Week"
    static let thisMonth = "This Month"
    static let indexedArrayOfNameKeys : [String] = [TomorrowTitleKeys.tomorrow, TomorrowTitleKeys.thisWeek, TomorrowTitleKeys.thisMonth]
    
}

public struct TomorrowNameKeys {
    static let quoteOfTheDay = "Quote Of The Day"
    static let goals = "Goals"
    static let grateful = "What I'm grateful for"
    static let fourToSix = "4am to 6am"
    static let sixToNine = "6am to 9am"
    static let nineToTwelve = "9am to 12pm"
    static let twelveToThree = "12pm to 3pm"
    static let threeToSix = "3pm to 6pm"
    static let sixToNinePM = "6pm to 9pm"
    static let nineAndAfter = "9pm and After"
    // this array sets the order of how objects are displayed in the UI
    static let indexedArrayOfNameKeys : [String] = [ModelNameKeys.quoteOfTheDay,
                                                    ModelNameKeys.goals,
                                                    ModelNameKeys.grateful,
                                                    ModelNameKeys.fourToSix,
                                                    ModelNameKeys.sixToNine,
                                                    ModelNameKeys.nineToTwelve,
                                                    ModelNameKeys.twelveToThree,
                                                    ModelNameKeys.threeToSix,
                                                    ModelNameKeys.sixToNinePM,
                                                    ModelNameKeys.nineAndAfter]
}

public struct TodayTitleKeys {
    static let today = "Today"
    static let indexedArrayOfNameKeys : [String] = [TodayTitleKeys.today]
}

// MARK: --> TP OBJECT

class TPObject: NSObject, Codable {
    // a tomorrow planner object
    var title: String = ""
    var text: String = ""
    override init() {
        super.init()
    }
    
    init(title: String, text: String){
        super.init()
        self.title = title
        self.text = text
    }
}

// MARK: -- > TP MODEL
// DATE, DATA ARRAY (title and text), and NOTES
class TPModel : Codable {
    // note unwrapping here...
    var date: Date!
    var dataArray : [TPObject]
    var notes: String
    var title: String
    
    // Default initializer (probably should delete this as it doesn't setup a TITLE)
    /*
    init (){
        date = Date()
        var newArray : [TPObject] = []
        for key in TomorrowNameKeys.indexedArrayOfNameKeys {
            let dataObject = TPObject(title: key, text: "")
            newArray.append(dataObject)
        }
        dataArray = newArray
        notes = ""
        title = ""
    }
    */
    
    // Initialize with Data
    init (date: Date, dataArray: [TPObject], notes: String, title: String){
        self.date = date
        self.dataArray = dataArray
        self.notes = notes
        self.title = title
    }
    
    // Initialize with Title and no Data 
    init (date: Date, title: String) {
        
        var tempArray : [TPObject] = []
        for key in TomorrowNameKeys.indexedArrayOfNameKeys {
                let dataObject = TPObject(title: key, text: "")
                tempArray.append(dataObject)
        }
        
        self.date = date
        self.dataArray = tempArray
        self.title = title
        self.notes = ""
    }
    
    // Initialize from Decoder
    public required init(from decoder: Decoder) throws {
        
        var tempDate : Date = Date()
        var tempDataArray : [TPObject] = [TPObject()]
        var tempNotes : String = ""
        var tempTitle : String = ""
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let date = try container.decodeIfPresent(Date.self, forKey: .date){
            tempDate = date
        }
        if let dataArray = try container.decodeIfPresent([TPObject].self, forKey: .dataArray){
            tempDataArray = dataArray
        }
        if let notes = try container.decodeIfPresent(String.self, forKey: .notes) {
            tempNotes = notes
        }
        if let title = try container.decodeIfPresent(String.self, forKey: .title){
            tempTitle = title
        }
        
        self.date = tempDate
        self.dataArray = tempDataArray
        self.notes = tempNotes
        self.title = tempTitle
    }
 
}

// Container class for Page View Controllers. Contains nested Hierarchical Data
class TPTomorrowModel : Codable {
    var dataArray : [TPModel]
    var titles : [String]
    
    // Default Initializer
    init (){
        
        // Creates a default array of TPObjects based on TomorrowNameKeys
        var nestedTomorrowArray : [TPObject] = []
        var nestedFutureArray : [TPObject] = []
        // sets up "goals, quote of the day, 4am - 6am.. etc."
        for key in TomorrowNameKeys.indexedArrayOfNameKeys {
            let dataObject = TPObject(title: key, text: "")
            nestedTomorrowArray.append(dataObject)
        }
        // sets up "what I want, why I want it..etc"
        for key in FutureModelNameKeys.indexedArrayOfNameKeys{
            let dataObject = TPObject(title: key, text: "")
            nestedFutureArray.append(dataObject)
        }
        
        // Creates a default array of TPModels based on TomorrowTitleKeys
        var tempDataArray : [TPModel] = []
        var tempTitlesArray : [String] = []
        for title in TomorrowTitleKeys.indexedArrayOfNameKeys {
            let tempTPModel = TPModel(date: Date(), dataArray: nestedFutureArray, notes: "", title : title)
            // if its the tomorrow object add a day to the date to make 'tomorrow'
            if title == TomorrowTitleKeys.tomorrow {
                print("PLAN DATA:::::::::::: TITLE KEY EQUALS TOMORROW... ADDING A DAY to TOMORROW.")
                // change titles and text to make the tomorrow object
                tempTPModel.dataArray = nestedTomorrowArray
                // add a day to the date
                if let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                    tempTPModel.date = tomorrowDate
                    print("Date is:::: ")
                    print(tempTPModel.date ?? "no date...")
                } else {
                    print("Plan Data: could not initialize tomorrowDate")
                }
            }
            tempDataArray.append(tempTPModel)
            tempTitlesArray.append(tempTPModel.title)
        }
        dataArray = tempDataArray
        titles = tempTitlesArray
    }
    
    // Initialize with Data
    init (dataArray: [TPModel], titles: [String]){
        self.dataArray = dataArray
        self.titles = titles
    }
    
    // Initialize from Decoder
    public required init(from decoder: Decoder) throws {
        
        var tempDataArray : [TPModel] = []
        var tempTitles : [String] = []
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let dataArray = try container.decodeIfPresent([TPModel].self, forKey: .dataArray){
            tempDataArray = dataArray
        }
        if let titles = try container.decodeIfPresent([String].self, forKey: .titles){
            tempTitles = titles
        }
        
        self.dataArray = tempDataArray
        self.titles = tempTitles
        
    }
    
}

class TPTodayModel : Codable {
    var data : TPModel
    
    // Default Initializer
    init (){
        // Creates a default array of TPObjects based on TomorrowNameKeys
        var nestedArray : [TPObject] = []
        for key in TomorrowNameKeys.indexedArrayOfNameKeys {
            let dataObject = TPObject(title: key, text: "")
            nestedArray.append(dataObject)
        }
        data = TPModel(date: Date(), dataArray: nestedArray, notes: "", title: TodayTitleKeys.today)
    }
    
    // Initialize with Data
    init (data: TPModel){
        self.data = data
    }
    
    // Initialize from Decoder
    public required init(from decoder: Decoder) throws {
        var tempData : TPModel = TPModel(date: Date(), title: "TEMP")
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let data = try container.decodeIfPresent(TPModel.self, forKey: .data){
            tempData = data
        }
        self.data = tempData
    }

}

// Mother class, has DATE, DATA ARRAY, and LIST of VC Main Titles
class TPFutureModel : Codable {
    // note unwrapping here...
    var date: Date!
    var dataArray : [FMObject]
    var titles : [String]
    
    // Default Initializer
    init (){
        date = Date()
        
        // Creates an array of title and text objects
        // based on future model name keys
        var nestedArray : [TPObject] = []
        for key in FutureModelNameKeys.indexedArrayOfNameKeys {
            let dataObject = TPObject(title: key, text: "")
            nestedArray.append(dataObject)
        }
        
        // Creates an array of future model objects each with its own array of title
        // and text objects and a main title
        var tempDataArray : [FMObject] = []
        var tempTitlesArray : [String] = []
        for title in FutureModelMainTitleKeys.indexedArrayOfNameKeys {
            let tempFMObject = FMObject(mainTitle: title, dataArray: nestedArray)
            tempDataArray.append(tempFMObject)
            tempTitlesArray.append(tempFMObject.mainTitle)
        }
        dataArray = tempDataArray
        titles = tempTitlesArray
    }
    
    init (date: Date, dataArray: [FMObject], titles: [String]){
        self.date = date
        self.dataArray = dataArray
        self.titles = titles
    }
    
    
    public required init(from decoder: Decoder) throws {
        
        var tempDate : Date = Date()
        var tempDataArray : [FMObject] = [FMObject()]
        var tempTitles : [String] = []
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let date = try container.decodeIfPresent(Date.self, forKey: .date){
            tempDate = date
        }
        if let dataArray = try container.decodeIfPresent([FMObject].self, forKey: .dataArray){
            tempDataArray = dataArray
        }
        if let titles = try container.decodeIfPresent([String].self, forKey: .titles){
            tempTitles = titles
        }
        
        self.date = tempDate
        self.dataArray = tempDataArray
        self.titles = tempTitles
        
    }
    
}

// MARK --> FM OBJECT
class FMObject: NSObject, Codable {
    // a tomorrow planner object
    var dataArray : [TPObject] = []
    var mainTitle: String = ""
    
    override init() {
        super.init()
        for title in FutureModelMainTitleKeys.indexedArrayOfNameKeys{
            mainTitle = title
            for name in FutureModelNameKeys.indexedArrayOfNameKeys {
                dataArray.append(TPObject(title: name, text: ""))
            }
        }
    }
    
    init(mainTitle: String, dataArray: [TPObject]){
        super.init()
        self.mainTitle = mainTitle
        self.dataArray = dataArray
    }
}

// MARK --> TOMORROW SINGLETON CLASS

protocol TPTomorrowClassDelegate: class {
    func TPTomorrowClassDidRecieveDataUpdate()
}

class TPTomorrowClass: NSObject {
    
    // Init Singleton
    class var sharedInstance: TPTomorrowClass {
        struct Singleton {
            static let instance = TPTomorrowClass()
        }
        return Singleton.instance
    }
    // End Singleton
    
    weak var delegate: TPTomorrowClassDelegate?
    var tomorrowModel: TPTomorrowModel = TPTomorrowModel()
    
    override init() {
        super.init()
    }
    
}

// MARK -->  TODAY SINGLETON CLASS

protocol TPTodayClassDelegate: class {
    func TPTodayClassDidRecieveDataUpdate()
}

class TPTodayClass: NSObject {
    
    // Init Singleton
    class var sharedInstance: TPTodayClass {
        struct Singleton {
            static let instance = TPTodayClass()
        }
        return Singleton.instance
    }
    
    weak var delegate: TPTodayClassDelegate?
    var todayModel = TPTodayModel()
    
    override init() {
        super.init()
    }
}


// MARK -->  FUTURE SINGLETON CLASS
protocol TPFutureClassDelegate: class {
    func TPFutureClassDidRecieveDataUpdate()
}

class TPFutureClass: NSObject {
    
    // Init Singleton
    class var sharedInstance: TPFutureClass {
        struct Singleton {
            static let instance = TPFutureClass()
        }
        return Singleton.instance
    }
    
    weak var delegate: TPFutureClassDelegate?
    var futureModel : TPFutureModel = TPFutureModel()
    
    override init() {
        super.init()
    }
}

// --> MARK: TPNotepadDelegate

protocol TPNotepadDelegate: class {
    func TPNotepadDidRecieveDataUpdate()
    func TPNotepadUpdateDataSource()
}

enum NotepadEnum {
    case today
    case tomorrow
    case nextWeek
    case nextMonth
}
