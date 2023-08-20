//
//  SignInTableVC.swift
//  SmallBlueIdea, LLC.
//
//  Created by Abram Andis on 05/09/2020.
//  Copyright © 2020 SMALLBLUEIDEA, LLC. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

@objc(SignInTableVC)

class SignInTableVC: UITableViewController {
    
        var ranOnce: Bool = false
        var runOnce: Bool = true
        var setupFieldsOnceBool: Bool = true
        //passwordField
        //signInButton
        //
    
        @IBOutlet weak var emailField: UITextField!
        @IBOutlet weak var passwordField: UITextField!
        @IBOutlet weak var signInButton: UIButton!
        @IBOutlet var mainTableView: UITableView!
    
        override func viewDidAppear(_ animated: Bool) {
            
            if let user = Auth.auth().currentUser {
                
                self.signedIn(user)
                // not working for Facebook
                /*if (user.isEmailVerified) {
                 self.signedIn(user)
                 }else { print("account not verified") }
                 */
            }
            
            //mainTableView.backgroundView = UIImageView(image: UIImage(named: "lightsOnBlue.jpg"))
            //mainTableView.backgroundView?.contentMode = .scaleAspectFill
            self.view.backgroundColor = UIColor.clear
            
            /*
             if (ranOnce == false) {
             addFaceBookLogin()
             }
             */
            
        }
        
        override func viewWillAppear(_ animated: Bool){
            
            // not calling super here will disable auto scroll.
            // iphoneSE the 'create account' button gets covered. I don't like this behavior on that device.
            
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.emailField.delegate = self
            self.passwordField.delegate = self
            
            self.emailField.autocorrectionType = .no
            self.emailField.spellCheckingType = .no
            self.passwordField.autocorrectionType = .no
            self.passwordField.spellCheckingType = .no
            
           // self.signInButton.layer.borderWidth = CGFloat(1.0)
           // self.signInButton.layer.borderColor = UIColor.white.cgColor
            
            self.hideKeyboardWhenTappedAround()
            //signInButton.backgroundColor = .clear
            //signInButton.layer.cornerRadius = 5
            //signInButton.layer.borderWidth = 1
            //signInButton.layer.borderColor = UIColor.white.cgColor
            registerForKeyboardNotifications()
            
            mainTableView.backgroundColor = UIColor.clear
            self.view.backgroundColor = UIColor.clear
        }
        
        override func viewDidLayoutSubviews() {
            
            /*
             Do not forget that this method is called multiple times and it's not a part of ViewController's life cycle, so be careful while using this.
             */
            
            setupUI()
            
        }
        // MARK: --> START KEYBOARD NOTIFICATIONS
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
          
            // get keyboard height and set contentInset
            let info = notification.userInfo!
            let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
            
