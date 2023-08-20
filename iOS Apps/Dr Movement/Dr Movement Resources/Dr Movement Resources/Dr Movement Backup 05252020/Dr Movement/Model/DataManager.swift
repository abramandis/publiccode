//
//  DataManager.swift
//  Dr Movement
//
//  Created by ABRAM ANDIS on 5/16/20.
//  Copyright © 2020 ABRAM ANDIS. All rights reserved.
//

import Foundation
import Firebase

// MARK: --> TPDataManager Class

class FireXDataManager: NSObject {
    
    let db = Firestore.firestore()
    
    // Init Singleton
    class var shared: FireXDataManager {
        struct Singleton {
            static let instance = FireXDataManager()
        }
        return Singleton.instance
    }

    override init() {
        super.init()
    }
    
    // MARK: - FUNCTIONS
    
    func getExams(){
        
        
    }
    
    
}



