//
//  GlobalCode.swift
//  The Tomorrow Planner
//
//  Created by Abram Andis on 4/23/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import Foundation
//import Firebase
//import FirebaseFirestore
import UIKit
import MapKit
import Contacts

// START MADGO SPECIFIC
/*
struct MadGoPurchaseOrder {
    
    var documentID: String!
    var customerID: String
    var address: String
    var location: GeoPoint
    var orderTime: Date
    var deliveredTime: Date
    var linkedDriverID: String
    var items: AnyObject // this is an array of inventory objects and amounts. Should have its own 'struct'
    var status: String
    
    var asDictionary: [String: Any] {
        return ["documentID": documentID,
                "customerID": customerID,
                "address": address,
                "location": location,
                "orderTime": orderTime,
                "deliveredTime": deliveredTime,
                "linkedDriverID": linkedDriverID,
                "items": items,
                "status": status]
    }
}

// Extend MadGoPurchaseOrder Model to include FirestoreModel
extension MadGoPurchaseOrder: FirestoreModel {
    
    init?(modelData: FirestoreModelData) {
        
        try? self.init(documentID: modelData.documentID,
                       customerID: modelData.value(forKey: "customerID"),
                       address: modelData.value(forKey: "address"),
                       location: modelData.value(forKey: "location"),
                       orderTime: modelData.value(forKey: "orderTime"),
                       deliveredTime: modelData.value(forKey: "deliveredTime"),
                       linkedDriverID: modelData.value(forKey: "linkedDriverID"),
                       items: modelData.value(forKey: "items"),
                       status: modelData.value(forKey: "status")
            
        )
        
    }
}

class MadGoAnnotation: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let status : String
    let coordinate: CLLocationCoordinate2D
    let purchaseOrderID : String
    
    init(title: String, locationName: String, status: String, coordinate: CLLocationCoordinate2D, purchaseOrderID : String) {
        self.title = title
        self.locationName = locationName
        self.status = status
        self.coordinate = coordinate
        self.purchaseOrderID = purchaseOrderID
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    // Annotation right callout accessory opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}



/// END MADGO SPECIFIC ///
*/

// THE TOMORROW PLANNER UI

// Bodoni 72 Smallcaps == BodoniSvtyTwoSCITCTT-Book
var globalUITextViewFont : UIFont = UIFont(name: "Bodoni 72 Smallcaps", size: 28) ?? .systemFont(ofSize: 18)
let globalUILightGray = UIColor(red: 251/255, green: 250/255, blue: 248/255, alpha: 1)
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

// adjusts large title size to FIT
// examine for errors
extension UIViewController {
    
    func adjustLargeTitleSize() {
        guard let title = title, #available(iOS 11.0, *) else { return }
        
        let maxWidth = UIScreen.main.bounds.size.width - 60
        var fontSize = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
        var width = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]).width
        
        while width > maxWidth {
            fontSize -= 1
            width = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]).width
        }
        
        navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontSize)
        ]
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

extension UIView {
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        }
        return self.topAnchor
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leftAnchor
        }
        return self.leftAnchor
    }
    
    var safeLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leadingAnchor
        }
        return self.leadingAnchor
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.rightAnchor
        }
        return self.rightAnchor
    }
    
    var safeTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.trailingAnchor
        }
        return self.trailingAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        }
        return self.bottomAnchor
    }
}

extension UITableView {
    func reloadWithoutScroll() {
        let offset = contentOffset
        reloadData()
        layoutIfNeeded()
        setContentOffset(offset, animated: false)
    }
}

// UITextView
extension UITextView {
    var caret: CGRect? {
        guard let selectedTextRange = self.selectedTextRange else { return nil }
        return self.caretRect(for: selectedTextRange.end)
    }
}

/*
extension UITextView {
    public func resize() {
        var newFrame = self.frame
        let width = newFrame.size.width
        let newSize = self.sizeThatFits(CGSize(width: width,
                                                   height: CGFloat.greatestFiniteMagnitude))
        newFrame.size = CGSize(width: width, height: newSize.height)
        self.frame = newFrame
        let minViewHeight : CGFloat = 256
        if newSize.height >= minViewHeight {
            self.heightAnchor.constraint(equalToConstant: newSize.height).isActive = true
        }
        
    }
}
*/

