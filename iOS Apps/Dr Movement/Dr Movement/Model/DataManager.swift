//
//  DataManager.swift
//  Dr Movement
//
//  Created by ABRAM ANDIS on 5/16/20.
//  Copyright © 2020 ABRAM ANDIS. All rights reserved.
//
//  Provides an interface between the Dr Movement objects and the returned database objects. This DMDataManager will call database functions from appropriate database service classes and will parse that data for view.

import Foundation
import FirebaseFirestoreSwift
import Firebase

// MARK: --> DMDataManager Class

class DMDataManager: NSObject {
    
    // Init Singleton
    class var shared: DMDataManager {
        struct Singleton {
            static let instance = DMDataManager()
        }
        return Singleton.instance
    }

    override init() {
        super.init()
    }
    
    // MARK: - FUNCTIONS
    
    // Return all exams from a particular patient
    func getExams(){
        
        // MARK: --> FIREBASE
        FireXDataManager.shared.dbExams.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let result = Result {
                        try document.data(as: DMExam.self)
                    }
                    switch result {
                    case .success(let exam):
                        if let exam = exam {
                            // A `City` value was successfully initialized from the DocumentSnapshot.
                            print("Exam: \(exam)")
                        } else {
                            // A nil value was successfully initialized from the DocumentSnapshot,
                            // or the DocumentSnapshot was nil.
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        // A `DMExam` value could not be initialized from the DocumentSnapshot.
                        print("Error decoding DMExam: \(error)")
                    }
                        
                }
                
            }
        }
        
        
    }
    
    func saveExam(exam : DMExam){
        
        // MARK: --> FIREBASE
        do {
            try FireXDataManager.shared.dbExams.addDocument(from: exam)
        } catch let error {
            print("Error writing exam to Firestore: \(error)")
        }
    }
    
    func getAllRoutines() {
        
        // MARK: --> FIREBASE
        FireXDataManager.shared.retrieveAllDocs(at: FireXDataManager.shared.dbRoutines){ (querySnapshot) in
            guard let querySnapshot = querySnapshot else { return }
            guard !querySnapshot.isEmpty else { return }
            
            // ** Error doesn't get passed back here. It is handled solely inside of the Firebase parse call.
            // ** Could return a good array, where some of the objects downloaded did not parse successfully
            
            // Parse firebase query to DM Object
            if let routines = FireXDataManager.shared.parse(querySnapshot: querySnapshot, as: DMRoutine.self) {
                if !routines.isEmpty {
                    // Update Global Data Model
                    DMDataModel.sharedInstance.allRoutines = routines
                } else {
                    print("Parsed Object Array is empty!")
                }
            } else {
                print("Parsed Object Array returned nil!")
            }
        }
    }
    
    func getExercisesFromRoutine(routine: DMRoutine) {
        
        // download exercises
        let myGroup = DispatchGroup()
        var tempArray : [DMExercise] = []
        for id in routine.exercises {
            myGroup.enter()
            getExercise(exercise: id) { (document) in
                if let document = document {
                    // PARSE DOCUMENT
                    if let parsedObject = FireXDataManager.shared.parse(document: document, as: DMExercise.self) {
                        tempArray.append(parsedObject)
                    } else { print("Document was not parsed!!")}
                    
                } else { print ("Document Could not be retrieved!")}
                myGroup.leave()
            }
            // store returned data in array
        }
        // return array of exercise objects
        myGroup.notify(queue: .main) {
            DMDataModel.sharedInstance.examExercises = tempArray
        }
    }
    
    func getExercise(exercise: String, completion: @escaping (DocumentSnapshot?) -> ()) {
        
        // Firebas Download Exercise
        FireXDataManager.shared.retrieveDoc(at: FireXDataManager.shared.dbExercises, documentPath: exercise) { (document) in
            completion(document)
        }
    }
}



