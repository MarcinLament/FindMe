//
//  ViewController.swift
//  FindMe
//
//  Created by Marcin Lament on 06/08/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    
    override func viewWillAppear(animated: Bool) {
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            print("User logged in, moving on...")
            openMapViewController()
            return
        }
        print("User not logged in")
        
        usernameView.hidden = false
        passwordView.hidden = false
        loginButton.hidden = false
        registerButton.hidden = false
        
        usernameView.delegate = self
        passwordView.delegate = self
        checkLoginButtonState()
    }

    @IBAction func login(sender: AnyObject) {
        
        PFUser.logInWithUsernameInBackground(usernameView.text!, password: passwordView.text!) { (user, error) -> Void in
            if error == nil {
                self.openMapViewController()
            } else {
                self.showAlert("Error", message: error!.localizedDescription, completion: nil)
            }
        }
        
    }

    @IBAction func register(sender: AnyObject) {

        let next = storyboard?.instantiateViewControllerWithIdentifier("RegisterViewController")
        self.presentViewController(next!, animated: true, completion: nil)
    }
    
    func openMapViewController(){
        performSegueWithIdentifier("OpenUserAreaSegue", sender: nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        checkLoginButtonState()
        return true
    }
    
    func checkLoginButtonState(){
        let hasMissingField = usernameView.text == ""
            || passwordView.text == ""
        
        loginButton.enabled = !hasMissingField
        loginButton.userInteractionEnabled = !hasMissingField
    }
}

