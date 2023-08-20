//
//  ExamViewController.swift
//  Dr Movement
//
//  Created by ABRAM ANDIS on 5/16/20.
//  Copyright © 2020 ABRAM ANDIS. All rights reserved.
//

import UIKit
import Firebase

class ExamViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        print("Go For It")
        // create an exam
        var date = Date()
        var patient = "THINKGIANT MAN"
        var routine = "ROUTINE55"
        var scores = [5,8,19,13]
        var therapistID = userID
        var totalScore = 15
        var clinic = "Montana"
        
        var exam : DMExam = DMExam(date: date, patientID: patient, routine: routine, scores: scores, therapistID: therapistID, totalScore: totalScore, clinic: clinic)
        
        // add an exam
        DMDataManager.shared.saveExam(exam: exam)
        
        // get exams
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            DMDataManager.shared.getExams()
        }
        

        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
