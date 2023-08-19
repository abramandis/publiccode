//
//  TPMainMenuTVC.swift
//  The Tomorrow Planner
//
//  Created by ABRAM ANDIS on 8/25/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//  1986 - 2018 Average Force of a Handshake
//  118 -> 96 men
//  96 -> 108 women

import UIKit

public struct MainMenuSegueKeys {
    static let tomorrow = "TomorrowSegue"
    static let today = "TodaySegue"
    static let future = "FutureSegue"
    static let settings = "SettingSegue"
}

class TPMainMenuTVC: UITableViewController {

    // MARK: - Variables
    
    // MARK: - Begin viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.navigationController?.navigationBar.barTintColor = globalUILightGray
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
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
            newVC.title = "Today"
        }
        if segue.identifier == MainMenuSegueKeys.future {
            let newVC = segue.destination as! TPPageVC
            //newVC.localContainerModel = self.futureModel
            newVC.dataSourceType = .future
            
        }
        if segue.identifier == MainMenuSegueKeys.settings{
            
            
        }
    }

    /* !!!! THIS CODE IS FOR GETTING RID OF STORYBOARD !!!! And using dependency injection... too much work !!!!
     
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            return
        }
        if indexPath.section == 1 {
            navToInstantiatedVC(menuVCArray[indexPath.section - 1])
        }
        if indexPath.section == 2 {
           navToInstantiatedVC(menuVCArray[indexPath.section - 1])
        }
        if indexPath.section == 3 {
            navToInstantiatedVC(menuVCArray[indexPath.section - 1])
        }
        if indexPath.section == 4 {
            navToInstantiatedVC(menuVCArray[indexPath.section - 1])
        }
        
    }
    
    
    // MARK: - Functions
    
    private func newVCFromStoryboard(storyboardID: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: storyboardID)
    }
    
    private func navToInstantiatedVC(_ viewController: UIViewController){
        self.navigationController!.pushViewController(viewController, animated: true)
    }

    // creates the view controllers
    private(set) lazy var menuVCArray: [UIViewController] = {
        var newArray : [UIViewController] = []
        // dependency injection here:
        // create tomorrow VC
        let tomorrowVC = self.newVCFromStoryboard(storyboardID: "TPPageVC") as! TPPageVC
        tomorrowVC.dataSourceType = DataSourceEnum.tomorrow
        newArray.append(tomorrowVC)
        
        // create today VC
        let todayVC = self.newVCFromStoryboard(storyboardID: "TPPageVC") as! TPPageVC
        todayVC.dataSourceType = DataSourceEnum.today
        newArray.append(todayVC)
        
        // create future VC
        let futureVC = self.newVCFromStoryboard(storyboardID: "TPPageVC") as! TPPageVC
        futureVC.dataSourceType = DataSourceEnum.future
        newArray.append(futureVC)
        
        // create settings VC
        let settingsVC = self.newVCFromStoryboard(storyboardID: "SettingsVC")
        newArray.append(settingsVC)
        return newArray
    }()
 */
}
    
    
    
    
    
    
    
    
    
   
