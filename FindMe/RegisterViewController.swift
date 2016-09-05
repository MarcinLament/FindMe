//
//  RegisterViewController.swift
//  FindMe
//
//  Created by Marcin Lament on 06/08/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import UIKit
import Parse

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameView: UIInputTextView!
    @IBOutlet weak var emailView: UIInputTextView!
    @IBOutlet weak var passwordView: UIInputTextView!
    @IBOutlet weak var displayNameView: UIInputTextView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        initStyles()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.handleSingleTap(_:)))
        self.view.addGestureRecognizer(gesture)
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func register(sender: AnyObject) {
        
        if(usernameView.getText() == "" || passwordView.getText() == "" || emailView.getText() == "" || displayNameView.getText() == ""){
            showAlert("Invalid details", message: "Fields cannot be empty.", completion: nil)
        }
        
        var missing = ""
        if isInvalidText(usernameView.getText()) { missing += "\n- Invalid username"}
        if isInvalidText(passwordView.getText()) { missing += "\n- Invalid password"}
        if isInvalidText(emailView.getText()) || !isValidEmail(emailView.getText()) { missing += "\n- Invalid email"}
        
        if(missing != ""){
            showAlert("Invalid details", message: "Please correct the following: \(missing)", completion: nil)
            return;
        }
        
        registerNewUser()
    }
    
    func registerNewUser(){
        //create unique user profile
        let userProfile = PFObject(className: "UserProfile")
        userProfile["displayName"] = displayNameView.getText()
        userProfile["email"] = emailView.getText()
        
        //create new user
        let user = PFUser()
        user.username = usernameView.getText()
        user.password = passwordView.getText()
        user.email = emailView.getText()
        user["userProfile"] = userProfile
        
        activityView.startAnimating()
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            
            if let error = error {
                let errorString = error.userInfo["error"] as? String
                self.showAlert("Cannot register", message: errorString!, completion: nil)
                self.activityView.stopAnimating()
            } else if(!succeeded){
                self.showAlert("Cannot register", message: "Internal server error", completion: nil)
                self.activityView.stopAnimating()
            }else{
                //login newly created user
                PFUser.logInWithUsernameInBackground(self.usernameView.getText(), password: self.passwordView.getText()) { (user, error) -> Void in
                    
                    self.activityView.stopAnimating()
                    if error != nil {
                        self.showAlert("Error", message: error!.localizedDescription, completion: nil)
                    } else {
                        PFCloud.callFunctionInBackground("verifyNewUser", withParameters: nil) {
                            (response: AnyObject?, error: NSError?) -> Void in
                            
                            //open map screen
                            self.performSegueWithIdentifier("OpenUserAreaSegue", sender: nil)
                        }
                    }
                }
            }
        }
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func isInvalidText(text: String) -> Bool{
        return text.characters.count > 45
            || text.containsString(" ")
    }
    
    func initStyles(){
        stylePrimaryButton(registerButton, roundedCorners: true)
        stylePrimaryBackground()
        
        usernameView.setStyle(nil, textPlaceholder: "Username", isPassword: false)
        emailView.setStyle(nil, textPlaceholder: "Email", isPassword: false)
        passwordView.setStyle(nil, textPlaceholder: "Password", isPassword: true)
        displayNameView.setStyle(nil, textPlaceholder: "Display name", isPassword: false)
    }
}