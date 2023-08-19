//
//  NotepadVC.swift
//  The Tomorrow Planner
//
//  Created by ABRAM ANDIS on 8/22/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import UIKit


class NotepadVC: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @objc func onTapGesture(touch: UITapGestureRecognizer){
        if touch.state == .ended {
            textView.isEditable = true
            textView.becomeFirstResponder()

            let location = touch.location(in: textView)
            if let position = textView.closestPosition(to: location) {
                let uiTextRange = textView.textRange(from: position, to: position)

                if let start = uiTextRange?.start, let end = uiTextRange?.end {
                    let loc = textView.offset(from: textView.beginningOfDocument, to: position)
                    let length = textView.offset(from: start, to: end)

                    textView.selectedRange = NSMakeRange(loc, length)

                }
            }
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.textView.isEditable = false
        self.textView.resignFirstResponder()
    }
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    
    var tapGesture : UITapGestureRecognizer?
    var runOnce = true
    var keyboardHeight : CGFloat = KeyboardService.keyboardHeight()
    // must set from previous VC
    var dataSourceIndex : Int?
    var dataSourceNotes : String?
    var dataSourceType : DataSourceEnum?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialize
        fetchModelData()
        
        // initialize gesture recognizer
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(touch:)))
        textView.addGestureRecognizer(tapGesture!)
        
        // hide done button
        self.doneButton.isEnabled = false
        self.doneButton.tintColor = UIColor.clear
        
        // setup text view
        textView.delegate = self
        textView.isScrollEnabled = true
        textView.bounces = true
        textView.backgroundColor = UIColor.white
        textView.textAlignment = .left
        textView.font = globalUITextViewFont
        textView.textColor = UIColor.black
        textView.isEditable = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // initialize
        fetchModelData()
        
        // set textView container inset
        textView.textContainerInset = UIEdgeInsets(top: 24.0, left: 16.0, bottom: 0.0, right: 16.0)
        
        // set textView content insets so they aren't under the keyboard
        if runOnce {
            print("setting textView insets")
            self.textView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
            runOnce = false
        }
        textView.setNeedsLayout()
        textView.setNeedsDisplay()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
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
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("notepad textViewDidEndEditing")
        // hide done button
        self.doneButton.isEnabled = false
        self.doneButton.tintColor = UIColor.clear
        
        // make scroll indicator go to bottom of screen
        let scrollIndicatorInsetsLong : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.textView.scrollIndicatorInsets = scrollIndicatorInsetsLong
        self.textView.isEditable = false 
        self.view.endEditing(true)
        
    }

    func textViewDidChange(_ textView: UITextView) {
        // update model
        //TPTomorrowClass.sharedInstance.tomorrowModel.dataArray[dataSourceIndex!].notes = textView.text
        print("Text View CHNGED)")
        updateModelData(text: textView.text)
    }
    
    
    
    func fetchModelData(){
        if dataSourceType != nil {
            switch dataSourceType {
            case .tomorrow:
                // !!!!!unwrapping optional here!!!!!
                print("BLAST OFF!!!!")
                textView.text = TPTomorrowClass.sharedInstance.tomorrowModel.dataArray[dataSourceIndex!].notes
            case .today:
                textView.text = TPTodayClass.sharedInstance.todayModel.data.notes
            case .future:
                //TPFutureClass.sharedInstance.futureModel.dataArray[dataSourceIndex!].notes = textView.text
                print("Notes have not been implemented in the FUTURE model")
            default:
                print("NotepadVC: UNKNOWN LOCATION OF MODEL DATA; CANNOT UPDATEMODELDATA()")
            }
        }
    }
    
    func updateModelData(text: String){
        if dataSourceType != nil {
            switch dataSourceType {
            case .tomorrow:
                // !!!!!unwrapping optional here!!!!!
                print("BLAST OFF!!!!")
                TPTomorrowClass.sharedInstance.tomorrowModel.dataArray[dataSourceIndex!].notes = textView.text
            case .today:
                TPTodayClass.sharedInstance.todayModel.data.notes = textView.text
            case .future:
                //TPFutureClass.sharedInstance.futureModel.dataArray[dataSourceIndex!].notes = textView.text
                print("Notes have not been implemented in the FUTURE model")
            default:
                print("NotepadVC: UNKNOWN LOCATION OF MODEL DATA; CANNOT UPDATEMODELDATA()")
            }
        }
    }
}
