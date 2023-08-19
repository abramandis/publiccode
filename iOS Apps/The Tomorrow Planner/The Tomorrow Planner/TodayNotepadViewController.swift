//
//  TodayNotepadViewController.swift
//  The Tomorrow Planner
//
//  Created by Abram Andis on 6/15/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import UIKit

class TodayNotepadViewController: UIViewController, UITextViewDelegate {
    
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.textView.resignFirstResponder()
    }
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    
    var runOnce = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.text = TPTodayClass.sharedInstance.todayModel.data.notes
        registerForKeyboardNotifications()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        textView.becomeFirstResponder()
        textView.textContainerInset = UIEdgeInsets(top: 24.0, left: 16.0, bottom: 0.0, right: 16.0)
        textView.setNeedsLayout()
        textView.setNeedsDisplay()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        textView.becomeFirstResponder()
        // resigns because this is todays notes
        // primarily meant for READING not CREATING
        if TPTodayClass.sharedInstance.todayModel.data.notes != "" {
            textView.resignFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        deregisterFromKeyboardNotifications()
        
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name:
            UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: Notification){
        
        print("KEYBOARD WAS SHOWN!!!")
        // show done button
        self.doneButton.isEnabled = true
        self.doneButton.tintColor = nil
        
        // get keyboard height and set contentInset
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: ((keyboardSize?.height ?? CGFloat(256)) + CGFloat(8)), right: 0.0)
        
        // handles scenario where keyboard size returns 0
        if let size = keyboardSize {
            if size.height >= CGFloat(32.0) {
                if runOnce {
                    self.textView.contentInset = contentInsets
                    runOnce = false
                    self.textView.setNeedsLayout()
                    self.textView.setNeedsDisplay()
                }
            }
            
        }
        
        //self.textView.contentInset = contentInsets
        self.textView.scrollIndicatorInsets = contentInsets
        self.textView.setNeedsLayout()
        self.textView.setNeedsDisplay()
    }
    
    @objc func keyboardWillBeHidden(notification: Notification){
        
        // hide done button
        self.doneButton.isEnabled = false
        self.doneButton.tintColor = UIColor.clear
        
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        //self.textView.contentInset = contentInsets
        self.textView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("notepad textViewDidEndEditing")
        TPTodayClass.sharedInstance.todayModel.data.notes = textView.text
        saveTodayModel()
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
