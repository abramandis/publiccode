//
//  FirestoreServices.swift
//  Dr Movement
//
//  Created by Abram Andis on 7/4/20.
//  Copyright © 2020 Abram Andis. All rights reserved.
//

import Foundation
import Firebase

// MARK: --> TPDataManager Class

class FireXDataManager: NSObject {
    
    let db = Firestore.firestore()
    let dbExams : CollectionReference
    let dbRoutines : CollectionReference
    let dbExercises : CollectionReference
    // Init Singleton
    class var shared: FireXDataManager {
        struct Singleton {
            static let instance = FireXDataManager()
        }
        return Singleton.instance
    }

    override init() {
        dbExams = self.db.collection(FirestoreConstants.ExamResults)
        dbRoutines = self.db.collection(FirestoreConstants.ExerciseRoutines)
        dbExercises = self.db.collection(FirestoreConstants.Exercises)
        super.init()
        
    }
    
    // MARK: - FUNCTIONS
    
    func getExams(){
        
        
    }
    
    func parse<T: Codable>(querySnapshot: QuerySnapshot, as type: T.Type) -> [T]? {
        // Parse Query Snapshot into Objects
        var tempArray : [T] = []
        for document in querySnapshot.documents {
            print("\(document.documentID) => \(document.data())")
            let result = Result {
                try document.data(as: type)
            }
            switch result {
            case .success(let object):
                if let object = object {
                    // A `Object` value was successfully initialized from the DocumentSnapshot.
                    print("Object: \(object)")
                    tempArray.append(object)
                } else {
                    // A nil value was successfully initialized from the DocumentSnapshot,
                    // or the DocumentSnapshot was nil.
                    print("Document does not exist")
                }
            case .failure(let error):
                // A `DMExam` value could not be initialized from the DocumentSnapshot.
                print("Error decoding Object: \(error)")
            }
        }
        if !tempArray.isEmpty {
            return tempArray
        } else {
            return nil
        }
        
    }
    
    func parse<T: Codable>(document: DocumentSnapshot?, as type: T.Type) -> T? {
        // Parse DocumentSnapshot into Objects
        let result = Result {
            try document?.data(as: type)
        }
        switch result {
        case .success(let object):
            if let object = object {
                // A `Object` value was successfully initialized from the DocumentSnapshot.
                print("Object: \(object)")
                return object
            } else {
                // A nil value was successfully initialized from the DocumentSnapshot,
                // or the DocumentSnapshot was nil.
                print("Document does not exist")
                return nil
            }
        case .failure(let error):
            // A `DMExam` value could not be initialized from the DocumentSnapshot.
            print("Error decoding Object: \(error)")
            return nil
        }
    }
    
    func retrieveAllDocs(at collection: CollectionReference, _ completion: @escaping (QuerySnapshot?) -> ()) {
        
        collection.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                completion(querySnapshot)
            }
        }
    }
    
    func retrieveDoc(at collection: CollectionReference, documentPath: String, _ completion: @escaping (DocumentSnapshot?) -> ()) {
        
        let docRef = collection.document(documentPath)
        docRef.getDocument { (document, err) in
            
            if let err = err {
                print("Error getting document: \(err)")
            } else {
                completion(document)
            }
            
            
        }
        
    }
}
