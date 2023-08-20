//
//  AppState.swift
//  Dr Movement
//
//  Created by ABRAM ANDIS on 5/9/20.
//  Copyright © 2020 ABRAM ANDIS. All rights reserved.
//

import Foundation
import UIKit

class AppState: NSObject {
    
    static let sharedInstance = AppState()
    var signedIn = false
    var displayName: String?
    var photoURL: URL?
    
}
