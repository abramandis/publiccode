//
//  NotepadViewController.swift
//  The Tomorrow Planner
//
//  Created by Abram Andis on 6/14/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import UIKit
import Foundation

class NotepadViewController: UIViewController, UITextViewDelegate {
    
    // Button Action
    func onDone(sender: AnyObject) {
        self.textView.resignFirstResponder()
    }
    
    // variables
    var textView = PaddedTextView()
    var doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: Selector("onDone:"))
    var runOnce = true
    let keyboardHeight = KeyboardService.keyboardHeight()
    var dataSourceIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add a done button to the navigation bar
        self.navigationItem.rightBarButtonItem = doneButton
        
        // hide done button
        self.doneButton.isEnabled = false
        self.doneButton.tintColor = UIColor.clear
        
        // setup text view
        textView.isScrollEnabled = true
        textView.bounces = true
        textView.backgroundColor = UIColor.white
        
        textView.text = TPTomorrowClass.sharedInstance.tomorrowModel.dataArray[dataSourceIndex!].notes
        textView.textAlignment = .left
        textView.font = globalUITextViewFont
        textView.textColor = UIColor.black
        textView.delegate = self
        self.textView.text = ""
        self.view.addSubview(textView)
        
        // constraints
        /*
        textView.widthAnchor.constraint(equalToConstant: 0).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        textView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        textView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        */
        
        textView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeLeadingAnchor, multiplier: 1).isActive = true
        textView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeTrailingAnchor, multiplier: 1).isActive = true
        textView.topAnchor.constraint(equalToSystemSpacingBelow: self.view.topAnchor, multiplier: 1).isActive = true
        textView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.view.bottomAnchor, multiplier: 1).isActive = true 
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // called here so the textContainerInsets are present when view appears the first time
        textView.textContainerInset = UIEdgeInsets(top: 24.0, left: 16.0, bottom: 0.0, right: 16.0)
        
        // set textView insets so they aren't under the keyboard
        if runOnce {
            print("setting textView insets")
            self.textView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
            runOnce = false
        }
        
        textView.setNeedsLayout()
        textView.setNeedsDisplay()
        textView.becomeFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
        // show done button
        self.doneButton.isEnabled = true
        self.doneButton.tintColor = nil
        
        let scrollIndicatorInsetsShort : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        
        // shrink scroll indicator insets when keyboard present
        self.textView.scrollIndicatorInsets = scrollIndicatorInsetsShort
        self.textView.setNeedsLayout()
        self.textView.setNeedsDisplay()
        print(keyboardHeight)
        
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        print("TEXT VIEW ENDED EDIT")
        
        // hide done button
        self.doneButton.isEnabled = false
        self.doneButton.tintColor = UIColor.clear
        
        // make scroll indicator go to bottom of screen
        let scrollIndicatorInsetsLong : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.textView.scrollIndicatorInsets = scrollIndicatorInsetsLong
        self.view.endEditing(true)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // update model
        TPTomorrowClass.sharedInstance.tomorrowModel.dataArray[self.dataSourceIndex!].notes = textView.text
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
