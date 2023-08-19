//
//  TPNotepadVC.swift
//  The Tomorrow Planner
//
//  Created by ABRAM ANDIS on 8/24/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import UIKit

class TPNotepadVC: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate  {

    // MARK: - Tap Gesture
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
    // MARK: - Outlets
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.textView.isEditable = false
        self.textView.resignFirstResponder()
    }
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    // MARK: - Variables

    var tapGesture : UITapGestureRecognizer?
    var runOnce = true
    var keyboardHeight : CGFloat = KeyboardService.keyboardHeight()
    // must set from previous VC
    var dataSourceType : DataSourceEnum!
    var dataSourceIndex : Int!
    //var dataSourceNotes : String!
    var editingText : Bool = false {
        didSet {
            // update UI nav buttons
            if editingText {
                self.doneButton.isEnabled = true
                self.doneButton.tintColor = nil
            } else {
                self.doneButton.isEnabled = false
                self.doneButton.tintColor = UIColor.clear
            }
        }
    }
    
    // testing X
    var tpPageDelegate : dataUpdaterXDelegate?

// MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = getModelPlanData(type: dataSourceType, planArrayIndex: dataSourceIndex).notes
        // initialize gesture recognizer
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(touch:)))
        textView.addGestureRecognizer(tapGesture!)
        // initalize done button
        doneButton.title = "Done"
        if editingText {
            self.doneButton.isEnabled = true
            self.doneButton.tintColor = nil
        } else {
            self.doneButton.isEnabled = false
            self.doneButton.tintColor = UIColor.clear
        }
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
        textView.text = getModelPlanData(type: dataSourceType, planArrayIndex: dataSourceIndex).notes
        // set textContainerInset
        textView.textContainerInset = UIEdgeInsets(top: 24.0, left: 16.0, bottom: 0.0, right: 16.0)
        // set contentInset
        if runOnce {
            self.textView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
            runOnce = false
        }
        textView.setNeedsLayout()
        textView.setNeedsDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }

    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.editingText.toggle()
        
        // shrink scroll indicator insets when keyboard present
        let scrollIndicatorInsetsShort : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        self.textView.scrollIndicatorInsets = scrollIndicatorInsetsShort
        self.textView.setNeedsLayout()
        self.textView.setNeedsDisplay()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.editingText.toggle()
        // make scroll indicator go to bottom of screen
        let scrollIndicatorInsetsLong : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.textView.scrollIndicatorInsets = scrollIndicatorInsetsLong
        self.textView.isEditable = false
        self.view.endEditing(true)
        
    }

    func textViewDidChange(_ textView: UITextView) {
        // update model
        updateModelNotes(type: dataSourceType, pageIndex: dataSourceIndex, text: textView.text)
        tpPageDelegate?.someoneCallThisFunction(text: textView.text)
    }

}
