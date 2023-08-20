//
//  GlobalCode.swift
//  Dr Movement
//
//  Created by ABRAM ANDIS on 5/9/20.
//  Copyright © 2020 ABRAM ANDIS. All rights reserved.
//

import Foundation
import UIKit

let globalButtonCornerRadius : CGFloat = 10.0
let globalUIPlaceHolderTextColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
let globalUIBackgroundColor1 = UIColor(red: 248/255, green: 245/255, blue: 237/255, alpha: 1)
let globalUIGreen = UIColor(red: 137/255, green: 229/255, blue: 146/255, alpha: 1)
let globalUIYellow = UIColor(red: 255/255, green: 212/255, blue: 0, alpha: 1)
let globalUIRed = UIColor(red: 255/255, green: 73/255, blue: 33/255, alpha: 1)
let globalUIRedOrange = UIColor(red: 229/255, green: 41/255, blue: 27/255, alpha: 1)
//let globalUIDarkReddish = UIColor(red: 196/255, green: 67/255, blue: 11/255, alpha: 1)
let globalUIDarkReddish = UIColor(red: 255/255, green: 120/255, blue: 26/255, alpha: 1)
let globalUITintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1) // black

// MARK: Extensions --->

/*
extension UIButton {
    override open var isEnabled : Bool {
        willSet{
            if newValue == false {
                self.setTitleColor(UIColor.gray, for: UIControlState.disabled)
            }
        }
    }
}
*/
extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // show an alert
    func showAlert(withTitle title:String, message:String, withVC viewController: UIViewController) {
        DispatchQueue.main.async {
            print("showAlertWithView Called")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
            alert.addAction(dismissAction)
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension UIViewController {
    func addDoneButtonOnKeyboard(textField: UITextField?=nil, textView: UITextView?=nil)
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x:0, y:0, width: getWindowWidth(), height:50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.isUserInteractionEnabled = true
        doneToolbar.sizeToFit()
        
        if let textField = textField {
            textField.inputAccessoryView = doneToolbar
        }
        if let textView = textView {
            textView.inputAccessoryView = doneToolbar
        }
    }
    
    @objc func doneButtonAction()
    {
        view.endEditing(true)
    }
}

extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    
    func asImage() -> UIImage? {
        // only available on ios 10
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
            
        }
    }
    
}

func getWindowHeight() -> CGFloat {
    return UIScreen.main.bounds.size.height
}

func getWindowWidth() -> CGFloat {
    return UIScreen.main.bounds.size.width
}

func isValidCharacterString(candidate: String) -> Bool {
    // \\S S is a negative lookahead that looks for a string that is only white space characters
    let charactersOrNumbersRegex: String = ".*\\S.*"
    return NSPredicate(format: "SELF MATCHES %@", charactersOrNumbersRegex).evaluate(with: candidate)
}

func isValidNumber(candidate: String) -> Bool {
    // ^ is beginning of string, $ is end of string, [0-9] matches numbers, {1, } is between 1 and X numbers long
    let numbersOnlyRegex: String = "^([0-9]){1,}$"
    return NSPredicate(format: "SELF MATCHES %@", numbersOnlyRegex).evaluate(with: candidate)
}

func isValidPhoneNumber(candidate: String) -> Bool {
    // ^ is beginning of string, $ is end of string, [0-9] matches numbers, {10,11} between 10-11 digits long
    let numbersOnlyRegex: String = "^([0-9]{10,10})$"
    return NSPredicate(format: "SELF MATCHES %@", numbersOnlyRegex).evaluate(with: candidate)
}

func isValidPassword(candidate: String) -> Bool {
    let passwordRegex: String = "(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{6,}"
    return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: candidate)
}

func isValidEmail(candidate: String) -> Bool {
    // this email Regex doesn't catch all bad scenarios. Modify.
    let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
}

struct Constants {
    
    struct NotificationKeys {
        static let SignedIn = "onSignInCompleted"
    }
    
    struct Segues {
        static let SignInToFp = "SignInToFP"
        static let FpToSignIn = "FPToSignIn"
        static let SignInToRH = "SignInToRH"
        static let SignInSegue = "SignInSegue"
    }
    
    struct MessageFields {
        static let name = "name"
        static let text = "text"
        static let photoURL = "photoURL"
        static let imageURL = "imageURL"
    }
    
}

// CLASSES

class GradientColors {
    var gl:CAGradientLayer!
    
    init() {
        //let colorTop = UIColor(red: 192.0 / 255.0, green: 38.0 / 255.0, blue: 42.0 / 255.0, alpha: 1.0).cgColor
        //let colorBottom = UIColor(red: 35.0 / 255.0, green: 2.0 / 255.0, blue: 2.0 / 255.0, alpha: 1.0).cgColor
        
        let colorTop = UIColor.black.cgColor
        let colorBottom = UIColor(red: 22.0 / 255.0, green: 22.0 / 255.0, blue: 22.0 / 255.0, alpha: 1.0).cgColor
        
        self.gl = CAGradientLayer()
        self.gl.colors = [colorTop, colorBottom]
        self.gl.locations = [0.0, 1.0]
    }
}

// MARK: ---> FONTS
func printAllFontNames() {
    
    for family: String in UIFont.familyNames
    {
        print("\(family)")
        for names: String in UIFont.fontNames(forFamilyName: family)
        {
            print("== \(names)")
        }
    }
    
}

func getAllFontNamesArray() -> [String] {
    
    var fontNamesArray : [String] = []
    
    for family: String in UIFont.familyNames
    {
        for names: String in UIFont.fontNames(forFamilyName: family)
        {
            fontNamesArray.append(names)
        }
        
    }
    return fontNamesArray
}


// MARK: <--- FONTS

// MARK: ---> SEGMENTED CONTROL STYLING
extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: backgroundColor ?? globalUITintColor), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: tintColor!), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}


// MARK: <--- SEGMENTED CONTROL STYLING
