//
//  DMObjects.swift
//  Dr Movement
//
//  Created by Abram Andis on 7/4/20.
//  Copyright © 2020 Abram Andis. All rights reserved.
//

import Foundation


public struct DMExam: Codable {

    let date: Date
    let patientID: String
    let routine: String
    let scores : [Int]
    let therapistID: String
    let totalScore : Int
    let clinic : String
    

    enum CodingKeys: String, CodingKey {
        case date
        case patientID
        case routine
        case scores
        case therapistID
        case totalScore
        case clinic
    }

}

public struct DMRoutine: Codable {

    let id: String
    let description: String
    let exercises: [String]
    let imageURL: URL?
    let clinic : String?
    

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case exercises
        case imageURL
        case clinic
    }

}

public struct DMExercise: Codable {

    let id: String
    let title: String
    let description: String
    let imageURL: URL?
    let clinic : String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case imageURL
        case clinic
    }

}