            // handles scenario where keyboard size returns 0
            if let size = keyboardSize {
                if size.height >= CGFloat(32.0) {
                    let offset = CGPoint(x: 0, y: (keyboardSize?.height ?? CGFloat(256)) + CGFloat(8))
                    self.mainTableView.setContentOffset(offset, animated: true)
                }
            } else {
                    let offset = CGPoint(x: 0, y: (CGFloat(256)) + CGFloat(8))
                    self.mainTableView.setContentOffset(offset, animated: true)
            }
        }
            
        @objc func keyboardWillBeHidden(notification: Notification){
            let offset = CGPoint(x: 0, y: 0)
            self.mainTableView.setContentOffset(offset, animated: true)
            self.view.endEditing(true)
        }
        // END KEYBOARD NOTIFICATIONS
    
        func setupUI(){
            
            if (setupFieldsOnceBool){
                self.setupFieldsOnceBool = false
                // email field setup
                let border = CALayer()
                let width = CGFloat(1.0)
                border.borderColor = UIColor.white.cgColor
                border.frame = CGRect(x: 0, y: emailField.frame.size.height - width, width:  emailField.frame.size.width, height: emailField.frame.size.height)
                border.borderWidth = width
                emailField.layer.addSublayer(border)
                emailField.layer.masksToBounds = true
                
                emailField.attributedPlaceholder = NSAttributedString(string: "Email Address",
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
                // password field setup
                let border2 = CALayer()
                let width2 = CGFloat(1.0)
                border2.borderColor = UIColor.white.cgColor
                border2.frame = CGRect(x: 0, y: passwordField.frame.size.height - width, width:  passwordField.frame.size.width, height: passwordField.frame.size.height)
                border2.borderWidth = width2
                
                passwordField.layer.addSublayer(border2)
                passwordField.layer.masksToBounds = true
                
                passwordField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
            }else { return }
        }
    
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        // MARK: - Table view data source
        override func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            return 1
        }
        
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            // sets the row height to the screen size of the device
            let cellDefaultHeight : CGFloat = 670.0
            let screenDefaultHeight : CGFloat = 670.0
            let factor : CGFloat = cellDefaultHeight/screenDefaultHeight
            let mainScreenHeight : CGFloat = UIScreen.main.bounds.size.height
            return factor * mainScreenHeight
            
        }
        
        // MARK: - Actions
        // EMAIL AUTH LOGIN
    
        @IBAction func didTapSignIn(_ sender: Any) {
            // Sign in with email
            guard let email = emailField.text, let password = passwordField.text else { return }
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
                guard let strongSelf = self else { return }
                
                if let error = error {
                    strongSelf.fireErrorHandle(error: error)
                    return
                }
                
                if let user = authResult?.user {
                    if (user.isEmailVerified) {
                        strongSelf.setDisplayName(user)
                        //self.signedIn(user)
                    }else {
                        // sends another verification email... original one expires pretty fast.
                        user.sendEmailVerification(completion: nil)
                        strongSelf.showAlert(withTitle: "Account not verified!", message: "Please check your email to verify your account.")
                        // doesn't show up after the other one BUG
                        // self.showAlert(withTitle: "Verification sent!", message: "New Email Verification sent.")
                    }
                }
                
            }
        }
    
    
        @IBAction func didTapForgotPassword(_ sender: Any) {
        
            let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
                
                let userInput = prompt.textFields![0].text
                if (userInput!.isEmpty) {
                    return
                }
                
                Auth.auth().sendPasswordReset(withEmail: userInput!) { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    self.showAlert(withTitle: "Password reset sent!", message: "Please check your email to reset your password.")
                }
            }
            
            let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (action) in
                print("Password reset cancelled")
                return
            }
            
            //prompt.addTextField(configurationHandler: nil)
            prompt.addTextField { (textField) in
                
                textField.text = self.emailField.text ?? ""
                
            }
            
            prompt.addAction(cancelAction)
            prompt.addAction(okAction)
            present(prompt, animated: true, completion: nil)

        }
    
        @IBAction func didTapCreateAccount(_ sender: Any) {
            guard let email = emailField.text, let password = passwordField.text else { return }
            
            if !isValidEmail(candidate: email) {
                showAlert(withTitle: "Email Invalid", message: "Please enter a valid email address")
                return
            }
            if !isValidPassword(candidate: password){
                showAlert(withTitle: "Password", message: "Password must be greater than 8 characters and have at least 1 capital letter.")
                return
            }
            
            // note this creates a new user without verifying email!!
            // we need to have a user email verified before they can access critical app data so we don't have malicious software creating thousands of accounts!!
            
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] (authResult, error) in
                
                guard let strongSelf = self else { return }
                
                if let error = error {
                    strongSelf.fireErrorHandle(error: error)
                    return
                }
                
                if let user = authResult?.user {
                    authResult?.user.sendEmailVerification( completion: nil )
                    
                    if (user.isEmailVerified) {
                        strongSelf.setDisplayName(user)
                    }else {
                        strongSelf.showAlert(withTitle: "Thank you for signing up!", message: "Please check your email to verify your account, then sign in.")
                    }
                }
            }
        }

        // SIGN OUT (Action for Segue)
          @IBAction func prepareForSignOutUnwind(segue: UIStoryboardSegue){
            // add another one of these
            do {
                print("Signing Out")
                try Auth.auth().signOut()
            }catch {
                
            }
            self.showAlert(withTitle: "Signed Out", message: "", withVC: self)
        }
    
        // END: - ACTIONS
        // MARK: - Functions
        
        func setDisplayName(_ user: User) {
            // something is happening in here that causes .signedIn(user) not to be called
            let changeRequest = user.createProfileChangeRequest()
            if (user.email != nil){
                
                changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
                changeRequest.commitChanges(){ (error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    // sign in
                    if let user = Auth.auth().currentUser {
                        if (user.isEmailVerified) {
                            self.signedIn(user)
                        }else {print("user has not verified email!")}
                    }
                    
                }
            }else { print("user.email not found, cannot change name") }
            
        }
        
        func signedIn(_ user: User?) {
            
            if user != nil {
                // FIR Analytics
                // MeasurementHelper.sendLoginEvent()
                AppState.sharedInstance.displayName = user?.displayName ?? user?.email
                AppState.sharedInstance.photoURL = user?.photoURL
                AppState.sharedInstance.signedIn = true
                let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.SignedIn)
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
                performSegue(withIdentifier: Constants.Segues.SignInSegue, sender: nil)
            }else {print("signedIn() failed, nil user")}
            
        }
        
        func showAlert(withTitle title:String, message:String) {
            DispatchQueue.main.async {
                print("show Alert called")
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
                alert.addAction(dismissAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        func fireErrorHandle(error: Error) {
            
            if let errorCode = AuthErrorCode(rawValue: error._code){
                
                switch errorCode {
                
                case .wrongPassword:
                    self.showAlert(withTitle: "Incorrect Password", message: "Please try again.")
                case .emailAlreadyInUse:
                    self.showAlert(withTitle: "Email Already In Use.", message: "This Email Address is already being used.")
                
                default:
                print("An internal error occurred in SignInTableVC")
                print(errorCode)
                print(error)
                self.showAlert(withTitle: "An Error Occured", message: error.localizedDescription)
                }
            }
        }
        
}

extension SignInTableVC: UITextFieldDelegate {

    // MARK: ---> Textfield Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //print("TextField did end editing method called")
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //print("TextField should begin editing method called")
        return true;
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //print("TextField should clear method called")
        return true;
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //print("TextField should end editing method called")
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // called when entering characters in a text field
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("TextField should return method called")
        textField.resignFirstResponder()
        textField.endEditing(true)
        return true;
    }

    // MARK: Textfield Delegates <---

}


