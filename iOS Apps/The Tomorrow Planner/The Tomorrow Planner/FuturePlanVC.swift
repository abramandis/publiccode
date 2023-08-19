//
//  FuturePlanVC.swift
//  The Tomorrow Planner
//
//  Created by Abram Andis on 7/2/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import UIKit

class FuturePlanVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    //let storyBoardID : String = "FutureStacker"
    var mainTitle : String = ""
    // index of the model data this VC refers too.. this is used to save data
    // better way?
    var mainIndex : Int!
    var runOnce = true
    var keyboardHeight : CGFloat = KeyboardService.keyboardHeight()
    var textViewArray : [UITextView] = []
    var titleLabelArray : [UILabel] = []
    
    var modelObjectArray : [TPObject] = []
    
    //var localModel = TPFutureClass.sharedInstance.futureModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // BUG (when app is left on overnight the data model doesn't refresh)
        
        // reset local data arrays
        titleLabelArray = [UILabel]()
        textViewArray = [UITextView]()
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.largeTitleDisplayMode = .automatic
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // create and add subviews to stackView
        if runOnce{
            for modelObject in TPFutureClass.sharedInstance.futureModel.dataArray[mainIndex].dataArray {
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
                label.text = modelObject.title
                
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
                newTextView.text = modelObject.text
                newTextView.textAlignment = .left
                newTextView.font = globalUITextViewFont
                newTextView.textColor = UIColor.black
                textViewArray.append(newTextView)
                stackView.addArrangedSubview(newTextView)
            }
            // set scrollView insets so they aren't under the keyboard
            self.scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
            runOnce = false
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        print("performing segue..........")
        // fixes a bug when keyboard is visible and moving into next view controller
        self.view.endEditing(true)
        return true
    }
}

extension FuturePlanVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView){
        // shrink scroll indicator
        let scrollIndicatorInsetsShort = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        self.scrollView.scrollIndicatorInsets = scrollIndicatorInsetsShort
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        // grow scroll indicator
        let scrollIndicatorInsetsLong = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.scrollView.scrollIndicatorInsets = scrollIndicatorInsetsLong
        self.view.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // change model data to reflect new inputed text
        for (index, textViewInArray) in textViewArray.enumerated() {
            if textView == textViewInArray {
                TPFutureClass.sharedInstance.futureModel.dataArray[self.mainIndex].dataArray[index].text = textView.text
            }
        }
    }
}
