//
//  LaunchScreenViewController.swift
//  The Tomorrow Planner
//
//  Created by Abram Andis on 6/5/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import Foundation
import UIKit

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        logoImageView.layer.masksToBounds = true
        logoImageView.layer.cornerRadius = logoImageView.frame.width / 2
        
    }
    
}
