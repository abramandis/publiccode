//
//  Model.swift
//  The Tomorrow Planner
//
//  Created by ABRAM ANDIS on 8/23/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import Foundation

// MARK: - TPContainerModelX
// Container class for Page View Controllers. Contains an array of "tomorrow plans" and an array of tomorrow plan titles.
class TPContainerModelX : Codable {
    var planArray : [TPPlanModelX]
    var titles : [String]
    
    // MARK: - Init with Type
    init (withType: DataSourceEnum){
        
        switch withType {
        case .tomorrow:
            // creates the stacks
            var nestedTomorrowStack : [TPObjectX] = []
            var nestedFutureStack : [TPObjectX] = []
            for key in TomorrowNameKeys.indexedArrayOfNameKeys {
                let dataObject = TPObjectX(title: key, text: "")
                nestedTomorrowStack.append(dataObject)
            }
            for key in FutureModelNameKeys.indexedArrayOfNameKeys{
                let dataObject = TPObjectX(title: key, text: "")
                nestedFutureStack.append(dataObject)
            }
            // creates the pages
            var tempDataArray : [TPPlanModelX] = []
            var tempTitlesArray : [String] = []
            for title in TomorrowTitleKeys.indexedArrayOfNameKeys {
                let tempTPModel = TPPlanModelX(date: Date(), objectStack: nestedFutureStack, notes: "", title : title)
                if title == TomorrowTitleKeys.tomorrow {
                    tempTPModel.objectStack = nestedTomorrowStack
                    // add a day to the date
                    if let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                        tempTPModel.date = tomorrowDate
                    }
                }
                tempDataArray.append(tempTPModel)
                tempTitlesArray.append(tempTPModel.title)
            }
            planArray = tempDataArray
            titles = tempTitlesArray
            
        case .today:
            // creates today plan template
            var nestedTomorrowArray : [TPObjectX] = []
            for key in TomorrowNameKeys.indexedArrayOfNameKeys {
                let dataObject = TPObjectX(title: key, text: "")
                nestedTomorrowArray.append(dataObject)
            }
            // creates today pages, however there is only one
            let tempDataArray : [TPPlanModelX] = [TPPlanModelX(date: Date(), objectStack: nestedTomorrowArray, notes: "", title : TodayTitleKeys.today)]
            let tempTitlesArray : [String] = [TodayTitleKeys.today]
            planArray = tempDataArray
            titles = tempTitlesArray
            
        case .future:
            // creates future plan template
            var nestedArray : [TPObjectX] = []
            for key in FutureModelNameKeys.indexedArrayOfNameKeys {
                let dataObject = TPObjectX(title: key, text: "")
                nestedArray.append(dataObject)
            }
            // creates pages
            var tempData : [TPPlanModelX] = []
            var tempTitles : [String] = []
            for title in FutureModelMainTitleKeys.indexedArrayOfNameKeys {
                let model = TPPlanModelX(date: Date(), objectStack: nestedArray, notes: "", title: title)
                tempData.append(model)
                tempTitles.append(model.title)
            }
            planArray = tempData
            titles = tempTitles
            }
        }
        
    // MARK: - Init with Data
    init (planArray: [TPPlanModelX], titles: [String]){
        self.planArray = planArray
        self.titles = titles
    }
    
    // MARK: - Init with Decoder
    public required init(from decoder: Decoder) throws {
        
        var tempDataArray : [TPPlanModelX] = []
        var tempTitles : [String] = []
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let planArray = try container.decodeIfPresent([TPPlanModelX].self, forKey: .planArray){
            tempDataArray = planArray
        }
        if let titles = try container.decodeIfPresent([String].self, forKey: .titles){
            tempTitles = titles
        }
        
        self.planArray = tempDataArray
        self.titles = tempTitles
        
    }
    
}

// MARK: -- > TPPlanModelX
// This is a generic "tomorrow plan". Includes a Date, Stack of TPObjectModelX objects, Notes, and a Title
class TPPlanModelX: Codable {
    // note unwrapping here...
    var date: Date!
    var objectStack : [TPObjectX]
    var notes: String
    var title: String
    
    // MARK: - Init from Data
    init (date: Date, objectStack: [TPObjectX], notes: String, title: String){
        self.date = date
        self.objectStack = objectStack
        self.notes = notes
        self.title = title
    }
    
    // MARK: - Custom Init
    init (date: Date, title: String, objectStackTitles: [String]) {
        
        var tempStack : [TPObjectX] = []
        for title in objectStackTitles {
                let object = TPObjectX(title: title, text: "")
                tempStack.append(object)
        }
        
        self.date = date
        self.objectStack = tempStack
        self.title = title
        self.notes = ""
    }
    
    // MARK: - Init from Decoder
    public required init(from decoder: Decoder) throws {
        
        var tempDate : Date = Date()
        var tempStack : [TPObjectX] = [TPObjectX()]
        var tempNotes : String = ""
        var tempTitle : String = ""
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let date = try container.decodeIfPresent(Date.self, forKey: .date){
            tempDate = date
        }
        if let objectStack = try container.decodeIfPresent([TPObjectX].self, forKey: .objectStack){
            tempStack = objectStack
        }
        if let notes = try container.decodeIfPresent(String.self, forKey: .notes) {
            tempNotes = notes
        }
        if let title = try container.decodeIfPresent(String.self, forKey: .title){
            tempTitle = title
        }
        
        self.date = tempDate
        self.objectStack = tempStack
        self.notes = tempNotes
        self.title = tempTitle
    }
 
}

// MARK: --> TPObjectX
// Base object that contains the plan "data"
class TPObjectX: NSObject, Codable {
    var title: String = ""
    var text: String = ""
    override init() {
        super.init()
    }
    
    // MARK: - Init
    init(title: String, text: String){
        super.init()
        self.title = title
        self.text = text
    }
}
