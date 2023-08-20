//
//  DMDataModel.swift
//  Dr Movement
//
//  Created by Abram Andis on 7/5/20.
//  Copyright © 2020 Abram Andis. All rights reserved.
//
//  Global Class to pass data around View Controllers

import Foundation

// MARK -->  DMDataModel Singleton Class
protocol DMDataModelDelegate: class {
    func DMDataModelDidRecieveDataUpdate()
}

class DMDataModel: NSObject {
    
    // Init Singleton
    class var sharedInstance: DMDataModel {
        struct Singleton {
            static let instance = DMDataModel()
        }
        return Singleton.instance
    }
    
    weak var delegate: DMDataModelDelegate? {
        didSet {
            // possible delegate.DMDataModelDidRecieveDataUpdate() here
        }
    }
    var exam : DMExam?
    var examExercises : [DMExercise]? {
        didSet {
            guard let delegate = delegate else { return }
            delegate.DMDataModelDidRecieveDataUpdate()
        }
    }
    var allRoutines : [DMRoutine]? {
        didSet {
            guard let delegate = delegate else { return }
            delegate.DMDataModelDidRecieveDataUpdate()
        }
    }
    
    override init() {
        super.init()
    }
}
