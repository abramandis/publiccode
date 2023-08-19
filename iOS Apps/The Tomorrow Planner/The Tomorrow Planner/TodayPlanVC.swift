//
//  TodayPlanVC.swift
//  The Tomorrow Planner
//
//  Created by Abram Andis on 7/19/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import UIKit

class TodayPlanVC: UIViewController {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBAction func barButtonPressed(_ sender: Any) {
        if self.editingText {
            print("BOOM")
            self.view.endEditing(true)
        } else {
            print("TESTING TINGINTINGINGINIG")
            self.performSegue(withIdentifier: "TodayNotesSegue", sender: self)
        }
    }
    
    let dataSourceNotes = TPTodayClass.sharedInstance.todayModel.data.notes
    let storyBoardID : String = "TodayStacker"
    var mainTitle : String = TPTodayClass.sharedInstance.todayModel.data.title
    var data : [TPObject] = TPTodayClass.sharedInstance.todayModel.data.dataArray
    
    var runOnce = true
    var keyboardHeight : CGFloat = KeyboardService.keyboardHeight()
    var textViewArray : [UITextView] = []
    var titleLabelArray : [UILabel] = []
    var editingText : Bool = false {
        didSet {
            if editingText {
                barButton.title = "Done"
            } else {
                barButton.title = "Notepad"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // BUG (when app is left on overnight the data model doesn't refresh)
        
        self.navigationController?.navigationBar.barTintColor = globalUILightGray
        // reset local data arrays
        titleLabelArray = [UILabel]()
        textViewArray = [UITextView]()
        
        self.barButton.title = "Notepad"
        
        // create and add subviews to stackView
        if runOnce {
            for object in data {
                        
                        // create title labels
                        let headerView = UIView()
                        headerView.translatesAutoresizingMaskIntoConstraints = false
                        headerView.heightAnchor.constraint(equalToConstant: 64).isActive = true
                        headerView.backgroundColor = globalUILightGray
                        
                        let label = UILabel()
                        //let label = UILabel(frame: CGRect(x: 16, y: 0, width: view.frame.width, height: 60))
                        label.backgroundColor = .clear
                        label.textColor = UIColor.gray
                        label.font = .systemFont(ofSize: 16)
                        label.textAlignment = .left
                        label.text = object.title
                        
                        titleLabelArray.append(label)
                        headerView.addSubview(label)
                        stackView.addArrangedSubview(headerView)
                        
                        label.sizeToFit()
                        label.frame = CGRect(x: 20, y: 64 - label.frame.height - 8, width: label.frame.width, height: label.frame.height)
                        
                        // create text views
                        let newTextView = PaddedTextView()
                        newTextView.delegate = self
                        newTextView.isScrollEnabled = false
                        newTextView.backgroundColor = UIColor.white
                        newTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 256.0).isActive = true
                        
                        newTextView.text = object.text
                        newTextView.textAlignment = .left
                        newTextView.font = globalUITextViewFont
                        newTextView.textColor = UIColor.black
                        textViewArray.append(newTextView)
                        newTextView.delegate = self
                        
                        stackView.addArrangedSubview(newTextView)
            }
                    
            // set scrollView insets so they aren't under the keyboard
            print("setting textView insets")
            self.scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
            runOnce = false
            print(keyboardHeight)
            
        }
        
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        self.view.setNeedsLayout()
        print("TODAY: View did LOAD")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.setNeedsLayout()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        saveTodayModelWithCompletion(completionHandler: { (success) -> Void in
            print("Today: saved today model")
        })
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        print("performing segue..........")
        // fixes a bug when keyboard is visible and moving into next view controller
        self.view.endEditing(true)
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newNotesVC = segue.destination as? NotepadVC {
            newNotesVC.dataSourceNotes = self.dataSourceNotes
            newNotesVC.dataSourceType = .today
        }
    }
    
}

extension TodayPlanVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView){
        // shrink scroll indicator
        let scrollIndicatorInsetsShort = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        self.scrollView.scrollIndicatorInsets = scrollIndicatorInsetsShort
        self.toggleKeyboardIsDisplayed()
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        // grow scroll indicator
        let scrollIndicatorInsetsLong = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.scrollView.scrollIndicatorInsets = scrollIndicatorInsetsLong
        self.view.endEditing(true)
        self.toggleKeyboardIsDisplayed()
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // change model data to reflect new inputed text
        for (index, textViewInArray) in textViewArray.enumerated() {
            if textView == textViewInArray {
                TPTodayClass.sharedInstance.todayModel.data.dataArray[index].text = textView.text
            }
        }
    }
    
    fileprivate func resize(textView: UITextView) {
        var newFrame = textView.frame
        let width = newFrame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: width,
                                                   height: CGFloat.greatestFiniteMagnitude))
        newFrame.size = CGSize(width: width, height: newSize.height)
        textView.frame = newFrame
        let minViewHeight : CGFloat = 256
        if newSize.height >= minViewHeight {
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: newSize.height).isActive = true
        }
        textView.layoutIfNeeded()
        print(newSize.height)
        
    }
    
    func toggleKeyboardIsDisplayed() {
        print("TOGGLE KEYBOARD CALLED!!!")
        editingText.toggle()
    }
}
