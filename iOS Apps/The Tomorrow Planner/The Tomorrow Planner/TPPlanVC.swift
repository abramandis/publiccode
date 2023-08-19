//
//  TPPlanVC.swift
//  The Tomorrow Planner
//
//  Created by ABRAM ANDIS on 8/23/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import UIKit

class TPPlanVC: UIViewController {

    // MARK: - Variables
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    var pageDelegate : TPPageVCNavItemDelegate?
    //var localObjectStack : [TPObjectX]!
    var dataSourceType : DataSourceEnum!
    var mainIndex : Int!
    var textViewArray : [UITextView] = []
    var titleLabelArray : [UILabel] = []
    var mainTitle : String = ""
    var runOnce = true
    var keyboardHeight : CGFloat = KeyboardService.keyboardHeight()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialize
        //scrollView.translatesAutoresizingMaskIntoConstraints = false
        //stackView.translatesAutoresizingMaskIntoConstraints = false
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = globalUILightGray
        
        // reset local data arrays
        titleLabelArray = [UILabel]()
        textViewArray = [UITextView]()

        // create and add subviews to stackView
        if runOnce {
            for object in getModelPlanData(type: dataSourceType, planArrayIndex: mainIndex).objectStack {
                
                
                // create title labels
                let title = UILabel()
                title.backgroundColor = .clear
                title.textColor = UIColor.gray
                title.font = .systemFont(ofSize: 16)
                title.textAlignment = .left
                title.text = object.title
                titleLabelArray.append(title)
                
                // create header view
                let headerView = UIView()
                headerView.translatesAutoresizingMaskIntoConstraints = false
                headerView.heightAnchor.constraint(equalToConstant: 64).isActive = true
                headerView.backgroundColor = globalUILightGray
                headerView.addSubview(title)
                stackView.addArrangedSubview(headerView)
                
                title.sizeToFit()
                title.frame = CGRect(x: 20, y: 64 - title.frame.height - 8, width: title.frame.width, height: title.frame.height)
                
                // create text views
                let newTextView = PaddedTextView()
                //newTextView.translatesAutoresizingMaskIntoConstraints = false
                newTextView.delegate = self
                newTextView.isScrollEnabled = false
                newTextView.backgroundColor = UIColor.white
                //newTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 256.0).priority = UILayoutPriority(rawValue: 999)
                //newTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 256.0).isActive = true
                newTextView.text = object.text
                newTextView.textAlignment = .left
                newTextView.font = globalUITextViewFont
                newTextView.textColor = UIColor.black
                textViewArray.append(newTextView)
                resize(textView: newTextView)
                stackView.addArrangedSubview(newTextView)
            }
            // set contentInsets
            self.scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
            runOnce = false
        }
            
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        for view in self.stackView.arrangedSubviews {
            //view.translatesAutoresizingMaskIntoConstraints = false
            //view.heightAnchor.constraint(greaterThanOrEqualToConstant: 256.0).isActive = true
        }
    }
 
    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
           print("performing segue..........")
           // fixes a bug when keyboard is visible and moving into next view controller
           self.view.endEditing(true)
           return true
       }

}

// MARK: - UITextViewDelegate

extension TPPlanVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView){
        self.pageDelegate?.toggleKeyboardIsDisplayed()
        
        // shrink scroll indicator
        let scrollIndicatorInsetsShort = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        self.scrollView.scrollIndicatorInsets = scrollIndicatorInsetsShort
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        self.pageDelegate?.toggleKeyboardIsDisplayed()
        
        // grow scroll indicator
        let scrollIndicatorInsetsLong = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.scrollView.scrollIndicatorInsets = scrollIndicatorInsetsLong
        self.view.endEditing(true)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // update model data
        for (index, textViewInArray) in textViewArray.enumerated() {
            if textView == textViewInArray {
                let foundIndex = index
                updateModelStackText(type: self.dataSourceType, pageIndex: self.mainIndex, stackIndex: foundIndex , text: textView.text)
            }
        }
    }
}

// MARK: - Private Functions

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
}
