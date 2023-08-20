//
//  ExamInitializerVC.swift
//  Dr Movement
//
//  Created by Abram Andis on 7/4/20.
//  Copyright © 2020 Abram Andis. All rights reserved.
//

import UIKit

class ExamInitializerVC: UIViewController, DMDataModelDelegate {
    var therapist : String?
    var patient : String?
    var selectedRoutine : DMRoutine?
    var routines : [DMRoutine]?
    
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func startButtonPressed(_ sender: Any) {
        guard let selectedRoutine = selectedRoutine else {return}
        // guard let patient = patient else { return }
        // get all exercise data from selected routine
        
        DMDataManager.shared.getExercisesFromRoutine(routine: selectedRoutine)
        // create local object instance of exam data
        // create view controller array
        // do any initial setup
        // segue to first view controller
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // get routines
        DMDataModel.sharedInstance.delegate = self
        DMDataManager.shared.getAllRoutines()
        
        // select routine
        // download exercise from routine
        // get customers
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
       
    }
   
    // protocol methods
    func DMDataModelDidRecieveDataUpdate() {
        print("Data Model Received Update. I will update the Views now.")
        print("ROUTINES:")
        print(DMDataModel.sharedInstance.allRoutines ?? "No routines downloaded.")
        print("EXAMS:")
        print(DMDataModel.sharedInstance.examExercises ?? "No Exam Exercises Downloaded.")
        
        if let downloadedRoutines = DMDataModel.sharedInstance.allRoutines {
            self.routines = downloadedRoutines
            self.selectedRoutine = downloadedRoutines[0]
        }
       
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
