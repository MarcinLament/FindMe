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
    
    @IBOutlet weak var usernameView: UITextField!
    @IBOutlet weak var emailView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var displayNameView: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        usernameView.delegate = self
        passwordView.delegate = self
        emailView.delegate = self
        displayNameView.delegate = self
        
        checkRegisterButtonState()
    }

    @IBAction func close(sender: AnyObject?) {
        dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func register(sender: AnyObject) {
        
        var missing = ""
        if isInvalidText(usernameView.text!) { missing += "\n- Invalid username"}
        if isInvalidText(passwordView.text!) { missing += "\n- Invalid password"}
        if isInvalidText(emailView.text!) || !isValidEmail(emailView.text!) { missing += "\n- Invalid email"}
        
        if(missing != ""){
            showAlert("Invalid details", message: "Please correct the following: \(missing)", completion: nil)
            return;
        }
        
        registerNewUser()
    }
    
    func isValidEmail(text: String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(text)
    }
    
    func isInvalidText(text: String) -> Bool{
        return text.characters.count > 45
            || text.containsString(" ")
    }
    
    func registerNewUser(){
        //create unique user profile
        let userProfile = PFObject(className: "UserProfile")
        userProfile["display_name"] = displayNameView.text
        
        //create new user
        var user = PFUser()
        user.username = usernameView.text
        user.password = passwordView.text
        user.email = emailView.text
        user["user_profile"] = userProfile
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? String
                self.showAlert("Cannot register", message: errorString!, completion: nil)
            } else {
                //login newly created user
            }
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        checkRegisterButtonState()
        return true
    }
    
    func checkRegisterButtonState(){
        let hasMissingField = usernameView.text == ""
            || passwordView.text == ""
            || emailView.text == ""
            || displayNameView.text == ""
        
        registerButton.enabled = !hasMissingField
        registerButton.userInteractionEnabled = !hasMissingField
    }
}