// CUSTOM "Pop-Up" SEGUE
// HAS NOT BEEN TESTED
class AlwaysPopupSegue : UIStoryboardSegue, UIPopoverPresentationControllerDelegate
{
    override init(identifier: String?, source: UIViewController, destination: UIViewController)
    {
        super.init(identifier: identifier, source: source, destination: destination)
        destination.modalPresentationStyle = UIModalPresentationStyle.popover
        destination.popoverPresentationController!.delegate = self
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}


// MARK ---> FUNCTIONS


func randomInt(min: Int, max: Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min + 1)))
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
        static let SignInToMadGo = "SignInToMadGo"
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
        
        let tpLightBlue = UIColor(red: 106.0 / 255.0, green: 189.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        let tpDarkBlue = UIColor(red: 38.0 / 255.0, green: 99.0 / 255.0, blue: 157.0 / 255.0, alpha: 1.0).cgColor
        
        
        let colorTop = tpLightBlue
        let colorBottom = tpDarkBlue
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


// MARK: ---> HELPER FUNCTIONS
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}


// MARK: ---> The Tomorrow Planner


// MARK: --> Save and Load Functions 

func saveAllModelData(){
    saveTomorrowModel()
    saveTodayModel()
    saveFutureModel()
}

func saveTomorrowModel() {
    print("global: saving TOMORROW MODEL to tomorrow.json")
    Storage.store(TPTomorrowClass.sharedInstance.tomorrowModel, to: .documents, as: FileNameKeys.tomorrow)
}

func saveTodayModel(){
    print("global: saving TODAY MODEL to today.json")
    Storage.store(TPTodayClass.sharedInstance.todayModel, to: .documents, as: FileNameKeys.today)
}

func saveFutureModel() {
    print("global: saving FUTURE MODEL to future.json")
    Storage.store(TPFutureClass.sharedInstance.futureModel, to: .documents, as: FileNameKeys.future)
}

func saveFutureModel(model: TPFutureModel){
    Storage.store(model, to: .documents, as: FileNameKeys.future)
}

// this is a completion handler
typealias CompletionHandler = (_ success:Bool) -> Void

func saveTomorrowModelWithCompletion(completionHandler: CompletionHandler) {
    let flag = Storage.store(TPTomorrowClass.sharedInstance.tomorrowModel, to: .documents, as: FileNameKeys.tomorrow)
    completionHandler(flag)
}

func saveTodayModelWithCompletion(completionHandler: CompletionHandler) {
    let flag = Storage.store(TPTodayClass.sharedInstance.todayModel, to: .documents, as: FileNameKeys.today)
    completionHandler(flag)
}

func saveFutureModelWithCompletion(completionHandler: CompletionHandler) {
    let flag = Storage.store(TPFutureClass.sharedInstance.futureModel, to: .documents, as: FileNameKeys.future)
    completionHandler(flag)
}


func loadTomorrowModel() -> TPTomorrowModel? {
    // retrieve JSON data
    print("global: trying to load TPTomorrowModel")
    if let retrievedPlan = Storage.retrieve(FileNameKeys.tomorrow, from: .documents, as: TPTomorrowModel.self) {
        return retrievedPlan
    } else {
        print("global: could not retrieve a TPTomorrowModel from tomorrow.json")
        return nil
    }
}

func loadTodayModel() -> TPTodayModel? {
    // retrieve JSON data
    print("global: trying to TPTodayModel data")
    if let retrievedPlan = Storage.retrieve(FileNameKeys.today, from: .documents, as: TPTodayModel.self) {
        return retrievedPlan
    } else {
        print("global: could not retrieve a TPTodayModel from today.json")
        return nil
    }
}

func loadFutureModel() -> TPFutureModel? {
    // retrieve JSON data
    print("global: trying to load TPFutureModel data")
    if let retrievedPlan = Storage.retrieve(FileNameKeys.future, from: .documents, as: TPFutureModel.self) {
        return retrievedPlan
    } else {
        print("global: could not retrieve a TPFutureModel from future.json")
        return nil
    }
}

// save and load history data. Note: this hasn't been implemented yet
/*
func savePlanDataToHistory(model: [TPStruct]) {
    Storage.store(model, to: .documents, as: FileNameKeys.history)
}

func loadHistoryData() -> [TPStruct]? {
    if let historyArray = Storage.retrieve(FileNameKeys.history, from: .documents, as: [TPStruct].self){
        return historyArray
    }
    return nil
}
*/

func deleteAllTPLocalData(){
    // change to FileNameKeys and iterate through all.
    Storage.remove("tomorrowPlanner.json", from: .documents)
    Storage.remove("todayObject.json", from: .documents)
    //Storage.remove("history.json")
    
}

private struct FileNameKeys {
    static let today = "today.json"
    static let tomorrow = "tomorrow.json"
    static let history = "history.json"
    static let future = "future.json"
}

struct UserDefaultsKeys {
    static let appFirstRun = "isAppFirstRun"
}


// MARK: <--- END The Tomorrow Planner
