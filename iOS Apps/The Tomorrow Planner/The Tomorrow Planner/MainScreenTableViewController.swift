//
//  MainScreenTableViewController.swift
//  The Tomorrow Planner
//
//  Created by Abram Andis on 4/29/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import UIKit

class MainScreenTableViewController: UITableViewController {
    
    // get the model data
    // right now these are singletons. I want to just 'get the data' later on.
    
    //var tomorrowModel = TPTomorrowClassX.sharedInstance.model
    //var todayModel = TPTodayClassX.sharedInstance.model
    //var futureModel = TPFutureClassX.sharedInstance.model
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.navigationController?.navigationBar.barTintColor = globalUILightGray
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        /* TEST */
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == MainMenuSegueKeys.tomorrow {
            let newVC = segue.destination as! TPPageVC
            //newVC.localContainerModel = self.tomorrowModel
            newVC.dataSourceType = .tomorrow
        }
        if segue.identifier == MainMenuSegueKeys.today {
            let newVC = segue.destination as! TPPageVC
            //newVC.localContainerModel = self.todayModel
            newVC.dataSourceType = .today
            
        }
        if segue.identifier == MainMenuSegueKeys.future {
            let newVC = segue.destination as! TPPageVC
            //newVC.localContainerModel = self.futureModel
            newVC.dataSourceType = .future
            
        }
        if segue.identifier == MainMenuSegueKeys.settings{
            
            
        }
    }
    
}
